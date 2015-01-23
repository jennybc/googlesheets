#' Open spreadsheet by title 
#'
#' Use the spreadsheet title (as it appears in Google Drive) to get a 
#' spreadsheet object, containing the spreadsheet id, title, time of last 
#' update, the titles of the worksheets contained, the number of worksheets 
#' contained, and a list of worksheet objects for every worksheet.
#'
#' @param title the title of the spreadsheet
#' 
#' @note The list of worksheet objects returned is missing the ncol, nrow and 
#' visibility components. Those are determined when \code{\link{open_worksheet}} 
#' or \code{\link{open_at_once}} is used to open a worksheet. It is time 
#' consuming to make a cellfeed request for every worksheet in the spreadsheet 
#' to determine the number of rows and columns. Use 
#' \code{\link{open_worksheets}} to open all worksheets contained in the 
#' spreadsheet. 
#' 
#' @seealso \code{\link{open_worksheets}}
#' 
#' @export
open_spreadsheet <- function(title) 
{
  ssfeed_df <- ssfeed_to_df()
  
  index <- match(title, ssfeed_df$sheet_title)
  if(is.na(index)) stop("Spreadsheet not found.")
  sheet_key <- ssfeed_df[index, "sheet_key"]
  
  the_url <- build_req_url("worksheets", key = sheet_key)
  
  req <- gsheets_GET(the_url)
  wsfeed <- gsheets_parse(req)
  
  wsfeed_list <- XML::xmlToList(wsfeed)
  
  ws_objs <- getNodeSet(wsfeed, "//ns:entry", c(ns = default_ns), 
                        function(x) make_ws_obj(x, sheet_key))
  
  names(ws_objs) <- lapply(ws_objs, function(x) x$title)
  
  ss <- spreadsheet()
  ss$sheet_id <- sheet_key
  ss$sheet_title <- wsfeed_list$title$text
  ss$updated <- wsfeed_list$updated
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  ss$visibility <- "private"
  ss$ws_names <- names(ws_objs)
  ss$worksheets <- ws_objs
  
  ss
}


#' Open a list of worksheets
#'
#' Return a list of all the worksheets in a spreadsheet as worksheet objects so 
#' that \code{plyr} functions can be used to perform worksheet operations on 
#' multiple worksheets at once.
#' 
#' @param ss a spreadsheet object returned by \code{\link{open_spreadsheet}}
#' 
#' @importFrom plyr llply
#' @export
open_worksheets <- function(ss) 
{
  llply(ss$worksheets, function(x) open_worksheet(ss, x$title))
}


#' Open worksheet by title or index
#'
#' Use the title or index of a worksheet to retrieve the worksheet object.
#'
#' @param ss a spreadsheet object containing the worksheet
#' @param value a character string for the title of worksheet or numeric for 
#' index of worksheet
#' 
#' @return A worksheet object.
#' @note Worksheet indexing starts at 1.
#' 
#' @examples
#' \dontrun{
#' ss <- open_spreadsheet("My Spreadsheet")
#' 
#' ws <- open_worksheet(ss, "Sheet1")
#' ws <- open_worksheet(ss, 1)
#' }
#' @export
open_worksheet <- function(ss, value) 
{
  if(is.character(value)) {
    index <- match(value, names(ss$worksheets))
    
    if(is.na(index))
      stop("Worksheet not found.")
    
  } else {
    index <- value
  }
  
  ws <- ss$worksheets[[index]]
  
  ws$visibility <- ss$visibility
  
  ws <- worksheet_dim(ws)
  
  ws
}


#' Open a worksheet from a spreadsheet in one go
#' 
#' @param ss_title spreadsheet title
#' @param ws_value title or numeric index of worksheet
#' 
#' @export
open_at_once <- function(ss_title, ws_value) 
{
  sheet <- open_spreadsheet(ss_title)
  open_worksheet(sheet, ws_value)
}


#' Open spreadsheet by key 
#'
#' Use key found in browser URL and return an object of class spreadsheet.
#'
#' @param key the key of a spreadsheet as it appears in browser URL.
#' @param visibility either "public" for public spreadsheets or "private" 
#' for private spreadsheets
#' 
#' @return Object of class spreadsheet.
#'
#' @note The visibility should be set to "public" only if the spreadsheet is
#' "Published to the web". This is different from setting the spreadsheet to "Public on the web"
#' in the visibility options in the sharing dialog of a Google Sheets file.
#'
#' @export
open_by_key <- function(key, visibility = "private") 
{
  the_url <- build_req_url("worksheets", key = key, visibility = visibility)
  
  req <- gsheets_GET(the_url)
  
  if(grepl("html", req$headers$`content-type`))
    stop("Please check visibility settings.")
  
  wsfeed <- gsheets_parse(req)
  wsfeed_list <- XML::xmlToList(wsfeed)
  
  ss <- spreadsheet()
  ss$sheet_id <- key
  ss$visibility <- visibility
  
  ss$updated <- wsfeed_list$updated
  ss$sheet_title <- wsfeed_list$title$text
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  
  # return list of worksheet objs
  ws_objs<- getNodeSet(wsfeed, "//ns:entry", c("ns" = default_ns),
                       function(x) make_ws_obj(x, ss$sheet_id))
  
  names(ws_objs) <- lapply(ws_objs, function(x) x$title)
  ss$ws_names <- names(ws_objs)
  ss$worksheets <- ws_objs
  ss
}


#' Open spreadsheet by url
#'
#' Use url of spreadsheet and return an object of class spreadsheet.
#'
#' @param url URL of spreadsheet as it appears in browser
#' @param visibility either "public" for public spreadsheets or "private" 
#' for private spreadsheets
#' 
#' @note This function assumes the longest character string separated by "/" in the url is the 
#' key of the spreadsheet.
#' @note The visibility should be set to "public" only if the spreadsheet is
#' "Published to the web". This is different from setting the spreadsheet to "Public on the web"
#' in the visibility options in the sharing dialog of a Google Sheets file.
#' 
#' @return Object of class spreadsheet
#'
#' This function only works for public spreadsheets.
#' This function extracts the key from the url and calls on 
#' \code{\link{open_by_key}}.
#' @export
open_by_url <- function(url, visibility = "private") 
{
  elements <- unlist(strsplit(url, "/"))
  
  key <- elements[which.max(nchar(elements))]
  
  # Further cleaning
  key1 <- sub(".*?key=", "", key)
  key2 <- sub("&.*", "", key1)
  
  open_by_key(key2, visibility)
}
