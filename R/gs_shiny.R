#' Form the URL to use to authenticate a user 
#' 
#' Once a user authenticates, the response is sent to the \code{redirect_uri} 
#' and contains an authorization code which \code{shiny_get_token} uses to 
#' exchange for an access token.
#' 
#' @param client_id application client id
#' @param client secret application client secret
#' @param redirect_uri redirect uri (shiny app url or localhost for local testing)
#' @export
gs_shiny_form_url <- function(redirect_uri) {
  
  client_id <- getOption("googlesheets.shiny.client_id")
  
  scope_list <- paste("https://spreadsheets.google.com/feeds", 
                      "https://docs.google.com/feeds", sep = " ")
  
  url <- httr::modify_url("https://accounts.google.com/o/oauth2/auth",
                          query = list(scope = scope_list, 
                                       state = "securitytoken",
                                       redirect_uri = redirect_uri,
                                       response_type = "code", 
                                       client_id = client_id,
                                       approval_prompt = "auto", # only have to approve once
                                       access_type = "online"))
  url
}


#' Exchange authorization code for an access token
#' 
#' Use the authorization code in the return URL to exchange for an access_token. 
#' 
#' @param auth_code authorization code returned by Google that appears in URL
#' @param client_id application client id
#' @param client secret application client secret
#' @param redirect_uri redirect uri (shiny app url or localhost for local testing)
#'
#' @return A list containing access_token, access_type, expires_in.
#' @export
gs_shiny_get_token <- function(auth_code, redirect_uri) {
  req <- 
    httr::POST("https://accounts.google.com/o/oauth2/token", 
               body = list(code = auth_code,
                           client_id = getOption("googlesheets.shiny.client_id"),
                           client_secret = getOption("googlesheets.shiny.client_secret"),
                           redirect_uri = redirect_uri,
                           grant_type = "authorization_code"), verbose = TRUE)
  
  # only access_token, access_type, expires_in is returned
  token <- httr::content(req, type = "application/json")
  
  scope_list <- c("https://spreadsheets.google.com/feeds",
                  "https://docs.google.com/feeds")
  
  googlesheets_app <-
    httr::oauth_app("google",
                    key = getOption("googlesheets.shiny.client_id"),
                    secret = getOption("googlesheets.shiny.client_secret"))
  
  token_formatted <- httr::Token2.0$new(app = googlesheets_app, 
                                        endpoint = httr::oauth_endpoints("google"), 
               credentials = list(access_token = token$access_token, 
                                  token_type = token$token_type, 
                                  expires_in = token$expires_in), 
               params = list(scope = scope_list, 
                             type = NULL, use_oob = FALSE, as_header = TRUE), 
               cache_path = FALSE)
  
  .state$token <- token_formatted
  .state$user <- google_user()
  .state$token
}
