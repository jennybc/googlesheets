#' Visit a Google Sheet in the browser
#'
#' @template ss
#' @template ws
#'
#' @return the \code{\link{googlesheet}} object given as input, invisibly
#' @export
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap()
#' gs_browse(gap_ss)
#' gs_browse(gap_ss, ws = 3)
#' gs_browse(gap_ss, ws = "Europe")
#'
#' ## assign and browse at once
#' gap_ss <- gs_gap() %>% gs_browse()
#' }
gs_browse <- function(ss, ws = 1) {
  if (!interactive()) return(invisible(ss))
  ws_browser_url <- ss$browser_url
  if (ws != 1) {
    this_ws <- gs_ws(ss, ws, verbose = FALSE)
    ws_bit <- paste0("edit#gid=", this_ws$gid)
    ws_browser_url <- file.path(gsub("/$", "", ws_browser_url), ws_bit)
  }
  utils::browseURL(ws_browser_url)
  return(invisible(ss))
}
