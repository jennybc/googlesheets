#' Create a new spreadsheet
#' 
#' Create a new (empty) spreadsheet in your Google Drive. The new spreadsheet
#' will contain 1 default worksheet titled "Sheet1".
#' 
#' @param title the title for the new spreadsheet
#' 
#' @export
new_ss <- function(title)
{
  the_body <- list("title" = title, 
                   "mimeType" = "application/vnd.google-apps.spreadsheet")
  
  the_url <- "https://www.googleapis.com/drive/v2/files"
  
  gsheets_POST(the_url, the_body)
  
  message(paste0('Spreadsheet "', title, '" created in Google Drive.'))
}


#' Move a spreadsheet to trash{"__src__":"file","ids":"1PmCRtmcX4r7LOS-XVw6u8f-E3sVnFgamJaKCmVF3Sv0","parentId":"0AFlKxBjVWN80Uk9PVA"}
#' 
#' Move a spreadsheet to trash in Google Drive.
#' 
#' @param x the title or key of a spreadsheet
#' 
#' @note Using the key is useful when there are spreadsheets with the same name 
#' since the default is to send the most recent spreadsheet to the trash.
#' 
#' @note Shared spreadsheets can not be removed from your Google Drive with 
#' this function. You must remove it manually in the web browser.
#' 
#' @export
delete_ss <- function(x)
{
  ssfeed_df <- list_spreadsheets()
  
  if(x %in% ssfeed_df$sheet_key) {
    key = x
  } else {
    key_index <- match(x, ssfeed_df$sheet_title)
    key <- ssfeed_df$sheet_key[key_index]
  }
  
  url <- "https://www.googleapis.com/drive/v2/files"
  
  the_url <- slaste(url, key, "trash")
  
  gsheets_POST(the_url, the_body = NULL)
  
  message('Spreadsheet moved to trash in Google Drive.')
}



#' Make a copy of an existing spreadsheet
#' 
#' You can either make a copy of your own spreadsheet or another user's 
#' spreadsheet. If the spreadsheet you want to make a copy of already exists in 
#' your Google Drive, pass in the title of the spreadsheet. To get a copy of 
#' another user's spreadsheet, enter the key of that spreadsheet. Make sure 
#' that the target spreadsheet is made 'accessible' in the sharing dialog 
#' options or else it wont be found.
#' 
#' @param x the title or key or url of a spreadsheet
#' 
#' @param new_title a character string for the new title of the spreadsheet, 
#' if \code{new_title} is NULL then the copied spreadsheet will
#' be given the default name: "Copy of ..."
#' 
#' @note if two spreadsheets with the same name exist in your Google drive then 
#' spreadsheet with the most recent "last updated" timestamp will be copied. 
#' @export
copy_ss <- function(x, new_title = NULL)
{
  # is it an old style sheet?
  url_start <- "https://docs.google.com/spreadsheet/ccc?key="
  if(x %>% stringr::str_detect(stringr::fixed(url_start))) {
    key <- x %>% stringr::str_replace(., stringr::fixed(url_start), "") %>%
      stringr::str_split_fixed('&', n = 2) %>% "["(1)
  } else {
    # is it a new style sheet?
    url_start <- "https://docs.google.com/spreadsheets/d/"
    if(x %>% stringr::str_detect(stringr::fixed(url_start))) {
      key <- x %>% stringr::str_replace(url_start, '') %>%
        stringr::str_split_fixed('/', n = 2) %>%
        "["(1)
    } else {
      # check user's spreadsheets
      ssfeed_df <- list_spreadsheets()
      
      if(x %in% ssfeed_df$sheet_key) {
        key <- x
      } else {
        key_index <- match(x, ssfeed_df$sheet_title)
        key <- ssfeed_df$sheet_key[key_index]
      }
    }
  }
  
  the_body <- list("title" = new_title)
  
  the_url <- slaste("https://www.googleapis.com/drive/v2/files", key, "copy")
  
  gsheets_POST(the_url, the_body)
  
  message("A copy of the spreadsheet has been made in your Google Drive.")
}


#' Add a new (empty) worksheet to spreadsheet
#'
#' Add a new (empty) worksheet to spreadsheet, specify title, worksheet extent (number of rows 
#' and columns). The title of the new worksheet can not be the same as any 
#' existing worksheets in the spreadsheet.
#'
#' @param ss a registered Google spreadsheet
#' @param ws_title character string for title of new worksheet 
#' @param nrow number of rows (default is 1000)
#' @param ncol number of columns (default is 26)
#' 
#' @export
new_ws <- function(ss, ws_title, nrow = 1000, ncol = 26) 
{ 
  ws_title_exist <- match(ws_title, ss$ws[["ws_title"]])
  
  if(!is.na(ws_title_exist))
    stop("A worksheet with the same name already exists, please choose a different name!")
  
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
  
  message(paste('Worksheet', ws_title, 'successfully added in Spreadsheet,', 
                ss$sheet_title))
}


#' Delete a worksheet from a spreadsheet
#'
#' The worksheet and all of its contents will be removed from the spreadsheet.
#'
#' @param ss a registered Google spreadsheet
#' @param ws_title title of worksheet 
#' @export
delete_ws<- function(ss, ws_title) 
{
  ws_title_exist <- ws_title %in% ss$ws[["ws_title"]]
  
  if(!ws_title_exist) {
    stop("Worksheet not found.")
  } else {
    ws_index <- match(ws_title, ss$ws[["ws_title"]])
    ws_id <- ss$ws[ws_index, "ws_id"]
  }
  
  gsheets_DELETE(ws_id) 
  
  message(paste('Worksheet:', ws_title, 
                'successfully deleted from Spreadsheet:', ss$sheet_title))
}
