#' Download a Google Sheet
#' 
#' Export a Google Spreadsheet as a .csv, .pdf, or .xlsx file. You can download 
#' a spreadsheet that you own or a sheet owned by a third party that has been 
#' made accessible via the sharing dialog options. You can download an entire 
#' spreadsheet or a single worksheet from a spreadsheet if you provide worksheet 
#' identifying information. If the chosen format is csv, the first worksheet 
#' will be exported, unless another worksheet is specified. If pdf format is 
#' chosen, all sheets will be appended into 1 pdf document. 
#' 
#' 
#' @param from sheet-identifying information, either a spreadsheet object or a 
#'   character vector of length one, giving a URL, sheet title, key or 
#'   worksheets feed
#'   
#' @param key character string guaranteed to provide unique key of the sheet; 
#'   overrides \code{from}
#'   
#' @param ws positive integer or character string specifying index or title, 
#'   respectively, of the worksheet to export ; if \code{NULL} then the entire 
#'   spreadsheet will be exported
#'   
#' @param to path to write file, if it does not contain the absolute path, 
#' then the file is relative to the current working directory
#' 
#' @param overwrite will only overwrite existing path if TRUE
#' 
#' @param verbose logical; do you want informative message?
#' @export
download_ss <- function(from, key = NULL, ws = NULL, to = "my_sheet.xlsx", 
                        overwrite = FALSE, verbose = TRUE) {
  
  if(is.null(key)) { # figure out the sheet from 'from ='
    from_ss <- from %>% identify_ss()
    key <-  from_ss$sheet_key
    title <- from_ss$sheet_title
  } else {           # else ... take key at face value
    key
  }
  
  if(!(tools::file_ext(to) %in% c("csv", "pdf", "xlsx"))) {
    stop(sprintf("Cannot download Google Spreadsheet as this format: %s",
                 tools::file_ext(to)))
  } else {
    ext <- tools::file_ext(to)
  }
  
  #export a single worksheet
  if(!is.null(ws)) {
    
    this_ws <- register_ss(key, verbose = FALSE) %>% get_ws(ws)
    
    export_links <- c(
      csv = this_ws$exportcsv,
      pdf = httr::modify_url(this_ws$exportcsv, query = list(format = "pdf")),
      xlsx = httr::modify_url(this_ws$exportcsv, query = list(format = "xlsx")))
    
  } else { 
    # get export links for entire spreadsheet
    the_url <- paste("https://www.googleapis.com/drive/v2/files", key, sep = "/")
    
    req <- gdrive_GET(the_url)
    
    export_links <- c(
      csv = req$content$exportLinks$'text/csv', # first sheet only
      pdf = req$content$exportLinks$'application/pdf',
      xlsx = req$content$exportLinks$'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')  
  }
  
  link <- export_links %>% `[[`(ext)
  
  # using httr::progress() shows number of bytes downloaded but when README knits, 
  # incremental #bytes gets printed, so removing for now
  gdrive_GET(link, httr::write_disk(to, overwrite = overwrite))
  
  if(file.exists(to)) {
    
    if(verbose) {
      
    if(identical(dirname(to), ".")) {
      dir <- getwd()
    } else {
      dir <- dirname(to)
    }
    
    message(sprintf("Sheet successfully downloaded: %s", file.path(dir, basename(to))))
    
    }
  } else {
    stop(sprintf("Cannot confirm the file download :("))
  }
}
