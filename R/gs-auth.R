# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authorize \code{googlesheets} to access user data from Google
#'
#' The user will be directed to a web browser, asked to sign in to their Google
#' account, and to grant \code{googlesheets} access to user data for Google
#' Spreadsheets and Google Drive. User credentials will be cached in a file
#' named \code{.httr-oauth} in the current working directory.
#'
#' Based on
#' \href{https://github.com/hadley/httr/blob/master/demo/oauth2-google.r}{this
#' demo} from \code{\link[httr]{httr}}.
#'
#' @param new_user logical, defaults to \code{FALSE}. Set to \code{TRUE} if you
#'   want to wipe the slate clean and re-authenticate with the same or different
#'   Google account.
#'
#' @export
gs_auth <- function(new_user = FALSE) {

  if(new_user && file.exists(".httr-oauth")) {
    message("Removing old credentials ...")
    file.remove(".httr-oauth")
  }

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

  # store user information in .state$user
  get_user_info()
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

#' Retrieve User data
#'
#' Store user name, email address and datetime of request in environment
#' variable .state$user
#'
#' @keywords internal
get_user_info <- function() {
  req <- gdrive_GET("https://www.googleapis.com/drive/v2/about")

  .state$user$name <- req$content$name
  .state$user$emailAddress <- req$content$user$emailAddress

  .state$user$datetime <- req$date
}

#' Print information about authorized user
#'
#' Display information about a user that has been authorized via
#' \code{authorize}: the name of the user, the Google account of the user, the
#' date-time of authorization for the current session, date-time of access
#' token expiry, and the validity of the current access token.
#'
#' @export
#' @examples
#' \dontrun{
#' gs_user()
#' }
#'
#' @export
gs_user <- function() {

  if(is.null(.state$token)) {
    message("Credentials were not found in this session.")

    if(file.exists(".httr-oauth")) {
      stop(paste(".httr-oauth found in the current working directory.",
                 "Run authorize() to use the",
                 "credentials cached in .httr-oauth for this session."))
    } else {
      stop(paste(".httr-oauth not found in the current working directory.",
                 "Run authorize() to obtain credentials."))
    }

  } else {

    token <- .state$token
    token_ok <- token$validate()

    sprintf("User: %s\n", .state$user$name) %>% cat()
    sprintf("Google account: %s\n", .state$user$emailAddress) %>% cat()
    # time when authorize() is run to store token in env
    sprintf("Date-time of session authorization: %s\n",
            .state$user$datetime) %>% cat()
    sprintf("Date-time of access token expiry: %s\n",
            file.info(".httr-oauth")$mtime + 3600) %>% cat()
    if(token_ok) {
      message("Access token is valid.")
    } else {
      message(paste("Access token has expired and will be auto-refreshed."))
    }
  }
}
