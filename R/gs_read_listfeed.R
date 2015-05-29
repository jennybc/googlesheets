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
  req <- gsheets_GET(this_ws$listfeed)

  ns <- xml2::xml_ns_rename(xml2::xml_ns(req$content), d1 = "feed")

  var_names <- req$content %>%
    xml2::xml_find_all("(//feed:entry)[1]", ns) %>%
    xml2::xml_find_all(".//gsx:*", ns) %>%
    xml2::xml_name()

  values <- req$content %>%
    xml2::xml_find_all("//feed:entry//gsx:*", ns) %>%
    xml2::xml_text()

  dat <- matrix(values, ncol = length(var_names), byrow = TRUE,
                dimnames = list(NULL, var_names)) %>%
    ## convert to integer, numeric, etc. but w/ stringsAsFactors = FALSE
    ## empty cells returned as empty string ""
    plyr::alply(2, type.convert, na.strings = c("NA", ""), as.is = TRUE) %>%
    ## get rid of attributes that are non-standard for tbl_dfs or data.frames
    ## and that are an artefact of the above (specifically, I think, the use of
    ## alply?); if I don't do this, the output is fugly when you str() it
    `attr<-`("split_type", NULL) %>%
    `attr<-`("split_labels", NULL) %>%
    `attr<-`("dim", NULL) %>%
    ## for some reason removing the non-standard dim attributes clobbers the
    ## variable names, so those must be restored
    `names<-`(var_names) %>%
    ## convert to data.frame (tbl_df, actually)
    dplyr::as_data_frame()

  dat

}
