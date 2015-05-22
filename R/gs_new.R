#' Create a new spreadsheet
#'
#' Create a new spreadsheet in your Google Drive. It will contain a single
#' worksheet which, by default, will [1] have 1000 rows and 26 columns, [2]
#' contain no data, and [3] be titled "Sheet1". Use the \code{ws},
#' \code{row_extent}, \code{col_extent}, and \code{...} arguments to give the
#' worksheet a different title or extent or to populate it with some data. This
#' function calls the
#' \href{https://developers.google.com/drive/v2/reference/}{Google Drive API} to
#' create the sheet and edit the worksheet name or extent. If you provide data
#' for the sheet, then this function also calls the
#' \href{https://developers.google.com/google-apps/spreadsheets/}{Google Sheets
#' API}.
#'
#' @param title the title for the new spreadsheet
#' @param ws_title the title for the new, sole worksheet; if unspecified, the
#'   Google Sheets default is "Sheet1"
#' @param row_extent integer for new row extent; if unspecified, the Google
#'   Sheets default is 1000
#' @param col_extent integer for new column extent; if unspecified, the Google
#'   Sheets default is 26
#' @param verbose logical; do you want informative message?
#'
#' @return a \code{\link{googlesheet}} object
#'
#' @examples
#' \dontrun{
#' foo <- gs_new()
#' foo
#' gs_delete(foo)
#'
#' foo <- gs_new("foo", ws_title = "numero uno", 4, 15)
#' foo
#' gs_delete(foo)
#' }
#'
#' @export
gs_new <- function(title = "my_sheet", ws_title = NULL,
                   row_extent = NULL, col_extent = NULL,
                   verbose = TRUE) {

  ## TO DO? warn if sheet with same title alredy exists?
  ## right now we proceed quietly, because sheet is identified by key

  the_body <- list(title = title,
                   mimeType = "application/vnd.google-apps.spreadsheet")

  req <-
    gdrive_POST(url = "https://www.googleapis.com/drive/v2/files",
                body = the_body)

  ss <- httr::content(req)$id %>%
    gs_key(verbose = FALSE)

  if(inherits(ss, "googlesheet")) {
    if(verbose) {
      message(sprintf("Sheet \"%s\" created in Google Drive.", ss$sheet_title))
    }
  } else {
    stop(sprintf("Unable to create Sheet \"%s\" in Google Drive.", title))
  }

  if(!is.null(ws_title) || !is.null(row_extent) || !is.null(col_extent)) {
    ss <- ss %>%
      gs_ws_modify(from = 1, to = ws_title,
                   new_dim = c(row_extent = row_extent,
                               col_extent = col_extent), verbose = FALSE)
    if(verbose) {
      if(ws_title %in% ss$ws$ws_title) {
        sprintf("Worksheet \"%s\" renamed to \"%s\".", "Sheet1", ws_title) %>%
          message()
      } else {
        sprintf(paste("Cannot verify whether worksheet \"%s\" was",
                      "renamed to \"%s\"."), "Sheet1", ws_title) %>%
          message()
      }
      message(sprintf("Worksheet dimensions: %d x %d.",
                      ss$ws$row_extent, ss$ws$col_extent))
    }
  }

  ss %>%
    invisible()

}
