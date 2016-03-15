#' Download a spreadsheet
#'
#' Export a Google Sheet as a .csv, .pdf, or .xlsx file. You can download a
#' sheet that you own or a sheet owned by a third party that has been made
#' accessible via the sharing dialog options. You can download the entire
#' spreadsheet (.pdf and .xlsx formats) or a single worksheet. This function
#' calls the \href{https://developers.google.com/drive/v2/reference/}{Google
#' Drive API}. Note that the current implementation of this function absolutely
#' requires authorization.
#'
#' If the worksheet is unspecified, i.e. if \code{ws = NULL}, then the entire
#' spreadsheet will be exported (.pdf and xlsx formats) or the first worksheet
#' will be exported (.csv format)
#'
#' @template ss_from
#' @template ws
#' @param to path to write file; file extension must be one of .csv, .pdf, or
#'   .xlsx, which dictates the export format; defaults to \code{foo.xlsx} where
#'   \code{foo} is a safe filename constructed from the title of the Sheet being
#'   downloaded
#' @param overwrite logical, indicating whether to overwrite an existing local
#'   file
#' @template verbose
#'
#' @return The normalized path of the downloaded file, after confirmed success,
#'   or \code{NULL}, otherwise, invisibly.
#'
#' @examples
#' \dontrun{
#' gs_download(gs_gap(), to = "gapminder.xlsx")
#' file.remove("gapminder.xlsx")
#' }
#'
#' @export
gs_download <-
  function(from, ws = NULL, to = NULL, overwrite = FALSE, verbose = TRUE) {

  stopifnot(inherits(from, "googlesheet"))

  if (is.null(to)) {
    to <- tolower(gsub('[^A-Za-z0-9]+', '-', from$sheet_title))
    to <- gsub("^-|-$", '', to)
    to <- paste0(to, ".xlsx")
  }

  ext <- tools::file_ext(to)
  if (!(ext %in% c("csv", "pdf", "xlsx"))) {
    spf("Cannot download Google spreadsheet as this format: %s", ext)
  }

  if (is.null(ws)) {
    key <- gs_get_alt_key(from)
    ## I used to hit the Drive Files resource to retrieve metadata
    ## GET /files/fileId (relative to Drive URI)
    ## then dug out export links
    ## but that required auth
    ## now I make the links "by hand" so we don't need a token so often
    ## if things break, consider that the link format has changed
    base_url <- "https://docs.google.com/spreadsheets/export"
    export_links <- c("csv", "pdf", "xlsx") %>%
      purrr::set_names() %>%
      purrr::map_chr(
        ~httr::modify_url(base_url,
                          query = list(id = key, exportFormat = .x)))
  } else {
    this_ws <- from %>% gs_ws(ws)
    export_links <- c(
      csv = this_ws$exportcsv,
      pdf = httr::modify_url(this_ws$exportcsv, query = list(format = "pdf")),
      xlsx = httr::modify_url(this_ws$exportcsv, query = list(format = "xlsx")))
  }

  ext_match <- grepl(ext, names(export_links))
  if (any(ext_match)) {
    link <- export_links[[ext]]
  } else {
    mess <- sprintf(paste("Download as a %s file is not supported for this",
                          "sheet. Is this perhaps an \"old\" Google Sheet?"),
                    ext)
    stop(mess)
  }

  httr::GET(link, omit_token_if(grepl("public", from$ws_feed)),
            if (interactive()) httr::progress() else NULL,
            httr::write_disk(to, overwrite = overwrite))

  if (file.exists(to)) {

    to <- normalizePath(to)
    if(verbose) {
      mpf("Sheet successfully downloaded:\n%s", to)
    }
    return(invisible(to))

  } else {

    spf("Cannot confirm the file download :(")
    return(invisible(NULL))

  }

}
