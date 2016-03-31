#' Visit a Google Sheet in the browser
#'
#' @template ss
#' @template ws
#'
#' @return nothing
#' @export
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap()
#' gs_browse(gap_ss)
#' gs_browse(gap_ss, ws = 3)
#' gs_browse(gap_ss, ws = "Europe")
#' }
gs_browse <- function(ss, ws = 1) {
  if (!interactive()) return()
  if (ws == 1) utils::browseURL(ss$browser_url)
  this_ws <- gs_ws(ss, ws, verbose = FALSE)
  ws_bit <- paste0("edit#gid=", this_ws$gid)
  ws_browser_url <- file.path(gsub("/$", "", ss$browser_url), ws_bit)
  utils::browseURL(ws_browser_url)
}
