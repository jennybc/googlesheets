#' Create a new spreadsheet
#'
#' Create a new (empty) spreadsheet in your Google Drive. The new sheet will
#' contain 1 default worksheet titled "Sheet1". This function
#' calls the \href{https://developers.google.com/drive/v2/reference/}{Google
#' Drive API}.
#'
#' @param title the title for the new sheet
#' @param verbose logical; do you want informative message?
#'
#' @return a \code{\link{googlesheet}} object
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' foo
#' }
#'
#' @export
gs_new <- function(title = "my_sheet", verbose = TRUE) {

  ## TO DO? warn if sheet with same title alredy exists?
  ## right now we proceed quietly, because sheet is identified by key

  the_body <- list(title = title,
                   mimeType = "application/vnd.google-apps.spreadsheet")

  req <-
    gdrive_POST(url = "https://www.googleapis.com/drive/v2/files",
                body = the_body)

  new_sheet_key <- httr::content(req)$id
  ## I set verbose = FALSE here because it seems weird to message "Spreadsheet
  ## identified!" in this context, esp. to do so *before* message confirming
  ## creation
  ss <- gs_key(new_sheet_key, verbose = FALSE)

  if(verbose) {
    message(sprintf("Sheet \"%s\" created in Google Drive.", ss$sheet_title))
  }

  ss %>%
    invisible()

}
