# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authorize user using Oauth2.0 Credentials
#'
#' User will be directed to web browser and asked to sign into their Google
#' account and grant gspreadr access permission to user data for Google 
#' Spreadsheets and Google Drive. User credentials will be cached in .httr-oauth
#' in the current working directory.
#'
#' This method follows the demo described at:
#' \url{https://github.com/hadley/httr/blob/master/demo/oauth2-google.r}
#' @param new_user set to \code{TRUE} if you want to authenticate a different
#' google account
#' @export
authorize <- function(new_user = FALSE) {
  
  if(new_user & file.exists(".httr-oauth")) {
    message("Removing old credentials ...")
    file.remove(".httr-oauth")
  }
  
  scope_list <- paste("https://spreadsheets.google.com/feeds", 
                      "https://docs.google.com/feeds")
  
  client_id <- getOption("gspreadr.client_id")
  client_secret <- getOption("gspreadr.client_secret")
  
  gspreadr_app <- httr::oauth_app("google", client_id, client_secret)
  
  google_token <-
    httr::oauth2.0_token(httr::oauth_endpoints("google"), gspreadr_app,
                         scope = scope_list, cache = TRUE)
  
  # check for validity so error is found before making requests
  # shouldn't happen if id and secret don't change
  if("invalid_client" %in% unlist(google_token$credentials))
    message("Authorization error. Please check client_id and client_secret.")
  
  stopifnot(inherits(google_token, "Token2.0"))
  
  .state$token <- google_token
  
}


#' Retrieve Google token from environment
#' 
#' Get token if it's previously stored, else prompt user to get one.
#'
get_google_token <- function() {
  
  if(is.null(.state$token)) {  
    authorize()
  }
  
  token <- httr::config(token = .state$token)
  
}
