#' Create a new spreadsheet
#'
#' Create a new spreadsheet in your Google Drive. It will contain a single
#' worksheet which, by default, will [1] have 1000 rows and 26 columns, [2]
#' contain no data, and [3] be titled "Sheet1". Use the \code{ws_title},
#' \code{row_extent}, \code{col_extent}, and \code{...} arguments to give the
#' worksheet a different title or extent or to populate it with some data. This
#' function calls the
#' \href{https://developers.google.com/drive/v2/reference/}{Google Drive API} to
#' create the sheet and edit the worksheet name or extent. If you provide data
#' for the sheet, then this function also calls the
#' \href{https://developers.google.com/google-apps/spreadsheets/}{Google Sheets
#' API}.
#'
#' We anticipate that \strong{if} the user wants to control the extent of the
#' new worksheet, it will be by providing input data and specifying `trim =
#' TRUE` (see \code{\link{gs_edit_cells}}) or by specifying \code{row_extent}
#' and \code{col_extent} directly. But not both ... although we won't stop you.
#' In that case, note that explicit worksheet sizing occurs before data
#' insertion. If data insertion triggers any worksheet resizing, that will
#' override any usage of \code{row_extent} or \code{col_extent}.
#'
#' @param title the title for the new spreadsheet
#' @param ws_title the title for the new, sole worksheet; if unspecified, the
#'   Google Sheets default is "Sheet1"
#' @template row_extent
#' @template col_extent
#' @param ... optional arguments passed along to \code{\link{gs_edit_cells}} in
#'   order to populate the new worksheet with data
#' @template verbose
#'
#' @template return-googlesheet
#'
#' @seealso \code{\link{gs_edit_cells}} for specifics on populating the new
#'   sheet with some data and \code{\link{gs_upload}} for creating a new
#'   spreadsheet by uploading a local file. Note that \code{\link{gs_upload}} is
#'   likely much faster than using \code{\link{gs_new}} and/or
#'   \code{\link{gs_edit_cells}}, so try both if speed is a concern.
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
#'
#' foo <- gs_new("foo", ws = "I know my ABCs", input = letters, trim = TRUE)
#' foo
#' gs_delete(foo)
#' }
#'
#' @export
gs_new <- function(title = "my_sheet", ws_title = NULL,
                   row_extent = NULL, col_extent = NULL,
                   ...,
                   verbose = TRUE) {

  current_sheets <- gs_ls(regex = title, fixed = TRUE, verbose = FALSE)
  if (!is.null(current_sheets)) {
    wpf(paste("At least one sheet matching \"%s\" already exists, so you",
              "may\nneed to identify by key, not title, in future."), title)
  }

  the_body <- list(title = title,
                   mimeType = "application/vnd.google-apps.spreadsheet")
  req <- httr::POST(.state$gd_base_url_files_v2, google_token(),
                    encode = "json", body = the_body) %>%
    httr::stop_for_status()
  rc <- content_as_json_UTF8(req)

  ss <- rc$id %>%
    gs_key(verbose = FALSE)

  if (inherits(ss, "googlesheet")) {
    if (verbose) {
      mpf("Sheet \"%s\" created in Google Drive.", ss$sheet_title)
    }
  } else {
    spf("Unable to create Sheet \"%s\" in Google Drive.", title)
  }

  if(!is.null(ws_title)) {
    ss <- ss %>%
      gs_ws_rename(from = 1, to = ws_title, verbose = FALSE)
    if(verbose && !is.null(ws_title)) {
      if(ws_title %in% ss$ws$ws_title) {
        mpf("Worksheet \"%s\" renamed to \"%s\".", "Sheet1", ws_title)
      } else {
        mpf(paste("Cannot verify whether worksheet \"%s\" was",
                  "renamed to \"%s\"."), "Sheet1", ws_title)
      }
    }
  }

  if(!is.null(row_extent) || !is.null(col_extent)) {
    ## unless I sleep, it's better to use ws = 1 than to access by (new?) title
    ss <- ss %>%
      gs_ws_resize(ws = 1, row_extent = row_extent, col_extent = col_extent,
                   verbose = FALSE)
  }

  dotdotdot <- list(...)
  if(length(dotdotdot)) {
    gs_edit_cells_arg_list <-
      c(list(ss = ss), dotdotdot, list(verbose = verbose))
    #print(gs_edit_cells_arg_list)
    ss <- do.call(gs_edit_cells, gs_edit_cells_arg_list)
  }

  if(verbose) {
    mpf("Worksheet dimensions: %d x %d.", ss$ws$row_extent, ss$ws$col_extent)
  }

  invisible(ss)

}
