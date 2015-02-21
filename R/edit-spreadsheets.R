#' Create a new spreadsheet
#' 
#' Create a new (empty) spreadsheet in your Google Drive. The new sheet will
#' contain 1 default worksheet titled "Sheet1".
#' 
#' @param title the title for the new sheet
#' @param verbose logical; do you want informative message?
#'   
#' @export
new_sheet <- function(title = "my_sheet", verbose = TRUE) {
  
  the_body <- list(title = title,
                   mimeType = "application/vnd.google-apps.spreadsheet")

  gsheets_POST(url = "https://www.googleapis.com/drive/v2/files", the_body)
  
  if(verbose) {
    message(sprintf("Sheet \"%s\" created in Google Drive.", title))
  }
  
}

#' Move a spreadsheet to trash
#' 
#' You must own the sheet in order to move it to the trash. If you try to delete
#' a sheet you do not own, a 403 Forbidden HTTP status code will be returned;
#' such shared spreadsheets can only be moved to the trash manually in the web
#' browser. If you trash a spreadsheet that is shared with others, it will no
#' longer appear in any of their Google Drives.
#' 
#' @param x character string giving identifying information for the sheet: 
#'   title, key, URL
#' @param verbose logical; do you want informative message?
#'   
#' @note Use the key when there are multiple sheets with the same name, since 
#'   the default will just send the most recent sheet to the trash.
#'   
#' @export
delete_sheet <- function(x, verbose = TRUE) {
  
  x_ss <- x %>% identify_sheet(verbose)
  
  the_url <- slaste("https://www.googleapis.com/drive/v2/files",
                    x_ss$sheet_key, "trash")
  
  gsheets_POST(the_url, the_body = NULL)
  
  if(verbose) {
    message(sprintf("Sheet \"%s\" moved to trash in Google Drive.",
                    x_ss$sheet_title))
  }

}


#' Make a copy of an existing spreadsheet
#' 
#' You can copy a spreadsheet that you own or a sheet owned by a third party 
#' that has been made accessible via the sharing dialog options. If the sheet 
#' you want to copy is visible in the listing provided by 
#' \code{\link{list_sheets}}, you can specify it by title. Otherwise you can
#' extract the key from the browser URL via \code{\link{extract_key_from_url}}
#' and explicitly specify the sheet by key.
#' 
#' @param from character string giving identifying information for the 
#'   sheet: title, key, URL
#' @param key character string guaranteed to provide unique key of the 
#'   sheet; overrides \code{from}
#' @param to character string giving the new title of the sheet; if 
#'   \code{NULL}, then the copied sheet will be titled "Copy of ..."
#' @param verbose logical; do you want informative message?
#'   
#' @note if two sheets with the same name exist in your Google drive then 
#'   sheet with the most recent "last updated" timestamp will be copied.
#' @export
copy_sheet <- function(from, key = NULL, to = NULL, verbose = TRUE) {
  
  if(is.null(key)) { # figure out the sheet from 'from ='
    from_ss <- from %>% identify_sheet()
    key <-  from_ss$sheet_key
    title <- from_ss$sheet_title
  } else {           # else ... take key at face value
    title <- key
  }

  the_body <- list("title" = to)
  
  the_url <- slaste("https://www.googleapis.com/drive/v2/files", key, "copy")
  
  gsheets_POST(the_url, the_body)
  
  if(verbose) {
    message(sprintf("A copy of \"%s\" has been made in your Google Drive.",
                    from_ss$sheet_title))
  }
}

#' Add a new (empty) worksheet to spreadsheet
#' 
#' Add a new (empty) worksheet to spreadsheet, specify title, worksheet extent
#' (number of rows and columns). The title of the new worksheet can not be the
#' same as any existing worksheets in the sheet.
#' 
#' @param ss a registered Google sheet
#' @param ws_title character string for title of new worksheet
#' @param nrow number of rows (default is 1000)
#' @param ncol number of columns (default is 26)
#' @param verbose logical; do you want informative message?
#'   
#' @export
new_ws <- function(ss, ws_title, nrow = 1000, ncol = 26, verbose = TRUE) { 
  
  ws_title_exist <- match(ws_title, ss$ws[["ws_title"]])
  
  if(!is.na(ws_title_exist)) {
    stop(sprintf("A worksheet titled \"%s\" already exists, please choose a different name.", ws_title))
  }
  
  the_body <- 
    XML::xmlNode("entry", 
                 namespaceDefinitions = 
                   c("http://www.w3.org/2005/Atom",
                     gs = "http://schemas.google.com/spreadsheets/2006"),
                 XML::xmlNode("title", ws_title),
                 XML::xmlNode("gs:rowCount", nrow),
                 XML::xmlNode("gs:colCount", ncol))
  
  the_body <- XML::toString.XMLNode(the_body)
  
  gsheets_POST(ss$ws_feed, the_body)
  
  if(verbose) {
    message(sprintf("Worksheet \"%s\" added to sheet \"%s\"",
                    ws_title, ss$sheet_title))
  }
}


#' Delete a worksheet from a spreadsheet
#'
#' The worksheet and all of its contents will be removed from the spreadsheet.
#'
#' @param ss a registered Google sheet
#' @param ws_title title of worksheet
#' @param verbose logical; do you want informative message?
#' 
#' @export
delete_ws <- function(ss, ws_title, verbose = TRUE) {
  
  ws_title_match <- match(ws_title, ss$ws$ws_title)
  
  if(is.na(ws_title_match)) {
    stop(sprintf("No worksheet titled \"%s\" found in sheet \"%s\".",
                 ws_title, ss$sheet_title))
  }

  gsheets_DELETE(ss$ws$ws_id[ws_title_match]) 
  
  if(verbose) {
    message(sprintf("Worksheet \"%s\" deleted from sheet \"%s\".",
                    ws_title, ss$sheet_title))
  }
}
