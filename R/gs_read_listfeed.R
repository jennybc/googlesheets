#' Read data via the "list feed"
#'
#' Gets data via the "list feed", which assumes populated cells form a neat
#' rectangle. The list feed consumes data row by row. The first row is assumed
#' to hold variable or column names. The related function,
#' \code{\link{gs_read_csv}}, also returns data from a rectangle of cells, but
#' it is generally faster and more resilient to, e.g. empty header cells or
#' rows, so use it if you can. However, you may need to use this function if you
#' are dealing with an "old" Google Sheet, which is beyond the reach of
#' \code{\link{gs_read_csv}}. Consult the Google Sheets API documentation for
#' more details about
#' \href{https://developers.google.com/google-apps/spreadsheets/data#work_with_list-based_feeds}{the
#' list feed}.
#'
#' @template ss
#' @template ws
#' @param reverse logical, optional. Indicates whether to request reverse row
#'   order in the actual API call.
#' @param orderby character, optional. Specifies a column to sort on in the
#'   actual API call.
#' @param sq character, optional. Provides a structured query for row filtering
#'   in the actual API call.
#' @template verbose
#'
#' @section Column names:
#'
#'   When you use the list feed, the Sheets API transforms the variable or
#'   column names like so: 'The column names are the header values of the
#'   worksheet lowercased and with all non-alpha-numeric characters removed. For
#'   example, if the cell A1 contains the value "Time 2 Eat!" the column name
#'   would be "time2eat".' If this is intolerable to you, use a different
#'   function to read the data. Or, at least, consume the first row via the cell
#'   feed and manually restore the variable names \emph{post hoc}. If you direct
#'   \code{gs_read_listfeed} to pass query parameters to the actual API call,
#'   you must refer to variables using the column names \emph{after this
#'   API-enforced transformation}. For example, to order the data by the column
#'   with "Time 2 Eat!" in the header row, you must specify \code{orderby =
#'   "time2eat"} in the \code{gs_read_listfeed} call.
#'
#' @section Sorting and filtering via the API:
#'
#'   Why on earth would you want to sort and filter via the API instead of in R?
#'   Just because you can? It is conceivable there are situations, such as a
#'   large spreadsheet, in which it is faster to sort or filter via API. Be sure
#'   to refer to variables using the API-transformed column names explained
#'   above! It is a
#'   \href{https://code.google.com/a/google.com/p/apps-api-issues/issues/detail?id=3588}{known
#'    bug} that \code{reverse=true} alone will NOT, in fact, reverse the row
#'   order of the result. In our experience, the \code{reverse} query parameter
#'   will only have effect in combination with explicit specification of a
#'   column to sort on via \code{orderby}. The syntax for these queries
#'   \href{http://stackoverflow.com/questions/25732784/official-reference-for-google-spreadsheet-api-structured-query-syntax}{is
#'    apparently undocumented}, so keep it simple or bring your spirit of
#'   adventure!
#'
#' @family data consumption functions
#'
#' @return a tbl_df
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' oceania_lf <- gs_read_listfeed(gap_ss, ws = "Oceania")
#' head(oceania_lf, 3)
#'
#' oceania_fancy <-
#'   gs_read_listfeed(gap_ss,
#'                    ws = "Oceania",
#'                    reverse = TRUE, orderby = "gdppercap",
#'                    sq = "lifeexp > 79 or year < 1960")
#' oceania_fancy
#' }
#'
#' @export
gs_read_listfeed <- function(ss, ws = 1,
                             reverse = NULL, orderby = NULL, sq = NULL,
                             verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"))
  stopifnot(is_toggle(reverse))
  if (!is.null(orderby)) {
    stopifnot(is.character(orderby), length(orderby) == 1L)
    orderby <- paste("column", orderby, sep = ":")
  }
  if (!is.null(sq)) {
    stopifnot(is.character(sq), length(sq) == 1L)
  }

  this_ws <- gs_ws(ss, ws, verbose)
  if (!is.null(reverse)) reverse <- tolower(as.character(reverse))
  the_query <- list(reverse = reverse, orderby = orderby, sq = sq)
  the_url <- httr::modify_url(this_ws$listfeed, query = the_query)
  if (grepl("public", the_url)) {
    req <- httr::GET(the_url)
  } else {
    req <- httr::GET(the_url, get_google_token())
  }
  httr::stop_for_status(req)
  rc <- content_as_xml_UTF8(req)

  ns <- xml2::xml_ns_rename(xml2::xml_ns(rc), d1 = "feed")

  var_names <- rc %>%
    xml2::xml_find_one("(//feed:entry)[1]", ns) %>%
    xml2::xml_find_all(".//gsx:*", ns) %>%
    xml2::xml_name()

  values <- rc %>%
    xml2::xml_find_all("//feed:entry//gsx:*", ns) %>%
    xml2::xml_text()
  values[values == ""] <- NA_character_

  dat <- matrix(values, ncol = length(var_names), byrow = TRUE,
                dimnames = list(NULL, var_names))
  dat %>%
    ## https://github.com/hadley/dplyr/issues/876
    ## https://github.com/hadley/dplyr/commit/9a23e869a027861ec6276abe60fe7bb29a536369
    ## I can drop as.data.frame() once dplyr version >= 0.4.4
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::as_data_frame() %>%
    readr::type_convert()

}
