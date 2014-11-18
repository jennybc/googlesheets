# default namespace for querying xml feed returned by GET
default_ns = "http://www.w3.org/2005/Atom"

#' Get list of spreadsheets for authorized user
#'
#' Retrieve the names of spreadsheets owned by user.
#'
#' or \code{\link{authorize}}
#'
#' @export
list_spreadsheets <- function() {
  titles <- spreadsheets_info()$sheet_title
  titles
}


#' Open spreadsheet by title 
#'
#' Use spreadsheet title (as it appears in Google Drive) to get spreadsheet 
#' object.
#'
#' @param title the title of a spreadsheet.
#' @return Object of class spreadsheet. 
#' 
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
#' 
#' @export
open_spreadsheet <- function(title) {
  ssfeed_df <- spreadsheets_info() # return spreadsheet feed as data frame
  
  index <- match(title, ssfeed_df$sheet_title)
  if(is.na(index)) stop("Spreadsheet not found.")
  sheet_key <- ssfeed_df[index, "sheet_key"]
  
  the_url <- build_req_url("worksheets", key = sheet_key)
  req <- gsheets_GET(the_url)
  wsfeed <- gsheets_parse(req)
  
  wsfeed_list <- xmlToList(wsfeed)
  
  ss <- spreadsheet()
  ss$sheet_id <- sheet_key
  ss$sheet_title <- wsfeed_list$title$text
  ss$updated <- wsfeed_list$updated
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  
  ws_objs <- getNodeSet(wsfeed, "//ns:entry", c(ns = default_ns), 
                        function(x) fetch_ws(x, ss$sheet_id))
  
  names(ws_objs) <- lapply(ws_objs, function(x) x$title)
  ss$ws_names <- names(ws_objs)
  ss$worksheets <- ws_objs
  ss
}


#' The worksheets contained in Spreadsheet
#'
#' Get list of worksheet titles (order as it appears in Google Docs) 
#' contained in spreadsheet. 
#'
#' @param spreadsheet A spreadsheet object returned by \code{\link{open_spreadsheet}}
#' @return The titles of worksheets contained in spreadsheet. 
#'
#' This is a mini wrapper for spreadsheet$ws_names.
#' @export  
list_worksheets <- function(ss) {
  titles <- ss$ws_names
  titles
}


#' Open worksheet given worksheet title or index
#'
#' Use title or index of worksheet to retrieve object of class worksheet.
#'
#' @param ss Spreadsheet object containing worksheet
#' @param x chr string for title of worksheet or numeric for index of worksheet 
#' in spreadsheet
#' @return An object of class worksheet and number of rows and cols attribute.
#'  
#' @export
open_worksheet <- function(ss, x, vis = "private") {
  if(is.character(x)) {
    index <- match(x, names(ss$worksheets))
    
    if(is.na(index))
      stop("Worksheet not found.")
    
  } else {
    index <- x
  }
  
  ws <- ss$worksheets[[index]]
  worksheet_dim(ws, visibility = vis)
}


#' Open a worksheet from a spreadsheet at once
#' 
#' @param ss_name Spreadsheet title
#' @param ws_name Worksheet name
#'
#' @export
open_at_once <- function(ss_title, ws_name) {
  sheet <- open_spreadsheet(ss_title)
  open_worksheet(sheet, ws_name)
}


#' Add new worksheet to spreadsheet
#'
#' Add a new worksheet to spreadsheet, specify name, number of rows and cols.
#'
#' @param ss Spreadsheet object
#' @param name character string for name of new worksheet 
#' @param rows Number of rows
#' @param cols Number of columns
#' @param token Google token
#' 
#' @importFrom XML xmlNode
#' @importFrom XML toString.XMLNode
#' @importFrom httr POST
#' @importFrom httr status_code
#' @export
add_worksheet<- function(ss, title, rows, cols, token = get_google_token()) {
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", 
                    ss$sheet_id, "/private/full")
  
  the_body <- 
    xmlNode("entry", 
            namespaceDefinitions = c("http://www.w3.org/2005/Atom",
                                     gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("title", title),
            xmlNode("gs:rowCount", rows),
            xmlNode("gs:colCount", cols))
  
  auth <- gsheets_auth(token)
  
  req <- 
    POST(the_url, auth, add_headers("Content-Type" = "application/atom+xml"),
         body = toString.XMLNode(the_body))
  
  if(status_code(req) == 201)
    message(paste("Worksheet", title, "successfully created in Spreadsheet",
                  ss$sheet_title))
  else
    message("Bad Request, something wrong on client side.")
}


#' Delete worksheet from spreadsheet
#'
#' The worksheet and all of its data will be removed from spreadsheet.
#'
#' @param ss Spreadsheet object
#' @param ws Worksheet object
#' @importFrom httr DELETE
#' @importFrom httr status_code
#' @export
del_worksheet<- function(ss, ws) {
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", 
                    ss$sheet_id, "/private/full/", ws$id, "/version")
  
  auth <- gsheets_auth(get_google_token())
  req <- DELETE(the_url, auth)
  
  if(status_code(req) == 200)
    message(
      paste("Worksheet", ws$title, "successfully deleted from", ss$sheet_title))
  else 
    message("Bad Request, something wrong on client side.")
}


#' Get all values from a row.
#'
#' @param ws worksheet object returned by \code{\link{open_worksheet}}
#' @param row row
#' @return Vector of all values in row.
#' @importFrom XML getNodeSet
#' @export
get_row <- function(ws, row, vis = "private") {
  if(row > ws$rows)
    stop("Specified row exceeds the number of rows contained in worksheet.")
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = row, max_row = row, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  rows <- dlply(tbl, "row", check_missing) # insert NAs for missing values
  
  rbind.fill(lapply(rows, function(x) {as.data.frame(t(x), stringsAsFactors=FALSE)}))
}


#' Get rows of worksheet
#'
#' Specify range of rows to get from worksheet.
#'
#' @param ws worksheet object returned by \code{\link{open_worksheet}}
#' @param from,to start and end row indexes
#' @return Dataframe of requested rows. 
#' @importFrom XML getNodeSet
#' @importFrom plyr rbind.fill
#' @importFrom plyr dlply
#' @export
get_rows <- function(ws, from, to, vis = "private") {
  
  if(to > ws$rows)
    to <- ws$rows
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = from, max_row = to, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  rows <- dlply(tbl, "row", check_missing)
  
  rbind.fill(lapply(rows, function(x) 
  {as.data.frame(t(x), stringsAsFactors=FALSE)}))
}


#' Get all values from a column.
#'
#' @param ws worksheet object returned by \code{\link{open_worksheet}}
#' @param col column
#' @return Vector of all values in column
#' @importFrom XML getNodeSet
#' @export
get_col <- function(ws, col, vis = "private") {
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = col, max_col = col, visibility = vis)
  
  req <- gsheets_GET(the_url)
  
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  col_vals <- c()
  for(i in 1:max(tbl$row)) {
    
    if(any(tbl$row ==  i)) {
      ind <- which(tbl$row == i)
      col_vals <- c(col_vals, tbl[ind, "val"])
    } else {
      col_vals <- c(col_vals, NA) 
    }
    
  }
  col_vals
}


#' Get columns of worksheet
#'
#' Specify range of columns to get from worksheet.
#'
#' @param ws Worksheet object
#' @param from,to start and end column indexes
#' @return Dataframe of requested columns.
#' @examples
#' get_cols(ws, 1, 2)
#' get_cols(ws, 30, 40) 
#' @importFrom XML getNodeSet
#' @importFrom plyr dlply
#' @export
get_cols <- function(ws, from, to, vis = "private") {
  
  if(to > ws$cols) 
    to <- ws$cols
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = from, max_col = to, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  rows <- dlply(tbl, "row", check_missing)
  
  rbind.fill(lapply(rows, function(x) 
  {as.data.frame(t(x), stringsAsFactors=FALSE)}))
  
}


#' Get all values of worksheet as a dataframe
#'
#' Use worksheet object and turn it into a dataframe.
#'
#' @param ws Worksheet object 
#' @return A dataframe. 
#' 
#' This function calls on \code{\link{get_cols}} with to set as number of 
#' columns of the worksheet.
#' @export
get_dataframe <- function(ws, vis = "private") {
  get_cols(ws, 1, ws$cols, vis)
}


#' Get a region of a worksheet
#'
#' Extract cells of a worksheet according to specified range.
#'
#' @param ws Worksheet object
#' @param from_row,to_row range of rows to extract
#' @param from_col,to_col range of cols to extract
#' @param vis Either \code{private} or \code{public}
#' @return A dataframe.
#' @export
get_region <- function(ws, from_row, to_row, from_col, to_col, vis = "private") {
  
  if(to_row > ws$rows)
    to_row <- ws$rows
  
  if(to_col > ws$cols)
    to_col <- ws$cols
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = from_row, max_row = to_row,
                           min_col = from_col, max_col = to_col, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)

  tbl <- create_lookup_tbl(feed)
  
  rows <- dlply(tbl, "row_adj", check_missing)
  
  rbind.fill(lapply(rows, function(x) 
  {as.data.frame(t(x), stringsAsFactors=FALSE)}))
}
  


# Public spreadsheets only -----

#' Open spreadsheet by key 
#'
#' Use key found in browser URL and return an object of class spreadsheet.
#'
#' @param spreadsheet_key A key of a spreadsheet as it appears in browser URL.
#' @return Object of class spreadsheet.
#'
#' This function currently only works for keys of public spreadsheets.
#' @export
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
open_by_key <- function(key) {
  the_url <- build_req_url("worksheets", key = key, visibility = "public")
  
  req <- gsheets_GET(the_url)
  wsfeed <- gsheets_parse(req)
  wsfeed_list <- xmlToList(wsfeed)
  
  ss <- spreadsheet()
  ss$sheet_id <- key
  ss$updated <- wsfeed_list$updated
  ss$sheet_title <- wsfeed_list$title$text
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  
  # return list of worksheet objs
  ws_objs<- getNodeSet(wsfeed, "//ns:entry", c("ns" = default_ns),
                       function(x) fetch_ws(x, ss$sheet_id))
  
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
#' @return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets.
#' This function extracts the key from the url and calls on open_by_key().
#' @export
open_by_url <- function(url) {
  key <- unlist(strsplit(url, "/"))[6] # TODO: fix hardcoding
  open_by_key(key)
}


