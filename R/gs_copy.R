#' Copy of an existing spreadsheet
#'
#' You can copy a spreadsheet that you own or a sheet owned by a third party
#' that has been made accessible via the sharing dialog options. This function
#' calls the \href{https://developers.google.com/drive/v2/reference/}{Google
#' Drive API}.
#'
#' @param from a \code{\link{googlesheet}} object, i.e. a registered Google
#'   sheet
#' @param to character string giving the new title of the sheet; if \code{NULL},
#'   then the copy will be titled "Copy of ..."
#' @param verbose logical; do you want informative message?
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

  the_body <- list("title" = to)

  the_url <-
    paste("https://www.googleapis.com/drive/v2/files", key, "copy", sep = "/")

  req <- gdrive_POST(the_url, body = the_body)

  new_key <- httr::content(req)$id

  new_ss <- try(gs_key(new_key, verbose = FALSE), silent = TRUE)

  cannot_find_sheet <- inherits(new_ss, "try-error")

  if(cannot_find_sheet) {
    if(verbose) {
      message("Cannot verify whether spreadsheet copy was successful.")
    }
    invisible(NULL)
  } else {
    ## this looks crazy but unless I sleep for several seconds, new_ss reflects
    ## the default "copy of ..." title instead of sheet title requested in `to
    ## =`
    new_ss$sheet_title <- to
    if(verbose) {
      message(sprintf("Successful copy! New sheet is titled \"%s\".",
                      new_ss$sheet_title))
    }
    new_ss %>%
      invisible()
  }

}
