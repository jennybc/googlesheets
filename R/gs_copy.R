#' Copy an existing spreadsheet
#'
#' You can copy a spreadsheet that you own or a sheet owned by a third party
#' that has been made accessible via the sharing dialog options. This function
#' calls the \href{https://developers.google.com/drive/v2/reference/}{Google
#' Drive API}.
#'
#' @template ss_from
#' @param to character string giving the new title of the sheet; if \code{NULL},
#'   then the copy will be titled "Copy of ..."
#' @template verbose
#'
#' @examples
#' \dontrun{
#' # copy the Gapminder example sheet
#' gap_ss <- gs_copy(gs_gap(), to = "Gapminder_copy")
#' gap_ss
#' gs_delete(gap_ss)
#' }
#'
#' @export
gs_copy <- function(from, to = NULL, verbose = TRUE) {

  stopifnot(inherits(from, "googlesheet"))

  key <- gs_get_alt_key(from)
  if (is.null(to)) {
    to <- paste("Copy of", from$sheet_title)
  }

  current_sheets <- gs_ls(regex = to, fixed = TRUE, verbose = FALSE)

  if (!is.null(current_sheets) && verbose) {
    wpf(paste("At least one sheet matching \"%s\" already exists, so you",
              "may\nneed to identify by key, not title, in future."), to)
  }

  the_url <- file.path(.state$gd_base_url_files_v2, key, "copy")
  the_body <- list("title" = to)
  req <-
    httr::POST(the_url, google_token(), encode = "json", body = the_body) %>%
    httr::stop_for_status()
  rc <- content_as_json_UTF8(req)

  new_ss <- try(gs_key(rc$id, verbose = FALSE), silent = TRUE)

  cannot_find_sheet <- inherits(new_ss, "try-error")

  if (cannot_find_sheet) {
    if (verbose) {
      message("Cannot verify whether spreadsheet copy was successful.")
    }
    return(invisible(NULL))
  }

  ## this looks crazy but unless I sleep for several seconds, new_ss reflects
  ## the default "copy of ..." title instead of sheet title requested in `to
  ## =`
  new_ss$sheet_title <- to
  if (verbose) {
    mpf("Successful copy! New sheet is titled \"%s\".", new_ss$sheet_title)
  }
  new_ss %>%
    invisible()

  }
