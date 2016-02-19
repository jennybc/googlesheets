#' Rename a spreadsheet
#'
#' Give a spreadsheet a new name. Note that file names are not necessarily
#' unique within a folder on Google Drive.
#'
#' @template ss
#' @param to character string for new title of spreadsheet
#' @template verbose
#'
#' @template return-googlesheet
#' @export
#'
#' @examples
#' \dontrun{
#' ss <- gs_gap() %>% gs_copy(to = "jekyll")
#' gs_ls("jekyll")                  ## see? it's there
#' ss <- ss %>% gs_rename("hyde")
#' gs_ls("hyde")                    ## see? it's got a new name
#' gs_delete(ss)
#' }
gs_rename <- function(ss, to, verbose = TRUE) {

  ## TO DO: extract this into a fxn when I generalize to a Drive listing
  ## and use it in gs_new() and gs_copy() as well
  current_sheets <- gs_ls(regex = to, fixed = TRUE, verbose = FALSE)

  if (ss$sheet_key %in% current_sheets$sheet_key && verbose) {
    mpf("New sheet name is same as existing: %s", ss$sheet_title)
  }

  if (!is.null(current_sheets) && verbose) {
    wpf(paste("At least one sheet matching \"%s\" already exists, so you",
              "may\nneed to identify by key, not title, in future."),
        ss$sheet_title)
  }

  fr <- gd_rename(ss$sheet_key, to)
  if (verbose) {
    if (!identical(fr$name, to)) {
      mpf("Cannot confirm that target Sheet \"%s\" was renamed to \"%s\"",
          ss$sheet_title, to)
    } else {
      mpf("Sheet \"%s\" renamed to \"%s\"", ss$sheet_title, fr$name)
    }
  }
  fr$id %>%
    gs_key(verbose = FALSE) %>%
    invisible()
}
