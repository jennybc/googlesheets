#' Print info about a \code{googlesheet} object
#'
#' Display information about a Google spreadsheet that has been registered with
#' \code{googlesheets}: the title of the spreadsheet, date-time of registration,
#' date-time of last update (at time of registration), visibility, permissions,
#' version, the number of worksheets contained, worksheet titles and extent, and
#' sheet key.
#'
#' @param x \code{\link{googlesheet}} object returned by functions such as \code{\link{gs_title}}, \code{\link{gs_key}}, and friends
#' @param ... potential further arguments (required for Method/Generic reasons)
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' foo
#' print(foo)
#' }
#'
#' @export
print.googlesheet <- function(x, ...) {

  sprintf("                  Spreadsheet title: %s\n", x$sheet_title) %>% cat()
  sprintf("                 Spreadsheet author: %s\n", x$author) %>% cat()
  sprintf("  Date of googlesheets registration: %s\n",
          x$reg_date %>% format.POSIXct(usetz = TRUE)) %>% cat()
  sprintf("    Date of last spreadsheet update: %s\n",
          x$updated %>% format.POSIXct(usetz = TRUE)) %>% cat()
  sprintf("                         visibility: %s\n", x$visibility) %>% cat()
  sprintf("                        permissions: %s\n", x$perm) %>% cat()
  sprintf("                            version: %s\n", x$version) %>% cat()
  cat("\n")

  ws_output <-
    sprintf("%s: %d x %d",
            x$ws$ws_title, x$ws$row_extent, x$ws$col_extent)
  sprintf("Contains %d worksheets:\n", x$n_ws) %>% cat()
  cat("(Title): (Nominal worksheet extent as rows x columns)\n")
  cat(ws_output, sep = "\n")

  cat("\n")
  sprintf("Key: %s\n", x$sheet_key) %>% cat()
  if(!is.na(x$alt_key)) sprintf("Alternate key: %s\n", x$alt_key) %>% cat()
  sprintf("Browser URL: %s\n", x$browser_url) %>% cat()
}
