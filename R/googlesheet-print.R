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

  cpf("                  Spreadsheet title: %s", x$sheet_title)
  cpf("                 Spreadsheet author: %s", x$author)
  cpf("  Date of googlesheets registration: %s",
      x$reg_date %>% format.POSIXct(usetz = TRUE))
  cpf("    Date of last spreadsheet update: %s",
      x$updated %>% format.POSIXct(usetz = TRUE))
  cpf("                         visibility: %s", x$visibility)
  cpf("                        permissions: %s", x$perm)
  cpf("                            version: %s", x$version)
  cat("\n")

  ws_output <-
    sprintf("%s: %d x %d",
            x$ws$ws_title, x$ws$row_extent, x$ws$col_extent)
  cpf("Contains %d worksheets:", x$n_ws)
  cat("(Title): (Nominal worksheet extent as rows x columns)\n")
  cat(ws_output, sep = "\n")

  cat("\n")
  cpf("Key: %s", x$sheet_key)
  if (!is.na(x$alt_key)) cpf("Alternate key: %s", x$alt_key)
  cpf("Browser URL: %s", x$browser_url)
}
