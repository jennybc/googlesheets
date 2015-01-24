#' Create a new spreadsheet
#' 
#' Create a new (empty) spreadsheet in your Google Drive. The new spreadsheet
#' will contain 1 default worksheet titled "Sheet1".
#' 
#' @param title the title for the new spreadsheet
#' 
#' @importFrom jsonlite toJSON
#' @export
add_spreadsheet <- function(title)
{
  dat <- data.frame("title" = title, 
                    "mimeType" = "application/vnd.google-apps.spreadsheet")
  
  the_body_pre <- toJSON(dat)
  
  the_body_clean <- sub('\\[', "", the_body_pre)
  the_body <- sub('\\]', "", the_body_clean)
  
  gsheets_POST(url = "https://www.googleapis.com/drive/v2/files", the_body, 
               content_type = "json")
  
  message(paste0('Spreadsheet "', title, '" created in Google Drive.'))
}


#' Move spreadsheet to trash
#' 
#' Move a spreadsheet to trash in Google Drive.
#' 
#' @param title the title of the spreadsheet
#' 
#' @note Shared spreadsheets can not be removed from your Google Drive with 
#' this function. You must remove it manually in the web browser.
#' 
#' @export
del_spreadsheet <- function(title)
{
  sheets_df <- ssfeed_to_df()
  
  index <- match(title, sheets_df$sheet_title)
  
  sheet_id <- sheets_df[index, "sheet_key"]
  
  the_url <- slaste("https://www.googleapis.com/drive/v2/files", sheet_id,
                    "trash")
  
  gsheets_POST(the_url, the_body = NULL)
  
  message(paste0('Spreadsheet "', title, '" moved to trash in Google Drive.'))
}


#' Add a new (empty) worksheet to spreadsheet
#'
#' Add a new (empty) worksheet to spreadsheet, specify title, number of rows 
#' and columns. The title of the new worksheet should not be the same as any of
#' the existing worksheets
#'
#' @param ss spreadsheet object
#' @param title character string for title of new worksheet 
#' @param nrow number of rows (default is 1000)
#' @param ncol number of columns (default is 26)
#' 
#' @importFrom XML xmlNode toString.XMLNode
#' @export
add_worksheet <- function(ss, title, nrow = 1000, ncol = 26) 
{ 
  exist <- match(title, list_worksheets(ss))
  
  if(!is.na(exist))
    stop("A worksheet with the same name already exists", 
         ", please choose a different name!")
  
  the_body <- 
    xmlNode("entry", 
            namespaceDefinitions = 
              c(default_ns,
                gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("title", title),
            xmlNode("gs:rowCount", nrow),
            xmlNode("gs:colCount", ncol))
  
  the_body <- toString.XMLNode(the_body)
  
  the_url <- build_req_url("worksheets", key = ss$sheet_id)
  
  gsheets_POST(the_url, the_body)
  
  message(paste0('Worksheet "', title, '" successfully added.'))
}


#' Delete a worksheet from spreadsheet
#'
#' The worksheet and all of its data will be removed from the spreadsheet.
#'
#' @param ss spreadsheet object
#' @param ws_title title of worksheet 
#' @export
del_worksheet<- function(ss, ws_title) 
{
  index <- match(ws_title, names(ss$worksheets))
  
  if(is.na(index))
    stop("Worksheet not found.")
  
  ws <- ss$worksheets[[index]]
  
  the_url <- build_req_url("worksheets", key = ws$sheet_id, ws_id = ws$ws_id)
  
  gsheets_DELETE(the_url) 
  
  message(paste0('Worksheet "', ws_title, '" successfully deleted.'))
}

#' Rename a worksheet
#'
#' @param ss spreadsheet object
#' @param old_title worksheet's current title
#' @param new_title worksheets's new title
#' 
#' @export
rename_worksheet <- function(ss, old_title, new_title)
{
  index <- match(old_title, names(ss$worksheets))
  
  if(is.na(index))
    stop("Worksheet not found.")
  
  ws <- ss$worksheets[[index]]
  
  req_url <- build_req_url("worksheets", key = ss$sheet_id, ws_id = ws$ws_id)
  req <- gsheets_GET(req_url)
  feed <- gsheets_parse(req)
  
  edit_url <- unlist(getNodeSet(feed, '//ns:link[@rel="edit"]', 
                                c("ns" = default_ns),
                                function(x) xmlGetAttr(x, "href")))
  
  new_feed <- sub(old_title, new_title, toString.XMLNode(feed))
  
  gsheets_PUT(edit_url, new_feed)
}