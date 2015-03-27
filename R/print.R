#' Print information about a Google spreadsheet registered with gspreadr
#'
#' Display information about a Google spreadsheet that has been registered with
#' \code{gspreadr}: the title of the spreadsheet, date-time of registration,
#' date-time of last update (at time of registration), the number of worksheets
#' contained, worksheet titles and extent, and sheet key.
#'
#' @param x gspreadsheet object returned by \code{register_ss} and other
#'   \code{gspreadr} functions
#' @param ... potential further arguments (required for Method/Generic reasons)
#'
#' @examples
#' \dontrun{
#' foo <- new_ss("foo")
#' foo
#' print(foo)
#' }
#'
#' @export
print.gspreadsheet <- function(x, ...) {

  sprintf("              Spreadsheet title: %s\n", x$sheet_title) %>% cat
  sprintf("  Date of gspreadr::register_ss: %s\n",
          x$get_date %>% format.POSIXct(usetz = TRUE)) %>% cat
  sprintf("Date of last spreadsheet update: %s\n",
          x$updated %>% format.POSIXct(usetz = TRUE)) %>% cat
  cat("\n")

  ws_output <-
    sprintf("%s: %d x %d",
            x$ws$ws_title, x$ws$row_extent, x$ws$col_extent)
  sprintf("Contains %d worksheets:\n", x$n_ws) %>% cat
  cat("(Title): (Nominal worksheet extent as rows x columns)\n")
  cat(ws_output, sep = "\n")

  cat("\n")
  sprintf("Key: %s\n", x$sheet_key) %>% cat
  #sprintf("Worksheets feed: %s\n", x$ws_feed) %>% cat
}
