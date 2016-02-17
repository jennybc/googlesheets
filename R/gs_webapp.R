#' Build URL for authentication
#'
#' Build the Google URL that \code{googlesheets} needs to direct users to in
#' order to authenticate in a Web Server Application. This function is designed
#' for use in Shiny apps. In contrast, the default authorization sequence in
#' \code{googlesheets} is appropriate for a user working directly with R on a
#' local computer, where the default handshakes between the local computer and
#' Google work just fine. The first step in the Shiny-based workflow is to form
#' the Google URL where the user can authenticate him or herself with Google.
#' After success, the response, in the form of an authorization code, is sent to
#' the \code{redirect_uri} (see below) which \code{\link{gs_webapp_get_token}}
#' uses to exchange for an access token. This token is then stored in the usual
#' manner for this package and used for subsequent API requests.
#'
#' That was the good news. The bad news is you'll need to use the
#' \href{https://console.developers.google.com}{Google Developers Console} to
#' \strong{obtain your own client ID and secret and declare the
#' \code{redirect_uri} specific to your project}. Inform \code{googlesheets} of
#' this information by providing as function arguments or by defining these
#' options. For example, you can put lines like this into a Project-specific
#' \code{.Rprofile} file:
#'
#' options("googlesheets.webapp.client_id" = MY_CLIENT_ID)
#' options("googlesheets.webapp.client_secret" = MY_CLIENT_SECRET)
#' options("googlesheets.webapp.redirect_uri" = MY_REDIRECT_URI)
#'
#' Based on Google Developers' guide to
#' \href{https://developers.google.com/identity/protocols/OAuth2WebServer}{Using
#' OAuth2.0 for Web Server Applications}.
#'
#' @param client_id client id obtained from Google Developers Console
#' @param redirect_uri where the response is sent, should be one of the
#'   redirect_uri values listed for the project in Google's Developer Console,
#'   must match exactly as listed including any trailing '/'
#' @param access_type either "online" (no refresh token) or "offline" (refresh
#'   token), determines whether a refresh token is returned in the response
#' @param approval_prompt either "force" or "auto", determines whether the user
#'   is reprompted for consent, If set to "auto", then the user only has to see
#'   the consent page once for the first time through the authorization
#'   sequence. If set to "force" then user will have to grant consent everytime
#'   even if they have previously done so.
#'
#' @seealso \code{\link{gs_webapp_get_token}}
#'
#' @export
gs_webapp_auth_url <-
  function(client_id = getOption("googlesheets.webapp.client_id"),
           redirect_uri = getOption("googlesheets.webapp.redirect_uri"),
           access_type = "online",
           approval_prompt = "auto") {

    scope_list <- paste("https://spreadsheets.google.com/feeds",
                        "https://docs.google.com/feeds")

    url <- httr::modify_url(
      httr::oauth_endpoints("google")$authorize,
      query = list(response_type = "code",
                   client_id = client_id,
                   redirect_uri = redirect_uri,
                   scope = scope_list,
                   state = "securitytoken",
                   access_type = access_type,
                   approval_prompt = approval_prompt))

    url
  }


#' Exchange authorization code for an access token
#'
#' Exchange the authorization code in the URL returned by
#' \code{\link{gs_webapp_auth_url}} to get an access_token. This function plays
#' a role similar to \code{\link{gs_auth}}, but in a Shiny-based workflow: it
#' stores a token object in an internal environment, where it can be retrieved
#' for making calls to the Google Sheets and Drive APIs. Read the documentation
#' for \code{\link{gs_webapp_auth_url}} for more details on OAuth2 within Shiny.
#'
#' @inheritParams gs_webapp_auth_url
#' @param client_secret client secret obtained from Google Developers Console
#' @param auth_code authorization code returned by Google that appears in URL
#'
#' @seealso \code{\link{gs_webapp_auth_url}}
#'
#' @export
gs_webapp_get_token <-
  function(auth_code,
           client_id = getOption("googlesheets.webapp.client_id"),
           client_secret = getOption("googlesheets.webapp.client_secret"),
           redirect_uri = getOption("googlesheets.webapp.redirect_uri")) {

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
    stop_for_content_type(req, "application/json; charset=utf-8")
    # content of req will contain access_token, token_type, expires_in
    token <- httr::content(req, type = "application/json")

    # Create a Token2.0 object consistent with the token obtained from gs_auth()
    token_formatted <-
      httr::Token2.0$new(app = googlesheets_app,
                         endpoint = httr::oauth_endpoints("google"),
                         credentials = list(access_token = token$access_token,
                                          token_type = token$token_type,
                                          expires_in = token$expires_in,
                                          refresh_token = token$refresh_token),
                         params = list(scope = scope_list, type = NULL,
                                       use_oob = FALSE, as_header = TRUE),
                         cache_path = FALSE)

    .state$token <- token_formatted
    .state$user <- google_user()
    .state$token
  }
