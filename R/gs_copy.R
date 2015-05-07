#' Make a copy of an existing spreadsheet
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
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- gs_copy(gs_key(gap_key), to = "Gapminder_copy")
#' gap_ss
#' }
#'
#' @export
gs_copy <- function(from, to = NULL, verbose = TRUE) {

  stopifnot(inherits(from, "googlesheet"))

  key <- gs_get_alt_key(from)
  title <- from$sheet_title

  the_body <- list("title" = to)

  the_url <-
    paste("https://www.googleapis.com/drive/v2/files", key, "copy", sep = "/")

  req <- gdrive_POST(the_url, body = the_body)

  new_title <- httr::content(req)$title

  new_ss <- try(gs_title(new_title, verbose = FALSE), silent = TRUE)

  cannot_find_sheet <- inherits(new_ss, "try-error")

  if(verbose) {
    if(cannot_find_sheet) {
      message("Cannot verify whether spreadsheet copy was successful.")
    } else {
      message(sprintf("Successful copy! New sheet is titled \"%s\".",
                      new_ss$sheet_title))
    }
  }

  if(cannot_find_sheet) {
    invisible(NULL)
  } else {
    new_ss %>%
      invisible()
  }

}
