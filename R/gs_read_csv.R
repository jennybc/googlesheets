#' Read data via the \code{exportcsv} link
#'
#' This function reads all data from a worksheet and returns it as a
#' \code{tbl_df} or \code{data.frame}. Don't be spooked by the "csv" thing --
#' the data is NOT actually written to file during this process. Data is read
#' from the "maximal data rectangle", i.e. the rectangle spanned by the maximal
#' row and column extent of the data. Empty cells within this rectangle will be
#' assigned NA. This is the fastest method of data consumption, so use it as
#' long as you can tolerate the lack of control re: which cells are being read.
#'
#' How does this compare to consumption via the list feed, implemented by
#' \code{\link{gs_read_listfeed}}? First, \code{gs_read_csv} is much, much
#' faster. Second, the first row, potentially containing column or variable
#' names, is NOT transformed/mangled, as it is via the list feed. Finally,
#' consumption via the \code{exportcsv} link is more tolerant of data that does
#' not form a perfect, neat rectangle, e.g. the read does NOT stop upon
#' encountering an empty row.
#'
#' @template ss
#' @template ws
#' @param ... Further arguments to be passed to the csv parser. This is
#'   currently \code{\link{read.csv}}, but expect a switch to
#'   \code{readr::read_csv} in the not-too-distant future! Note that by default
#'   \code{\link{read.csv}} is called with \code{stringsAsFactors = FALSE}.
#' @template verbose
#'
#' @family data consumption functions
#'
#' @return a tbl_df
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' oceania_csv <- gs_read_csv(gap_ss, ws = "Oceania")
#' str(oceania_csv)
#' oceania_csv
#' }
#' @export
gs_read_csv <- function(ss, ws = 1, ..., verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"))

  this_ws <- gs_ws(ss, ws, verbose)

  if(is.null(this_ws$exportcsv)) {
    stop(paste("This appears to be an \"old\" Google Sheet. The old Sheets do",
               "not offer the API access required by this function.",
               "Consider converting it from an old Sheet to a new Sheet.",
               "Or use another data consumption function, such as",
               "gs_read_listfeed() or gs_read_cellfeed(). Or use gs_download()",
               "to export it to a local file and then read it into R."))
  }

  req <- gsheets_GET(this_ws$exportcsv, to_xml = FALSE,
                     use_auth = !ss$is_public)

  if(req$headers$`content-type` != "text/csv") {
    stop1 <- "Cannot access this sheet via csv."
    stop2 <- "Are you sure you have permission to access this Sheet?"
    stop3 <- paste("If this Sheet is supposed to be public, make sure it is",
                   "\"published to the web\", which is NOT the same as",
                   "\"public on the web\".")
    stop4 <- sprintf("status_code: %s", req$status_code)
    stop5 <- sprintf("content-type: %s", req$headers$`content-type`)
    stop(paste(stop1, stop2, stop3, stop4, stop5, sep = "\n"))
  }

  if(is.null(req$content) || length(req$content) == 0L) {
    message(sprintf("Worksheet \"%s\" is empty.", this_ws$ws_title))
    dplyr::data_frame()
  } else {
    ## numeric columns have an NA for empty cells
    ## character columns have "" for empty cells
    ## hence the value of na.strings
    req %>%
      httr::content(type = "text/csv", na.strings = c("", "NA"),
                    encoding = "UTF-8", ...) %>%
      dplyr::as_data_frame() %>%
      dplyr::as.tbl()
    ## in future, I'm interested in using readr::read_csv(), either directly
    ## or indirectly, if httr make it the parser when MIME type is text/csv
    ## won't do it know because doesn't support vector valued na.strings,
    ## comment.char, etc.
    ## track progress on these issues:
    ## https://github.com/hadley/readr/issues/167
    ## https://github.com/hadley/readr/issues/114
    ## https://github.com/hadley/readr/issues/125
    ## parsing content "by hand" with readr_csv() might look like so:
    ## req %>%
    ##   httr::content(type = "text", encoding = "UTF-8") %>%
    ##   readr::read_csv()
  }

}


