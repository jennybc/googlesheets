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
#' @template verbose
#'
#' @examples
#' \dontrun{
#' write.csv(head(iris, 5), "iris.csv", row.names = FALSE)
#' iris_ss <- gs_upload("iris.csv")
#' iris_ss
#' gs_read(iris_ss)
#' file.remove("iris.csv")
#' gs_delete(iris_ss)
#' }
#'
#' @export
gs_upload <- function(file, sheet_title = NULL, verbose = TRUE) {

  if (!file.exists(file)) {
    spf("\"%s\" does not exist!", file)
  }

  valid_ext <- c("xls", "xlsx", "csv", "tsv", "txt", "tab", "xlsm", "xlt",
                 "xltx", "xltm", "ods")
  ext <- tools::file_ext(file)
  if (!(ext %in% valid_ext)) {
    spf("Cannot convert file with this extension to a Google Sheet: %s", ext)
  }

  if (is.null(sheet_title)) {
    sheet_title <- file %>% basename() %>% tools::file_path_sans_ext()
  }

  ## upload metadata --> get a fileId (Drive-speak) or key (Sheets-speak)
  the_body <- list(title = sheet_title,
                   mimeType = "application/vnd.google-apps.spreadsheet")
  req <- httr::POST(.state$gd_base_url_files_v2, google_token(),
                    body = the_body, encode = "json") %>%
    httr::stop_for_status()
  rc <- content_as_json_UTF8(req)
  new_key <- rc$id

  ## the actual file upload
  the_url <- file.path(.state$gd_base_url, "upload/drive/v2/files", new_key)
  the_url <-
    httr::modify_url(the_url,
                     query = list(uploadType = "media", convert = TRUE))
  req <- httr::PUT(the_url, google_token(), body = httr::upload_file(file)) %>%
    httr::stop_for_status()
  rc <- content_as_json_UTF8(req)

  ss_df <- gs_ls()
  success <- new_key %in% ss_df$sheet_key

  if (success) {
    if (verbose) {
      mpf(paste0("File uploaded to Google Drive:\n%s\n",
                 "As the Google Sheet named:\n%s"),
          file, sheet_title)
    }
  } else {
    spf("Cannot confirm the file upload :(")
  }

  new_key %>%
    gs_key(verbose = FALSE) %>%
    invisible()

}
