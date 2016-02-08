#' Retrieve Google user data
#'
#' @return a list
#'
#' @keywords internal
google_user <- function() {

  ## require pre-existing token, to avoid recursion that would arise if
  ## gdrive_GET() called gs_auth()
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {

    ## docs here
    ## https://developers.google.com/drive/v2/reference/about
    req <- gdrive_GET("https://www.googleapis.com/drive/v2/about")

    user_stuff <- req$content$user
    list(displayName = user_stuff$displayName,
         emailAddress = user_stuff$emailAddress,
         date = req$headers$date %>% httr::parse_http_date())

  } else {

    NULL

  }

}

#' Retrieve information about authorized user
#'
#' Display information about a user that has been authorized via \code{gs_auth}:
#' the user's display name, email, the date-time of info lookup, and the
#' validity of the current access token. This is a subset of the information
#' available from
#' \href{https://developers.google.com/drive/v2/reference/about/get}{the "about"
#' endpoint} of the Drive API.
#'
#' @template verbose
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

  if(token_exists(verbose) && is_legit_token(.state$token)) {

    token <- .state$token

    token_valid <- token$validate()

    ret <- list(
      displayName = .state$user$displayName,
      emailAddress = .state$user$emailAddress,
      date = .state$user$date,
      token_valid = token_valid,
      peek_acc = paste(stringr::str_sub(token$credentials$access_token,
                                        end = 5),
                       stringr::str_sub(token$credentials$access_token,
                                        start = -5), sep = "..."),
      peek_ref = paste(stringr::str_sub(token$credentials$refresh_token,
                                        end = 5),
                       stringr::str_sub(token$credentials$refresh_token,
                                        start = -5), sep = "..."))

    if(verbose) {
      sprintf("          displayName: %s",  ret$displayName) %>% message()
      sprintf("         emailAddress: %s", ret$emailAddress) %>% message()
      sprintf("                 date: %s",
              format(ret$date, usetz = TRUE)) %>% message()
      sprintf("         access token: %s",
              if(token_valid) "valid" else "expired, will auto-refresh") %>%
        message()
      sprintf(" peek at access token: %s", ret$peek_acc) %>% message()
      sprintf("peek at refresh token: %s", ret$peek_ref) %>% message()

    }

  } else {

    if(verbose) message("No user currently authorized.")
    ret <- NULL

  }

  invisible(ret)

}
