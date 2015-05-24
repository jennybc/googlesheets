# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authorize \code{googlesheets}
#'
#' Authorize \code{googlesheets} to access your Google user data. You will be
#' directed to a web browser, asked to sign in to your Google account, and to
#' grant \code{googlesheets} access to user data for Google Spreadsheets and
#' Google Drive. These user credentials are cached in a file named
#' \code{.httr-oauth} in the current working directory.
#'
#' Based on
#' \href{https://github.com/hadley/httr/blob/master/demo/oauth2-google.r}{this
#' demo} from \code{\link[httr]{httr}}.
#'
#' @param new_user logical, defaults to \code{FALSE}. Set to \code{TRUE} if you
#'   want to wipe the slate clean and re-authenticate with the same or different
#'   Google account.
#' @param token path to a valid token; intended primarily for internal use
#'
#' @export
gs_auth <- function(new_user = FALSE, token = NULL) {

  if(new_user && file.exists(".httr-oauth")) {
    message("Removing old credentials ...")
    file.remove(".httr-oauth")
  }

  if(is.null(token)) {

    scope_list <- c("https://spreadsheets.google.com/feeds",
                    "https://docs.google.com/feeds")

    googlesheets_app <-
      httr::oauth_app("google",
                      key = getOption("googlesheets.client_id"),
                      secret = getOption("googlesheets.client_secret"))

    google_token <-
      httr::oauth2.0_token(httr::oauth_endpoints("google"), googlesheets_app,
                           scope = scope_list, cache = TRUE)

    # check for validity so error is found before making requests
    # shouldn't happen if id and secret don't change
    if("invalid_client" %in% unlist(google_token$credentials)) {
      message("Authorization error. Please check client_id and client_secret.")
    }

    stopifnot(inherits(google_token, "Token2.0"))

    .state$token <- google_token

  } else {

    google_token <- readRDS(token)
    .state$token <- google_token

  }

  .state$user <- google_user()

}

#' Retrieve Google token from environment
#'
#' Get token if it's previously stored, else prompt user to get one.
#'
#' @keywords internal
get_google_token <- function() {
  
    if(is.null(.state$token)) {
      gs_auth()
    }
    
    httr::config(token = .state$token)
    
}

#' Retrieve Google user data
#'
#' @return a list
#'
#' @keywords internal
google_user <- function() {
  
  ## require pre-existing token, to avoid recursion that would arise if
  ## gdrive_GET() called gs_auth()

    req <- gdrive_GET("https://www.googleapis.com/drive/v2/about")
    
    user_stuff <- req$content$user
    list(displayName = user_stuff$displayName,
         emailAddress = user_stuff$emailAddress,
         auth_date = req$headers$date %>% httr::parse_http_date())
  
}

#' Retrieve information about authorized user
#'
#' Display information about a user that has been authorized via \code{gs_auth}:
#' the user's display name, email, the date-time of authorization for the
#' current session, date-time of access token expiry, and the validity of the
#' current access token. This is a subset of the information available from
#' \href{https://developers.google.com/drive/v2/reference/about/get}{the "about"
#' endpoint} of the Drive API.
#'
#' @param verbose logical, indicating if info should be printed
#'
#' @return a list containing user and session info
#'
#' @export
#' @examples
#' \dontrun{
#' gs_user()
#' }
#'
#' @export
gs_user <- function(verbose = TRUE) {
  
  if(token_exists()) {
    
      token <- .state$token
      token_ok <- token$validate()
      
      ret <- list(displayName = .state$user$displayName,
                  emailAddress = .state$user$emailAddress,
                  auth_date = .state$user$auth_date)
      
      if(token_ok) {
        ret$exp_date <- file.info(".httr-oauth")$mtime + 3600
      } else {
        ret$exp_date <- NA_character_ %>% as.POSIXct()
      }
    
    if(verbose) {
      sprintf("                       displayName: %s\n",
              ret$displayName) %>% cat()
      sprintf("                      emailAddress: %s\n",
              ret$emailAddress) %>% cat()
      sprintf("Date-time of session authorization: %s\n",
              ret$auth_date) %>% cat()
      sprintf("  Date-time of access token expiry: %s\n",
              ret$exp_date) %>% cat()
      if(token_ok) {
        message("Access token is valid.")
      } else {
        message(paste("Access token has expired and will be auto-refreshed."))
      }
  }
  }
  
  else if(verbose) cat("No user currently authorized.")
  
  invisible(ret)
  
}

#' Check if authorization currently in force
#'
#' @return logical
#'
#' @keywords internal
token_exists <- function() {
  
  if(is.null(.state$token)) {
    message("No authorization yet in this session!\n")
    
    if(file.exists(".httr-oauth")) {
      message(paste("NOTE: a .httr-oauth file exists in current working",
                    "directory.\n Run gs_auth() to use the",
                    "credentials cached in .httr-oauth for this session."))
    } else {
      message(paste("No .httr-oauth file exists in current working directory.",
                    "Run gs_auth() to provide credentials."))
    }
    
    invisible(FALSE)
    
  } else {
    
    invisible(TRUE)
    
  }
  
}

