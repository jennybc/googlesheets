#' Read data via the "list feed"
#'
#' Gets data via the "list feed", which assumes populated cells form a neat
#' rectangle. The list feed consumes data row by row. The first row is assumed
#' to hold variable or column names. The related function,
#' \code{\link{gs_read_csv}}, also returns data from a rectangle of cells, but
#' it is generally faster and more resilient to, e.g. empty header cells or
#' rows, so use it if you can. However, you may need to use this function if you
#' are dealing with an "old" Google Sheet, which is beyond the reach of
#' \code{\link{gs_read_csv}}. The list feed also has some ability to sort and
#' filter rows via the API (more below). Consult the Google Sheets API
#' documentation for more details about
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
#' @param ... Further arguments to control parsing, most of which are passed to
#'   \code{\link[readr:type_convert]{readr::type_convert}}.
#' @template verbose
#'
#' @section Data ingest philosophy:
#'
#'   \code{\link{gs_read_csv}} is the "reference implementation" for ingesting
#'   data from a Google Sheet. This, in turn, implies that
#'   \code{\link[readr:read_delim]{readr::read_csv}} is the true reference. Use
#'   the \code{...} argument to control parsing behavior.
#'   \code{gs_read_listfeed} cannot actually pass the data through
#'   \code{\link[readr:read_delim]{readr::read_csv}}, but instead uses
#'   \code{\link[readr:type_convert]{readr::type_convert}}. Therefore, arguments
#'   passed via \code{...} are used in different ways. Some are used directly in
#'   \code{gs_read_listfeed} (example: \code{col_names}). Some are passed
#'   through to \code{\link[readr:type_convert]{readr::type_convert}} (example:
#'   \code{col_types}). Some are ignored because they are incompatible with the
#'   list feed (example: \code{comment}).
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
#' ## do row ordering and filtering in the API call
#' oceania_fancy <-
#'   gs_read_listfeed(gap_ss,
#'                    ws = "Oceania",
#'                    reverse = TRUE, orderby = "gdppercap",
#'                    sq = "lifeexp > 79 or year < 1960")
#' oceania_fancy
#'
#' ## modify data ingest in style of readr::read_csv, readr::type_convert
#' oceania_tweaked <-
#'   gs_read_listfeed(gap_ss,
#'                    ws = "Oceania",
#'                    col_names = paste0("VAR", 1:6),
#'                    col_types = "cccnnn")
#' oceania_tweaked
#' }
#'
#' @export
gs_read_listfeed <- function(ss, ws = 1,
                             reverse = NULL, orderby = NULL, sq = NULL,
                             ...,
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

  ddd <- list(...)
  col_names <- ddd$col_names
  if (!is.null(col_names)) stopifnot(is.character(col_names))
  col_types <- ddd$col_types
  locale <- ddd$locale %||% readr::default_locale()
  na <- ddd$na %||% c("", "NA")
  trim_ws <- ddd$trim_ws %||% TRUE
  oops <- intersect(names(ddd), c("comment", "skip", "n_max", "progress"))
  if (length(oops) > 0 && verbose) {
    mpf(paste("These arguments are incompatible with the list feed and\n",
              "will be ignored:\n%s"), paste(oops, collapse = ", "))
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
  n_cols <- length(var_names)
  if (!is.null(col_names)) {
    if (length(col_names) >= n_cols) {
      var_names <- col_names[seq_len(n_cols)]
    } else {
      if (verbose) mpf("'col_names' too short ... ignoring.")
    }
  }
  ## FIXME: get the var_names from the cellfeed so API doesn't mangle them

  values <- rc %>%
    xml2::xml_find_all("//feed:entry//gsx:*", ns) %>%
    xml2::xml_text()
  values[values == ""] <- NA_character_

  dat <- matrix(values, ncol = n_cols, byrow = TRUE,
                dimnames = list(NULL, var_names))
  dat %>%
    ## https://github.com/hadley/dplyr/issues/876
    ## https://github.com/hadley/dplyr/commit/9a23e869a027861ec6276abe60fe7bb29a536369
    ## I can drop as.data.frame() once dplyr version >= 0.4.4
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::as_data_frame() %>%
    readr::type_convert(col_types = col_types, na = na, trim_ws = trim_ws,
                        locale = locale)

}
