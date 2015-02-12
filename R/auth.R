# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Authorize user using ClientLogin
#'
#' Authorize user using email and password.
#'
#' @param email User's email.
#' @param passwd User's password.
#'
#' This method is using API as described at:
#' \url{https://developers.google.com/accounts/docs/AuthForInstalledApps}
#'
#' @export
login <- function(email, passwd) 
{
  service <- "wise"
  account_type <- "HOSTED_OR_GOOGLE"
  the_url <- "https://www.google.com/accounts/ClientLogin"
  
  req <- httr::POST(the_url, body = list("accountType" = account_type,
                                         "Email" = email,
                                         "Passwd" = passwd,
                                         "service" = service))
  
  gsheets_check(req)
  
  # SID, LSID not active, extract auth token
  token <- sub(".*Auth=", "", httr::content(req))
  token <- sub("\n", "", token)
  auth_header <- paste0("GoogleLogin auth=", token)
  
  .state$token <- auth_header
}

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
authorize <- function(new_user = FALSE) 
{
  if(new_user & file.exists(".httr-oauth")) {
    message("Removing old credentials ...")
    system("rm .httr-oauth")
  }
  
  scope_list <- paste("https://spreadsheets.google.com/feeds", 
                      "https://docs.google.com/feeds")
  
  client_id <- "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com"
  client_secret <- "iWPrYg0lFHNQblnRrDbypvJL"
  
  gspreadr_app <- httr::oauth_app("google", client_id, client_secret)
  
  google_token <-
    httr::oauth2.0_token(httr::oauth_endpoints("google"), gspreadr_app,
                         scope = scope_list, cache = TRUE)
  
  check_token(google_token)
  
  .state$token <- google_token
}


#' Check status of http response
#' 
#' Google returns status 200 (success) or 403 (failure), show error msg if 403.
#' 
#' @param req response from \code{\link{gsheets_GET}} request
gsheets_check <- function(req) {
  if(httr::status_code(req) == 403) {
    if(grepl("BadAuthentication", httr::content(req)))
      stop("Incorrect username or password.")
    else
      stop("Unable to authenticate")
  }
}

#' Format token for making request
#' 
#' Check if token is obtained from Google login or oauth2.0 and format it for 
#' making request. Format token as a header (login) or in configuations 
#' (oauth2.0).
#' 
#' @param token Google token
gsheets_auth <- function(token) {
  if(any(class(token) != "character"))
    auth <- httr::config(token = .state$token)
  else 
    auth <- httr::add_headers('Authorization' = .state$token)
}


#' Check Google token for validity
#' 
#' Make sure Google token is good to use upon retrieval so error is found 
#' before making requests. 
#' 
#' @param token Google authorization token
check_token <- function(token) {
  if("invalid_client" %in% unlist(token$credentials))
    message("Authorization error. Please check client_id and client_secret.")
}

#' Retrieve Google token from environment
#' 
#' Get token if it's previously stored, else prompt user to get one.
#'
get_google_token <- function() {
  if(is.null(.state$token)) 
    authorize()
  .state$token
}
