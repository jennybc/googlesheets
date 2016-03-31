#' Retrieve and report on the current token
#'
#' Prints information about the Google token that is in force and returns the
#' token invisibly.
#'
#' @template verbose
#'
#' @template return-Token2
#' @export
#'
#' @examples
#' \dontrun{
#' ## load/refresh existing credentials, if available
#' ## otherwise, go to browser for authentication and authorization
#' gs_auth()
#'
#' gd_token()
#' }
gd_token <- function(verbose = TRUE) {
  if (!token_available(verbose = verbose) || !is_legit_token(.state$token)) {
    if (verbose) message("No token currently in force.")
    return(invisible(NULL))
  }
  token <- .state$token
  token_valid <- token$validate()
  first_last_n <- function(x, n = 5) {
    paste(substr(x, start = 1, stop = n),
          substr(x, start = nchar(x) - n + 1, stop = nchar(x)), sep = "...")
  }
  scopes <- token$params$scope %>%
    strsplit(split = "\\s+") %>%
    purrr::flatten_chr()

  cpf("         access token: %s",
      if (token_valid) "valid" else "expired, will auto-refresh")
  cpf(" peek at access token: %s",
      first_last_n(token$credentials$access_token))
  cpf("peek at refresh token: %s",
      first_last_n(token$credentials$refresh_token))
  cpf("               scopes: %s",
      paste(scopes, collapse = "\n                       "))
  cpf("     token cache_path: %s", token$cache_path)
  invisible(token)
}

#' @export
#' @rdname gd_token
gs_token <- gd_token
