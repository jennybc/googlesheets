#' Move spreadsheets to trash on Google Drive
#'
#' You must own a sheet in order to move it to the trash. If you try to delete a
#' sheet you do not own, a 403 Forbidden HTTP status code will be returned; such
#' shared spreadsheets can only be moved to the trash manually in the web
#' browser. If you trash a spreadsheet that is shared with others, it will no
#' longer appear in any of their Google Drives. If you delete something by
#' mistake, remain calm, and visit the
#' \href{https://drive.google.com/drive/#trash}{trash in Google Drive}, find the
#' sheet, and restore it.
#'
#' @param x sheet-identifying information, either a googlesheet object or a
#'   character vector of length one, giving a URL, sheet title, key or
#'   worksheets feed; if \code{x} is specified, the \code{regex} argument will
#'   be ignored
#' @param regex character; a regular expression; sheets whose titles match will
#'   be deleted
#' @param ... optional arguments to be passed to \code{\link{grepl}} when
#'   matching \code{regex} to sheet titles
#' @param verbose logical; do you want informative message?
#'
#' @return tbl_df with one row per specified or matching sheet, a variable
#'   holding spreadsheet titles, a logical vector indicating deletion success
#'
#' @note If there are multiple sheets with the same name and you don't want to
#'   delete them all, identify the sheet to be deleted via key.
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' foo <- edit_cells(foo, input = head(iris))
#' delete_ss("foo")
#' }
#'
#' @export
delete_ss <- function(x = NULL, regex = NULL, verbose = TRUE, ...) {

  ## this can be cleaned up once identify_ss() becomes less rigid

  if(!is.null(x)) {

    ## I set verbose = FALSE here mostly for symmetry with gs_new
    x_ss <- x %>%
      identify_ss(verbose = FALSE)
    # this will throw error if no sheet is uniquely identified; tolerate for
    # now, but once identify_ss() is revised, add something here to test whether
    # we've successfully identified at least one sheet for deletion; to delete
    # multiple sheets or avoid error in case of no sheets, current workaround is
    # to use the regex argument
    if(is.na(x_ss$alt_key)) { ## this is a "new" sheet
      keys_to_delete <-  x_ss$sheet_key
    } else {                     ## this is an "old" sheet
      keys_to_delete <- x_ss$alt_key
    }
    titles_to_delete <- x_ss$sheet_title

  } else {

    if(is.null(regex)) {

      stop("You must specify which sheet(s) to delete.")

    } else {

      ss_df <- gs_ls()
      delete_me <- grepl(regex, ss_df$sheet_title, ...)
      keys_to_delete <-
        ifelse(ss_df$version == "new", ss_df$sheet_key,
               ss_df$alt_key)[delete_me]
      titles_to_delete <- ss_df$sheet_title[delete_me]

      if(length(titles_to_delete) == 0L) {
        if(verbose) {
          sprintf("No matching sheets found.") %>%
            message()
        }
        return(invisible(NULL))
      }
    }
  }

  if(verbose) {
    sprintf("Sheets found and slated for deletion:\n%s",
            titles_to_delete %>%
              paste(collapse = "\n")) %>%
      message()
  }

  the_url <- paste("https://www.googleapis.com/drive/v2/files",
                   keys_to_delete, "trash", sep = "/")

  post <- lapply(the_url, gdrive_POST, body = NULL)
  statii <- vapply(post, `[[`, FUN.VALUE = integer(1), "status_code")
  sitrep <-
    dplyr::data_frame_(list(ss_title = ~ titles_to_delete,
                            deleted = ~(statii == 200)))

  if(verbose) {
    if(all(sitrep$deleted)) {
      message("Success. All moved to trash in Google Drive.")
    } else {
      sprintf("Oops. These sheets were NOT deleted:\n%s",
              sitrep$ss_title[!sitrep$deleted] %>%
                paste(collapse = "\n")) %>%
        message()
    }
  }

  sitrep %>% invisible()

}
