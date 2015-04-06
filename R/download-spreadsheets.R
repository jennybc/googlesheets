#' Download a Google spreadsheet
#' 
#' Export a Google sheet as a .csv, .pdf, or .xlsx file. You can download a 
#' sheet that you own or a sheet owned by a third party that has been made 
#' accessible via the sharing dialog options. You can download an entire 
#' spreadsheet or a single worksheet from a spreadsheet if you provide worksheet
#' identifying information. If the chosen format is csv, the first worksheet 
#' will be exported, unless another worksheet is specified. If pdf format is 
#' chosen, all sheets will be catenated into one PDF document.
#' 
#' @param from sheet-identifying information, either a googlesheet object or a 
#'   character vector of length one, giving a URL, sheet title, key or 
#'   worksheets feed
#' @param key character string guaranteed to provide unique key of the sheet; 
#'   overrides \code{from}
#' @param ws positive integer or character string specifying index or title, 
#'   respectively, of the worksheet to export; if \code{NULL} then the entire 
#'   spreadsheet will be exported
#' @param to path to write file, if it does not contain the absolute path, then 
#'   the file is relative to the current working directory; file extension must
#'   be one of .csv, .pdf, or .xlsx
#' @param overwrite logical indicating whether to overwrite an existing local 
#'   file
#' @param verbose logical; do you want informative message?
#'   
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' download_ss(gap_key, to = "gapminder.xlsx")
#' file.remove("gapminder.xlsx")
#' } 
#' 
#' @export
download_ss <- function(from, key = NULL, ws = NULL, to = "my_sheet.xlsx",
                        overwrite = FALSE, verbose = TRUE) {
  
  if(is.null(key)) { # figure out the sheet from 'from ='
    from_ss <- from %>% identify_ss()
    if(is.na(from_ss$alt_key)) { ## this is a "new" sheet
      key <-  from_ss$sheet_key
    } else {                     ## this is an "old" sheet
      key <- from_ss$alt_key
    }
    title <- from_ss$sheet_title
  }                 # otherwise ... take key at face value

  ext <- tools::file_ext(to)
  if(!(ext %in% c("csv", "pdf", "xlsx"))) {
    stop(sprintf("Cannot download Google spreadsheet as this format: %s", ext))
  }
  
  # export a single worksheet
  if(!is.null(ws)) {
    
    this_ws <- register_ss(key, verbose = FALSE) %>% get_ws(ws)
    
    export_links <- c(
      csv = this_ws$exportcsv,
      pdf = httr::modify_url(this_ws$exportcsv, query = list(format = "pdf")),
      xlsx = httr::modify_url(this_ws$exportcsv, query = list(format = "xlsx")))
  } else {
    # get export links for entire spreadsheet
    the_url <-
      paste("https://www.googleapis.com/drive/v2/files", key, sep = "/")
    
    req <- gdrive_GET(the_url)
    export_links <- c(
      csv = req$content$exportLinks$'text/csv', # first sheet only
      pdf = req$content$exportLinks$'application/pdf',
      xlsx = req$content$exportLinks$'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
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

  if (interactive()) {
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
