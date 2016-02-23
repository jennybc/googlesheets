# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authorize \code{googlesheets}
#'
#' Authorize \code{googlesheets} to view and manage your files. You will be
#' directed to a web browser, asked to sign in to your Google account, and to
#' grant \code{googlesheets} permission to operate on your behalf with Google
#' Sheets and Google Drive. By default, these user credentials are cached in a
#' file named \code{.httr-oauth} in the current working directory, from where
#' they can be automatically refreshed, as necessary.
#'
#' Most users, most of the time, do not need to call this function
#' explicitly -- it will be triggered by the first action that
#' requires authorization. Even when called, the default arguments will often
#' suffice. However, when necessary, this function allows the user to
#'
#' \itemize{
#'   \item force the creation of a new token
#'   \item retrieve current token as an object, for possible storage to an
#'   \code{.rds} file
#'   \item read the token from an object or from an \code{.rds} file
#'   \item provide your own app key and secret -- this requires setting up a new
#'   project in
#'   \href{https://console.developers.google.com}{Google Developers Console}
#'   \item prevent caching of credentials in \code{.httr-oauth}
#' }
#'
#' In a direct call to \code{gs_auth}, the user can provide the token, app key
#' and secret explicitly and can dictate whether interactively-obtained
#' credentials will be cached in \code{.httr_oauth}. If unspecified, these
#' arguments are controlled via options, which, if undefined at the time
#' \code{googlesheets} is loaded, are defined like so:
#'
#' \describe{
#'   \item{key}{Set to option \code{googlesheets.client_id}, which defaults to
#'   a client ID that ships with the package}
#'   \item{secret}{Set to option \code{googlesheets.client_secret}, which
#'   defaults to a client secret that ships with the package}
#'   \item{cache}{Set to option \code{googlesheets.httr_oauth_cache}, which
#'   defaults to \code{TRUE}}
#' }
#'
#' To override these defaults in persistent way, predefine one or more of
#' them with lines like this in a \code{.Rprofile} file:
#' \preformatted{
#' options(googlesheets.client_id = "FOO",
#'         googlesheets.client_secret = "BAR",
#'         googlesheets.httr_oauth_cache = FALSE)
#' }
#' See \code{\link[base]{Startup}} for possible locations for this file and the
#' implications thereof.
#'
#' More detail is available from
#' \href{https://developers.google.com/identity/protocols/OAuth2InstalledApp}{Using
#' OAuth 2.0 for Installed Applications}. See \code{\link{gs_webapp_auth_url}}
#' and \code{\link{gs_webapp_get_token}} for functions that execute the "web
#' server application" flow.
#'
#' @param token optional; an actual token object or the path to a valid token
#'   stored as an \code{.rds} file
#' @param new_user logical, defaults to \code{FALSE}. Set to \code{TRUE} if you
#'   want to wipe the slate clean and re-authenticate with the same or different
#'   Google account. This disables the \code{.httr-oauth} file in current
#'   working directory.
#' @param key,secret the "Client ID" and "Client secret" for the application;
#'   defaults to the ID and secret built into the \code{googlesheets} package
#' @param cache logical indicating if \code{googlesheets} should cache
#'   credentials in the default cache file \code{.httr-oauth}
#' @template verbose
#'
#' @return an OAuth token object, specifically a
#'   \code{\link[=Token-class]{Token2.0}}, invisibly
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ## load/refresh existing credentials, if available
#' ## otherwise, go to browser for authentication and authorization
#' gs_auth()
#'
#' ## force a new token to be obtained
#' gs_auth(new_user = TRUE)
#'
#' ## store token in an object and then to file
#' ttt <- gs_auth()
#' saveRDS(ttt, "ttt.rds")
#'
#' ## load a pre-existing token
#' gs_auth(token = ttt)       # from an object
#' gs_auth(token = "ttt.rds") # from .rds file
#' }
gs_auth <- function(token = NULL,
                    new_user = FALSE,
                    key = getOption("googlesheets.client_id"),
                    secret = getOption("googlesheets.client_secret"),
                    cache = getOption("googlesheets.httr_oauth_cache"),
                    verbose = TRUE) {

  if (new_user) {
    gs_deauth(clear_cache = TRUE, verbose = verbose)
  }

  if (is.null(token)) {

    scope_list <- c("https://spreadsheets.google.com/feeds",
                    "https://www.googleapis.com/auth/drive")
    googlesheets_app <- httr::oauth_app("google", key = key, secret = secret)
    google_token <-
      httr::oauth2.0_token(httr::oauth_endpoints("google"), googlesheets_app,
                           scope = scope_list, cache = cache)
    stopifnot(is_legit_token(google_token, verbose = TRUE))
    .state$token <- google_token

  } else if (inherits(token, "Token2.0")) {

    stopifnot(is_legit_token(token, verbose = TRUE))
    .state$token <- token

  } else if (inherits(token, "character")) {

    google_token <- try(suppressWarnings(readRDS(token)), silent = TRUE)
    if (inherits(google_token, "try-error")) {
      spf("Cannot read token from alleged .rds file:\n%s", token)
    } else if (!is_legit_token(google_token, verbose = TRUE)) {
      spf("File does not contain a proper token:\n%s", token)
    }
    .state$token <- google_token
  } else {
    spf("Input provided via 'token' is neither a",
        "token,\nnor a path to an .rds file containing a token.")
  }

  .state$user <- google_user()

  invisible(.state$token)

}

#' Produce Google token
#'
#' If token is not already available, call \code{\link{gs_auth}} to either load
#' from cache or initiate OAuth2.0 flow. Return the token -- not "bare" but,
#' rather, prepared for inclusion in downstream requests. Use \code{gd_token} or
#' \code{gs_token} to reveal the actual access token, suitable for use with
#' \code{curl}.
#'
#' @return a \code{request} object (an S3 class provided by \code{httr})
#'
#' @keywords internal
google_token <- function(verbose = FALSE) {
  if (!token_available(verbose = verbose)) gs_auth(verbose = verbose)
  httr::config(token = .state$token)
}

#' @rdname google_token
include_token_if <- function(cond) if(cond) google_token() else NULL
#' @rdname google_token
omit_token_if <- function(cond) if(cond) NULL else google_token()

#' Check token availability
#'
#' Check if a token is available in \code{\link{googlesheets}}' internal
#' \code{.state} environment.
#'
#' @return logical
#'
#' @keywords internal
token_available <- function(verbose = TRUE) {

  if (is.null(.state$token)) {
    if (verbose) {
      if(file.exists(".httr-oauth")) {
        message("A .httr-oauth file exists in current working ",
                "directory.\nWhen/if needed, the credentials cached in ",
                ".httr-oauth will be used for this session.\nOr run gs_auth() ",
                "for explicit authentication and authorization.")
      } else {
        message("No .httr-oauth file exists in current working directory.\n",
                "When/if needed, 'googlesheets' will initiate authentication ",
                "and authorization.\nOr run gs_auth() to trigger this ",
                "explicitly.")
      }
    }
    return(FALSE)
  }

  TRUE

}

#' Suspend authorization
#'
#' Suspend \code{\link{googlesheets}}' authorization to place requests to the
#' Drive and Sheets APIs on behalf of the authenticated user.
#'
#' @param clear_cache logical indicating whether to disable the
#'   \code{.httr-oauth} file in working directory, if such exists, by renaming
#'   to \code{.httr-oauth-SUSPENDED}
#' @template verbose
#'
#' @examples
#' \dontrun{
#' gs_deauth()
#' }
gs_deauth <- function(clear_cache = TRUE, verbose = TRUE) {

  if (clear_cache && file.exists(".httr-oauth")) {
    if(verbose) {
      message("Disabling .httr-oauth by renaming to .httr-oauth-SUSPENDED")
    }
    file.rename(".httr-oauth", ".httr-oauth-SUSPENDED")
  }

  if (token_available(verbose = FALSE)) {
    if (verbose) {
      message("Removing google token stashed internally in 'googlesheets'.")
    }
    rm("token", envir = .state)
  } else {
    message("No token currently in force.")
  }

  invisible(NULL)

}

#' Check that token appears to be legitimate
#'
#' @keywords internal
is_legit_token <- function(x, verbose = FALSE) {

  if (!inherits(x, "Token2.0")) {
    if(verbose) message("Not a Token2.0 object.")
    return(FALSE)
  }

  if("invalid_client" %in% unlist(x$credentials)) {
    # shouldn't happen if id and secret are good
    if(verbose) {
      message("Authorization error. Please check client_id and client_secret.")
    }
    return(FALSE)
  }

  if("invalid_request" %in% unlist(x$credentials)) {
    # in past, this could happen if user clicks "Cancel" or "Deny" instead of
    # "Accept" when OAuth2 flow kicks to browser ... but httr now catches this
    if(verbose) message("Authorization error. No access token obtained.")
    return(FALSE)
  }

  TRUE

}

## useful when debugging
gd_token <- gs_token <- function() {
  if (!token_available(verbose = TRUE)) return(NULL)
  .state$token$credentials$access_token
}
