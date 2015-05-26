#' Build the Google URL to authorize \code{googlesheets} in Shiny
#' 
#' This is the first step in the authorization sequence. Form the Google URL
#' that redirects the user to Google's authorization screen. Once a user 
#' authenticates, the response in the form of an authorization code is sent 
#' to the \code{redirect_uri} in which \code{gs_shiny_get_token} uses to 
#' exchange for an access token.
#' 
#' Set client ID and Secret, and redirect uri specific to your project by:
#' options("googlesheets.shiny.client_id" = MY_CLIENT_ID)
#' options("googlesheets.shiny.client_secret" = MY_CLIENT_SECRET)
#' options("googlesheets.shiny.redirect_uri" = MY_REDIRECT_URI)
#' 
#' Based on Google Developers' guide to \href{https://developers.google.com/ide
#' ntity/protocols/OAuth2WebServer}{Using OAuth2.0 for Web Server Applications}.
#' 
#' @seealso gs_shiny_get_token
#' 
#' @export
gs_shiny_form_url <- function() {
  
  client_id <- getOption("googlesheets.shiny.client_id")
  redirect_uri <- getOption("googlesheets.shiny.redirect_uri")
  
  scope_list <- paste("https://spreadsheets.google.com/feeds", 
                      "https://docs.google.com/feeds", sep = " ")
  
  url <- httr::modify_url(
    httr::oauth_endpoints("google")$authorize,
    query = list(response_type = "code",
                 client_id = client_id,
                 redirect_uri = redirect_uri,
                 scope = scope_list, 
                 state = "securitytoken",
                 access_type = "online", # set to offline to return refresh token
                 approval_prompt = "auto")) # only have to approve once
  
  url
}


#' Exchange authorization code for an access token
#' 
#' Use the authorization code in the return URL to exchange for an access_token 
#' by making an HTTPS POST. 
#' 
#' This function behaves similarly to gs_auth(). A token object gets stored in 
#' an environment variable and retrieved when making calls to the Google Sheets 
#' and Drive APIs. 
#' 
#' @param auth_code authorization code returned by Google that appears in URL
#' 
#' @export
gs_shiny_get_token <- function(auth_code) {
  
  client_id <- getOption("googlesheets.shiny.client_id")
  client_secret <- getOption("googlesheets.shiny.client_secret")
  redirect_uri <- getOption("googlesheets.shiny.redirect_uri")
  
  googlesheets_app <-
    httr::oauth_app("google", key = client_id, secret = client_secret)
  
  scope_list <- c("https://spreadsheets.google.com/feeds",
                  "https://docs.google.com/feeds")
  
  req <- 
    httr::POST("https://accounts.google.com/o/oauth2/token", 
               body = list(code = auth_code,
                           client_id = client_id,
                           client_secret = client_secret,
                           redirect_uri = redirect_uri,
                           grant_type = "authorization_code"), verbose = TRUE)
  
  # only access_token, access_type, expires_in is returned
  token <- httr::content(req, type = "application/json")
  
  # Create a Token2.0 object consistent with the token obtained from gs_auth()
  token_formatted <- 
    httr::Token2.0$new(app = googlesheets_app, 
                       endpoint = httr::oauth_endpoints("google"), 
                       credentials = list(access_token = token$access_token, 
                                          token_type = token$token_type, 
                                          expires_in = token$expires_in), 
                       params = list(scope = scope_list, type = NULL, 
                                     use_oob = FALSE, as_header = TRUE), 
                       cache_path = FALSE)
  
  .state$token <- token_formatted
  .state$user <- google_user()
  .state$token
}
