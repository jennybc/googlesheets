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
authorize <- function(new_user = FALSE) {

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

}


#' Retrieve Google token from environment
#'
#' Get token if it's previously stored, else prompt user to get one.
#'
#' @keywords internal
get_google_token <- function() {

  if(is.null(.state$token)) {
    authorize()
  }

  httr::config(token = .state$token)

}
