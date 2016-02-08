# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authorize \code{googlesheets}
#'
#' Authorize \code{googlesheets} to access your Google user data. You will be
#' directed to a web browser, asked to sign in to your Google account, and to
#' grant \code{googlesheets} access to user data for Google Spreadsheets and
#' Google Drive. These user credentials are cached in a file named
#' \code{.httr-oauth} in the current working directory, from where they can be
#' automatically refreshed, as necessary.
#'
#' Most users, most of the time, do not need to call this function
#' explicitly -- it will be triggered by the first action that
#' requires authorization. Even when called, the default arguments will often
#' suffice. However, when necessary, this function allows the user to
#'
#' \itemize{
#'   \item store a token -- the token is invisibly returned and can be assigned
#'   to an object or written to an \code{.rds} file
#'   \item read the token from an \code{.rds} file or pre-existing object in the
#'   workspace
#'   \item provide your own app key and secret -- this requires setting up a new
#'   project in
#'   \href{https://console.developers.google.com}{Google Developers Console}
#'   \item prevent caching of credentials in \code{.httr-oauth}
#' }
#'
#' In a call to \code{gs_auth}, the user can provide the token, app key and
#' secret explicitly and can dictate whether credentials will be cached in
#' \code{.httr_oauth}. If unspecified, these arguments are controlled via
#' options, which, if undefined at the time \code{googlesheets} is loaded, are
#' defined like so:
#'
#' \describe{
#'   \item{key}{Set to option \code{googlesheets.client_id}, which defaults to
#'   a client ID that ships with the package}
#'   \item{secret}{Set to option \code{googlesheets.client_secret}, which
#'   defaults to a client secret that ships with the package}
#'   \item{cache}{Set to option \code{googlesheets.httr_oauth_cache}, which
#'   defaults to TRUE}
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
#' \href{https://developers.google.com/identity/protocols/OAuth2}{Using OAuth
#' 2.0 to Access Google APIs}. This function executes the "installed
#' application" flow. See \code{\link{gs_webapp_auth_url}} and
#' \code{\link{gs_webapp_get_token}} for functions that execute the "web server
#' application" flow.
#'
#' @param token an actual token object or the path to a valid token stored as an
#'   \code{.rds} file
#' @param new_user logical, defaults to \code{FALSE}. Set to \code{TRUE} if you
#'   want to wipe the slate clean and re-authenticate with the same or different
#'   Google account. This deletes the \code{.httr-oauth} file in current working
#'   directory.
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
gs_auth <- function(token = NULL,
                    new_user = FALSE,
                    key = getOption("googlesheets.client_id"),
                    secret = getOption("googlesheets.client_secret"),
                    cache = getOption("googlesheets.httr_oauth_cache"),
                    verbose = TRUE) {

  if(new_user && file.exists(".httr-oauth")) {
    if(verbose) message("Removing old credentials ...")
    file.remove(".httr-oauth")
  }

  if(is.null(token)) {

    scope_list <- c("https://spreadsheets.google.com/feeds",
                    "https://www.googleapis.com/auth/drive")

    googlesheets_app <- httr::oauth_app("google", key = key, secret = secret)

    google_token <-
      httr::oauth2.0_token(httr::oauth_endpoints("google"), googlesheets_app,
                           scope = scope_list, cache = cache)

    stopifnot(is_legit_token(google_token, verbose = TRUE))

    .state$token <- google_token

  } else {

    if(is_legit_token(token)) {
      google_token <- token
    } else {
      google_token <- try(suppressWarnings(readRDS(token)), silent = TRUE)
      if(inherits(google_token, "try-error")) {
        if(verbose) {
          message(sprintf("Cannot read token from alleged .rds file:\n%s",
                          token))
        }
        return(invisible(NULL))
      } else if(!is_legit_token(google_token, verbose = TRUE)) {
        if(verbose) {
          message(sprintf("File does not contain a proper token:\n%s", token))
        }
        return(invisible(NULL))
      }
    }
    .state$token <- google_token

  }

  .state$user <- google_user()

  invisible(.state$token)

}

#' Retrieve Google token from environment
#'
#' Get token if it's previously stored, else prompt user to get one.
#'
#' @keywords internal
get_google_token <- function() {

  if(is.null(.state$token) || !is_legit_token(.state$token)) {
    gs_auth()
  }

  httr::config(token = .state$token)

}

#' Check if authorization currently in force
#'
#' @return logical
#'
#' @keywords internal
token_exists <- function(verbose = TRUE) {

  if(is.null(.state$token)) {
    if(verbose) {

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

    FALSE

  } else {

    TRUE

  }

}

#' Suspend authorization
#'
#' This unexported function exists so we can suspend authorization for
#' testing purposes.
#'
#' @keywords internal
gs_auth_suspend <- function(disable_httr_oauth = TRUE, verbose = TRUE) {

  if(disable_httr_oauth && file.exists(".httr-oauth")) {
    if(verbose) {
      message("Disabling .httr-oauth by renaming to .httr-oauth-SUSPENDED")
    }
    file.rename(".httr-oauth", ".httr-oauth-SUSPENDED")
  }

  if(!is.null(.state$token)) {
    if(verbose) {
      message(paste("Removing google token stashed in googlesheets's",
                    "internal environment"))
    }
    rm("token", envir = .state)
  }

}

#' Check that token appears to be legitimate
#'
#' This unexported function exists to catch tokens that are technically valid,
#' i.e. `inherits(token, "Token2.0")` is TRUE, but that have dysfunctional
#' credentials.
#'
#' @keywords internal
is_legit_token <- function(x, verbose = FALSE) {

  if(!inherits(x, "Token2.0")) {
    if(verbose) message("Not a Token2.0 object.")
    return(FALSE)
  }

  if("invalid_client" %in% unlist(x$credentials)) {
    # check for validity so error is found before making requests
    # shouldn't happen if id and secret don't change
    if(verbose) {
      message("Authorization error. Please check client_id and client_secret.")
    }
    return(FALSE)
  }

  if("invalid_request" %in% unlist(x$credentials)) {
    # known example: if user clicks "Cancel" instead of "Accept" when OAuth2
    # flow kicks to browser
    if(verbose) message("Authorization error. No access token obtained.")
    return(FALSE)
  }

  TRUE

}
