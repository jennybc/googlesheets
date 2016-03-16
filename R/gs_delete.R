#' Delete a spreadsheet
#'
#' Move a spreadsheet to trash on Google Drive. You must own a sheet in order to
#' move it to the trash. If you try to delete a sheet you do not own, a 403
#' Forbidden HTTP status code will be returned; third party spreadsheets can
#' only be moved to the trash manually in the web browser (which only removes
#' them from your Google Sheets home screen, in any case). If you trash a
#' spreadsheet that is shared with others, it will no longer appear in any of
#' their Google Drives. If you delete something by mistake, remain calm, and
#' visit the \href{https://drive.google.com/drive/#trash}{trash in Google
#' Drive}, find the sheet, and restore it.
#'
#' @template ss
#' @template verbose
#'
#' @return logical indicating if the deletion was successful
#'
#' @seealso \code{\link{gs_grepdel}} and \code{\link{gs_vecdel}} for handy
#'   wrappers that help you delete sheets by title, with the ability to delete
#'   multiple sheets at once
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("new_sheet")
#' gs_delete(foo)
#' }
#'
#' @export
gs_delete <- function(ss, verbose = TRUE) {

  if (!inherits(ss, "googlesheet")) {
    spf("Input must be a 'googlesheet'.\n",
        "Trying to delete by title? See gs_grepdel() and gs_vecdel().")
  }

  key <- gs_get_alt_key(ss)
  the_url <- file.path(.state$gd_base_url_files_v2, key)

  req <- httr::DELETE(the_url, google_token()) %>%
    httr::stop_for_status()
  status <- httr::status_code(req)

  if (verbose) {
    if (status == 204L) {
      mpf("Success. \"%s\" moved to trash in Google Drive.", ss$sheet_title)
    } else {
      mpf("Oops. \"%s\" was NOT deleted.", ss$sheet_title)
    }
  }

  if(status == 204L) invisible(TRUE) else invisible(FALSE)

}

#' Delete several spreadsheets at once by title
#'
#' These functions violate the general convention of operating on a registered
#' Google sheet, i.e. on a \code{\link{googlesheet}} object. But the need to
#' delete a bunch of sheets at once, based on a vector of titles or on a regular
#' expression, came up so much during development and testing, that it seemed
#' wise to package this as a function.
#'
#' @examples
#' \dontrun{
#' sheet_title <- c("cat", "catherine", "tomCAT", "abdicate", "FLYCATCHER")
#' ss <- lapply(paste0("TEST-", sheet_title), gs_new)
#' # list, for safety!, then delete 'TEST-abdicate' and 'TEST-catherine'
#' gs_ls(regex = "TEST-[a-zA-Z]*cat[a-zA-Z]+$")
#' gs_grepdel(regex = "TEST-[a-zA-Z]*cat[a-zA-Z]+$")
#'
#' # list, for safety!, then delete the rest,
#' # i.e. 'TEST-cat', 'TEST-tomCAT', and 'TEST-FLYCATCHER'
#' gs_ls(regex = "TEST-[a-zA-Z]*cat[a-zA-Z]*$", ignore.case = TRUE)
#' gs_grepdel(regex = "TEST-[a-zA-Z]*cat[a-zA-Z]*$", ignore.case = TRUE)
#'
#' ## using gs_vecdel()
#' sheet_title <- c("cat", "catherine", "tomCAT", "abdicate", "FLYCATCHER")
#' ss <- lapply(paste0("TEST-", sheet_title), gs_new)
#' # delete two of these sheets
#' gs_vecdel(c("TEST-cat", "TEST-abdicate"))
#' # see? they are really gone, but the others remain
#' gs_ls(regex = "TEST-[a-zA-Z]*cat[a-zA-Z]*$", ignore.case = TRUE)
#' # delete the remainder
#' gs_vecdel(c("TEST-FLYCATCHER", "TEST-tomCAT", "TEST-catherine"))
#' # see? they are all gone now
#' gs_ls(regex = "TEST-[a-zA-Z]*cat[a-zA-Z]*$", ignore.case = TRUE)
#' }
#'
#' @param regex character; a regular expression; sheets whose titles match will
#'   be deleted
#' @param ... optional arguments to be passed to \code{\link{grep}} when
#'   matching \code{regex} to sheet titles
#' @template verbose
#'
#' @export
gs_grepdel <- function(regex, ..., verbose = TRUE) {

  stopifnot(is.character(regex))

  delete_me <- gs_ls(regex, ..., verbose = verbose)

  if(is.null(delete_me)) {
    invisible(NULL)
  } else {
    lapply(delete_me$sheet_key, function(x) {
      gs_delete(gs_key(x, verbose = verbose), verbose = verbose)
    }) %>%
      unlist()
  }

}

#' @rdname gs_grepdel
#' @param vec character vector of sheet titles to delete
#' @export
gs_vecdel <- function(vec, verbose = TRUE) {

  stopifnot(is.character(vec))

  delete_me <- gs_ls(verbose = FALSE) %>%
    dplyr::filter_(~ sheet_title %in% vec)

  if(nrow(delete_me)) {
    lapply(delete_me$sheet_key, function(x) {
      gs_delete(gs_key(x, verbose = verbose), verbose = verbose)
    }) %>%
      unlist()
  } else {
    invisible(NULL)
  }

}
