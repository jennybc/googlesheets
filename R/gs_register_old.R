#' Register an old Google Sheet
#'
#' @name gs_register_old
#'
#' @param x sheet-identifying information; a character vector of length one
#'   holding old sheet key or browser URL.
#' @param lookup logical, optional. Controls whether \code{googlesheets} will
#'   place authorized API requests during registration. If unspecified, will
#'   be set to \code{TRUE} if authorization has previously been used in this R
#'   session, if working directory contains a file named \code{.httr-oauth}, or
#'   if \code{x} is a worksheets feed or \code{googlesheet} object that
#'   specifies "public" visibility.
#' @template visibility
#' @template verbose
#'
#' @return a \code{googlesheet} object
#' 
#' @export
#'
#' @examples
#' # The following spreadsheet from Gapminder collection would not get identified using gs_key()
#' gs_key_old("phAwcNAVuyj0TAlJeCEzcGQ", lookup=FALSE)
#' 
#' @importFrom httr stop_for_status
gs_key_old <- function(x, lookup = NULL, visibility = NULL, verbose = TRUE){
  # three alternative urls to try
  url_start_list <-
    c(url_start_old1 = "https://docs.google.com/spreadsheet/pub?key=",
      url_start_old2 = "https://docs.google.com/spreadsheet/ccc?key=",
      url_start_old3 = "https://spreadsheets.google.com/ccc?key=")
  
  for (url in url_start_list){
    res <- rGET(paste0(url,x))
    if (res$status_code==200) break
  }
  
  httr::stop_for_status(res)
  
  if (verbose) {
    mpf("Success! New url for this key is found!\nAttempting %s", res$url)
  }
  
  gs_url(res$url, lookup, visibility, verbose)
}

#' @rdname gs_register_old
#' @export
#'
#' @examples
#' # this spreadsheet from Gapminder collection would not get identified using gs_key()
#' gs_url_old("http://docs.google.com/spreadsheet/pub?key=phAwcNAVuyj0TAlJeCEzcGQ", lookup=FALSE)
gs_url_old <- function(x, lookup = NULL, visibility = NULL, verbose = TRUE){
  
  if (verbose) {
    mpf("Extracting the key from the url!")
  }
  
  key <- extract_key_from_url(x)
  gs_key_old(key, lookup, visibility, verbose)
}