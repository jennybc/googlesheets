#' Read data via the "list feed"
#'
#' Gets data via the "list feed", which assumes populated cells form a neat
#' rectangle. The list feed consumes data row by row. The first row is assumed
#' to hold variable or column names. The related function,
#' \code{\link{gs_read_csv}}, also returns data from a rectangle of cells,
#' but it is generally faster and more resilient to, e.g. empty rows, so use it
#' if you can. However, you may need to use this function if you are dealing
#' with an "old" Google Sheet, which \code{\link{gs_read_csv}} does not
#' support). Consult the Google Sheets API documentation for more details about
#' \href{https://developers.google.com/google-apps/spreadsheets/data#work_with_list-based_feeds}{the
#' "list feed"}.
#'
#' @template ss
#' @template ws
#' @template verbose
#'
#' @note When you use the "list feed", the Sheets API transforms the variable or
#'   column names like so: 'The column names are the header values of the
#'   worksheet lowercased and with all non-alpha-numeric characters removed. For
#'   example, if the cell A1 contains the value "Time 2 Eat!" the column name
#'   would be "time2eat".' If this is intolerable to you, use a different
#'   function to read the data. Or, at least, consume the first row via the cell
#'   feed and manually restore the variable names \emph{post hoc}.
#'
#' @family data consumption functions
#'
#' @return a tbl_df
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' oceania_lf <- gs_read_listfeed(gap_ss, ws = "Oceania")
#' str(oceania_lf)
#' oceania_lf
#' }
#'
#' @export
gs_read_listfeed <- function(ss, ws = 1, verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"))

  this_ws <- gs_ws(ss, ws, verbose)
  the_url <- this_ws$listfeed
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
