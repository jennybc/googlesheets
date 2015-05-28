#' Download a spreadsheet
#'
#' Export a Google Sheet as a .csv, .pdf, or .xlsx file. You can download a
#' sheet that you own or a sheet owned by a third party that has been made
#' accessible via the sharing dialog options. You can download the entire
#' spreadsheet (.pdf and .xlsx formats) or a single worksheet. This function
#' calls the \href{https://developers.google.com/drive/v2/reference/}{Google
#' Drive API}.
#'
#' If the worksheet is unspecified, i.e. if \code{ws = NULL}, then the entire
#' spreadsheet will be exported (.pdf and xlsx formats) or the first worksheet
#' will be exported (.csv format)
#'
#' @template ss_from
#' @template ws
#' @param to path to write file; file extension must be one of .csv, .pdf, or
#'   .xlsx, which dictates the export format
#' @param overwrite logical, indicating whether to overwrite an existing local
#'   file
#' @template verbose
#'
#' @examples
#' \dontrun{
#' gs_download(gs_gap(), to = "gapminder.xlsx")
#' file.remove("gapminder.xlsx")
#' }
#'
#' @export
gs_download <-
  function(from, ws = NULL, to = "my_sheet.xlsx",
           overwrite = FALSE, verbose = TRUE) {

  stopifnot(inherits(from, "googlesheet"))

  ext <- tools::file_ext(to)
  if(!(ext %in% c("csv", "pdf", "xlsx"))) {
    stop(sprintf("Cannot download Google spreadsheet as this format: %s", ext))
  }

  if(is.null(ws)) {

    key <- gs_get_alt_key(from)
    the_url <-
      paste("https://www.googleapis.com/drive/v2/files", key, sep = "/")

    req <- gdrive_GET(the_url)
    export_links <- c(
      csv = req$content$exportLinks$'text/csv', # first sheet only
      pdf = req$content$exportLinks$'application/pdf',
      xlsx = req$content$exportLinks$'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

  } else {

    this_ws <- from %>% gs_ws(ws)
    export_links <- c(
      csv = this_ws$exportcsv,
      pdf = httr::modify_url(this_ws$exportcsv, query = list(format = "pdf")),
      xlsx = httr::modify_url(this_ws$exportcsv, query = list(format = "xlsx")))

  }

  ext_match <- grepl(ext, names(export_links))
  if(any(ext_match)) {
    link <- export_links %>% `[[`(ext)
  } else {
    mess <- sprintf(paste("Download as a %s file is not supported for this",
                          "sheet. Is this perhaps an \"old\" Google Sheet?"),
                    ext)
    stop(mess)
  }

  if(interactive()) {
    gdrive_GET(link, httr::write_disk(to, overwrite = overwrite),
               httr::progress())
  } else {
    gdrive_GET(link, httr::write_disk(to, overwrite = overwrite))
  }

  if(file.exists(to)) {

    if(verbose) {
      message(sprintf("Sheet successfully downloaded: %s", normalizePath(to)))
    }

  } else {

    stop(sprintf("Cannot confirm the file download :("))

  }

}
