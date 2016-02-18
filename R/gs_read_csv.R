#' Read data via the \code{exportcsv} link
#'
#' This function reads all data from a worksheet and returns it as a
#' \code{tbl_df} or \code{data.frame}. Don't be spooked by the "csv" thing --
#' the data is NOT actually written to file during this process. Data is read
#' from the "maximal data rectangle", i.e. the rectangle spanned by the maximal
#' row and column extent of the data. Empty cells within this rectangle will be
#' assigned \code{NA}. This is the fastest method of data consumption, so use it
#' as long as you can tolerate the lack of control re: which cells are being
#' read.
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
#'   \code{\link[readr]{read_csv}}.
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

  if (is.null(this_ws$exportcsv)) {
    stop("This appears to be an \"old\" Google Sheet. The old Sheets do\n",
         "not offer the API access required by this function.\n",
         "Consider converting it from an old Sheet to a new Sheet.\n",
         "Or use another data consumption function, such as\n",
         "gs_read_listfeed() or gs_read_cellfeed(). Or use gs_download()\n",
         "to export it to a local file and then read it into R.",
         call. = FALSE)
  }

  if (ss$is_public) {
    req <- httr::GET(this_ws$exportcsv)
  } else {
    req <- httr::GET(this_ws$exportcsv, get_google_token())
  }
  httr::stop_for_status(req)
  stop_for_content_type(req, "text/csv")

  if (is.null(req$content) || length(req$content) == 0L) {
    mpf("Worksheet \"%s\" is empty.", this_ws$ws_title)
    return(dplyr::data_frame())
  }

  req %>%
    httr::content(as = "text") %>%
    readr::read_csv(...)
  ## empty cells in   numeric columns come as NA
  ## empty cells in character columns come as ""
  ## --> we like the `na = c("", NA)` default in readr::read_csv()
  }
