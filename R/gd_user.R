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

#' Retrieve information about the current Google user
#'
#' Display information about the Google user that has authorized
#' \code{\link{googlesheets}} to call the Drive and Sheets APIs on their behalf.
#' Returns and prints the user's display name, email, the date-time of info
#' lookup, and the validity of the current access token. This is a subset of the
#' information available from
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
gd_user <- function(verbose = TRUE) {

  if(token_exists(verbose = verbose) && is_legit_token(.state$token)) {

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

    ret <- NULL

  }

  invisible(ret)

}

#' @export
#' @rdname gd_user
gs_user <- gd_user
