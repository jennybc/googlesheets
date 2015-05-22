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
shiny_get_url <- function(client_id, 
                          client_secret,
                          redirect_uri) {
  
  scope_list <- paste("https://spreadsheets.google.com/feeds", 
                      "https://docs.google.com/feeds", sep = " ")
  
  url <- httr::modify_url("https://accounts.google.com/o/oauth2/auth",
                          query = list(scope = scope_list, 
                                       state = "securitytoken",
                                       redirect_uri = redirect_uri,
                                       response_type = "code", 
                                       client_id = client_id,
                                       approval_prompt = "auto",
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
shiny_get_token <- function(auth_code, client_id, client_secret, redirect_uri) {
  req <- 
    httr::POST("https://accounts.google.com/o/oauth2/token", 
               body = list(code = auth_code,
                           client_id = client_id,
                           client_secret = client_secret,
                           redirect_uri = redirect_uri,
                           grant_type = "authorization_code"), verbose = TRUE)
  
  # only access_token, access_type, expires_in is returned
  token_data <- httr::content(req, type = "application/json")
  
  .state$shiny_access_token <- token_data
  
  token_data
}
