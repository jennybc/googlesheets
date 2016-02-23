#' Retrieve Google user data
#'
#' @return a list
#'
#' @keywords internal
google_user <- function() {

  ## require pre-existing token, to avoid recursion that would arise if
  ## this function called gs_auth()
  if (token_available(verbose = FALSE)) {

    ## https://developers.google.com/drive/v2/reference/about
    url <- file.path(.state$gd_base_url, "drive/v2/about")
    req <- httr::GET(url, google_token()) %>%
      httr::stop_for_status()
    rc <- content_as_json_UTF8(req)

    list(displayName = rc$user$displayName,
         emailAddress = rc$user$emailAddress,
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

  if(token_available(verbose = verbose) && is_legit_token(.state$token)) {

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
      mpf("          displayName: %s",  ret$displayName)
      mpf("         emailAddress: %s", ret$emailAddress)
      mpf("                 date: %s", format(ret$date, usetz = TRUE))
      mpf("         access token: %s",
          if(token_valid) "valid" else "expired, will auto-refresh")
      mpf(" peek at access token: %s", ret$peek_acc)
      mpf("peek at refresh token: %s", ret$peek_ref)
    }

  } else {

    ret <- NULL

  }

  invisible(ret)

}

#' @export
#' @rdname gd_user
gs_user <- gd_user
