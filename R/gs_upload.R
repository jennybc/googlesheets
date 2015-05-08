#' Upload a file and convert it to a Google Sheet
#'
#' Google supports the following file types to be converted to a Google
#' spreadsheet: .xls, .xlsx, .csv, .tsv, .txt, .tab, .xlsm, .xlt, .xltx, .xltm,
#' .ods. The newly uploaded file will appear in your Google Sheets home screen.
#' This function calls the
#' \href{https://developers.google.com/drive/v2/reference/}{Google Drive API}.
#'
#' @param file path to the file to upload
#' @param sheet_title the title of the spreadsheet; optional, if not specified
#'   then the name of the file will be used
#' @param verbose logical; do you want informative message?
#'
#' @examples
#' \dontrun{
#' write.csv(head(iris, 5), "iris.csv", row.names = FALSE)
#' iris_ss <- upload_ss("iris.csv")
#' iris_ss
#' get_via_lf(iris_ss)
#' file.remove("iris.csv")
#' gs_delete(iris_ss)
#' }
#'
#' @export
upload_ss <- function(file, sheet_title = NULL, verbose = TRUE) {

  if(!file.exists(file)) {
    stop(sprintf("\"%s\" does not exist!", file))
  }

  ext <- c("xls", "xlsx", "csv", "tsv", "txt", "tab", "xlsm", "xlt",
           "xltx", "xltm", "ods")

  if(!(tools::file_ext(file) %in% ext)) {
    stop(sprintf(paste("Cannot convert file with this extension to a Google",
                       "Spreadsheet: %s"), tools::file_ext(file)))
  }

  if(is.null(sheet_title)) {
    sheet_title <- file %>% basename() %>% tools::file_path_sans_ext()
  }

  req <-
    gdrive_POST(url = "https://www.googleapis.com/drive/v2/files",
                body = list(title = sheet_title,
                            mimeType = "application/vnd.google-apps.spreadsheet"))

  new_sheet_key <- httr::content(req)$id

  # append sheet_key to put_url
  put_url <- httr::modify_url("https://www.googleapis.com/",
                              path = paste0("upload/drive/v2/files/",
                                            new_sheet_key))

  gdrive_PUT(put_url, the_body = file)

  ss_df <- gs_ls()
  success <- new_sheet_key %in% ss_df$sheet_key

  if(success) {
    if(verbose) {
      message(sprintf(paste("\"%s\" uploaded to Google Drive and converted",
                            "to a Google Sheet named \"%s\""),
                      basename(file), sheet_title))
    }
  } else {
    stop(sprintf("Cannot confirm the file upload :("))
  }

  new_sheet_key %>%
    register_ss(verbose = FALSE) %>%
    invisible()

}
