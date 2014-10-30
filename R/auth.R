#' Authorize client using ClientLogin
#'
#' Authorize user using email and password.
#'
#'@param email User's email.
#'@param passwd Password for user's email.
#'@return Object of class client which stores the auth token required for subsequent requests.
#'
#'This method is using API as described at:
#'\url{https://developers.google.com/accounts/docs/AuthForInstalledApps}
#'
#'Authorization token will be stored in http_session object which then gets
#'stored in client object.
#'@export
#'@importFrom httr POST
#'@importFrom httr status_code
#'@importFrom httr content
login <- function(email, passwd) {
  service = "wise"
  account_type = "HOSTED_OR_GOOGLE"
  the_url = "https://www.google.com/accounts/ClientLogin"

  req <- POST(the_url, body = list("accountType" = account_type,
                                   "Email" = email,
                                   "Passwd" = passwd,
                                   "service" = service))

  google_check(req)

  # SID, LSID not active, extract auth token
  token <- sub(".*Auth=", "", content(req))

  auth_header <- paste0("GoogleLogin auth=", token)

  # make http_session object to store token
  session <- http_session()
  session$headers <- auth_header

  # instantiate client object to store credentials
  new_client <- client()
  new_client$auth <- c(email, passwd)
  new_client$http_session <- session

  new_client
}


#' Authorize client using Oauth2.0 Credentials
#'
#' Authorize user using email and password.
#'
#'@return Object of class client which stores the Oauth2.0 token required for subsequent requests.
#'
#'This method is following the demo described at:
#'\url{https://github.com/hadley/httr/blob/master/demo/oauth2-google.r}
#'
#'Authorization token will be stored in client as auth.
#'@export
#'@importFrom httr POST
#'@importFrom httr oauth_app
#'@importFrom httr oauth_endpoints
#'@importFrom httr oauth2.0_token
authorize <- function() {
  SCOPE <- paste("https://spreadsheets.google.com/feeds","https://docs.google.com/feeds")
  CLIENT_ID <- "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com"
  CLIENT_SECRET <- "xsvcER2hCCALoN7A8ww6MaKG"

  gspreadr_app <- oauth_app("google", CLIENT_ID, CLIENT_SECRET)

  google_token <-
    oauth2.0_token(oauth_endpoints("google"), gspreadr_app, scope = SCOPE)

  new_client <- client()
  new_client$auth <- google_token
  new_client
}

