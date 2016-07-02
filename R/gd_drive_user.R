#' Retrieve Google Drive user data
#'
#' Unexported workhorse function.
#'
#' @template return-drive_user
#'
#' @keywords internal
drive_user <- function() {

  ## require pre-existing token, to avoid recursion that would arise if
  ## this function called gs_auth()
  if (!token_available(verbose = FALSE)) {
    return(NULL)
  }

  ## https://developers.google.com/drive/v2/reference/about
  url <- file.path(.state$gd_base_url, "drive/v2/about")
  req <- rGET(url, google_token()) %>%
    httr::stop_for_status()
  rc <- content_as_json_UTF8(req)
  rc$date <- req$headers$date %>% httr::parse_http_date()
  structure(rc, class = c("drive_user", "list"))

}

#' Retrieve information about the current Google user
#'
#' Retrieve information about the Google user that has authorized
#' \code{\link{googlesheets}} to call the Drive and Sheets APIs on their behalf.
#' As long as \code{full = FALSE} (the default), only the most useful subset of
#' the information available from
#' \href{https://developers.google.com/drive/v2/reference/about/get}{the "about"
#' endpoint} of the Drive API is returned. This is also the information exposed
#' in the print method:
#'
#' \itemize{
#' \item User's display name
#' \item User's email
#' \item Date-time of user info lookup
#' \item User's permission ID
#' \item User's root folder ID
#' }
#'
#' When \code{full = TRUE}, all information provided by the API is returned.
#'
#' @param full Logical, indicating whether to return selected (\code{FALSE},
#' the default) or full (\code{TRUE}) user information.
#' @template verbose
#'
#' @template return-drive_user
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' ## these are synonyms: gd = Google Drive, gs = Google Sheets
#' gd_user()
#' gs_user()
#' }
#'
#' @export
gd_user <- function(full = FALSE, verbose = TRUE) {

  if (!token_available(verbose = verbose) || !is_legit_token(.state$token)) {
    if (verbose) {
      message("To retrieve user info, please call gs_auth() explicitly.")
    }
    return(invisible(NULL))
  }

  user_info <- drive_user()

  if (!full) {
    keepers <- c("user", "date", "rootFolderId", "permissionId")
    user_info <- structure(user_info[keepers], class = c("drive_user", "list"))
  }

  user_info

}

#' @export
#' @rdname gd_user
gs_user <- gd_user

#' @export
print.drive_user <- function(x, ...) {
  cpf("          displayName: %s", x$user$displayName)
  cpf("         emailAddress: %s", x$user$emailAddress)
  cpf("                 date: %s", format(x$date, usetz = TRUE))
  cpf("         permissionId: %s", x$permissionId)
  cpf("         rootFolderId: %s", x$rootFolderId)
  invisible(x)
}
