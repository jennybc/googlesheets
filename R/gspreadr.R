# default namespace for querying xml feed returned by GET
default_ns = "http://www.w3.org/2005/Atom"

#' Get list of spreadsheets
#'
#' Retrieve the names of spreadsheets in Google drive.
#'
#' @export
list_spreadsheets <- function() 
{
  ssfeed_to_df()$sheet_title
}


#' Open spreadsheet by title 
#'
#' Use the spreadsheet title (as it appears in Google Drive) to get a 
#' spreadsheet object, containing the spreadsheet id, title, time of last 
#' update, the titles and number of worksheets contained, and a list of 
#' worksheet objects.
#'
#' @param title the title of a spreadsheet.
#' 
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
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
  
  wsfeed_list <- xmlToList(wsfeed)
  
  ws_objs <- getNodeSet(wsfeed, "//ns:entry", c(ns = default_ns), 
                        function(x) make_ws_obj(x, sheet_key))
  
  names(ws_objs) <- lapply(ws_objs, function(x) x$title)
  
  ss <- spreadsheet()
  ss$sheet_id <- sheet_key
  ss$sheet_title <- wsfeed_list$title$text
  ss$updated <- wsfeed_list$updated
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  ss$ws_names <- names(ws_objs)
  ss$worksheets <- ws_objs
  ss
}


#' Get list of worksheets contained in spreadsheet
#'
#' Retrieve list of worksheet titles (order as it appears in spreadsheet) 
#' contained in spreadsheet. 
#'
#' @param ss spreadsheet object returned by \code{\link{open_spreadsheet}}
#'
#' This is a mini wrapper around spreadsheet$ws_names.
#' @export  
list_worksheets <- function(ss) 
{
  ss$ws_names
}


#' Open worksheet given worksheet title or index
#'
#' Use title or index of worksheet to retrieve worksheet object.
#'
#' @param ss spreadsheet object containing worksheet
#' @param value a character string for title of worksheet or numeric for 
#' index of worksheet
#' @return A worksheet object with number of rows and cols component.
#' @examples
#' ws <- open_worksheet(ss, "Sheet1")
#' ws <- open_worksheet(ss, 1)
#' @export
open_worksheet <- function(ss, value, vis = "private") 
{
  if(is.character(value)) {
    index <- match(value, names(ss$worksheets))
    
    if(is.na(index))
      stop("Worksheet not found.")
    
  } else {
    index <- value
  }
  
  ws <- ss$worksheets[[index]]
  worksheet_dim(ws, visibility = vis)
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


#' Add a new worksheet to spreadsheet
#'
#' Add a new (empty) worksheet to spreadsheet, specify title, number of rows 
#' and columns.
#'
#' @param ss spreadsheet object
#' @param title character string for title of new worksheet 
#' @param nrow Number of rows
#' @param ncol Number of columns
#' @param token Google token obtained from \code{\link{login}} or 
#' \code{\link{authorize}}
#' 
#' @importFrom XML xmlNode
#' @importFrom XML toString.XMLNode
#' @importFrom httr POST
#' @importFrom httr status_code
#' @export
add_worksheet<- function(ss, title, nrow, ncol, token = get_google_token()) 
{   
  the_body <- 
    xmlNode("entry", 
            namespaceDefinitions = c("http://www.w3.org/2005/Atom",
                                     gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("title", title),
            xmlNode("gs:rowCount", nrow),
            xmlNode("gs:colCount", ncol))
  
  auth <- gsheets_auth(token)
  
  the_url <- build_req_url("worksheets", key = ss$sheet_id)
  
  req <- 
    POST(the_url, auth, add_headers("Content-Type" = "application/atom+xml"),
         body = toString.XMLNode(the_body))
  
  if(status_code(req) == 201)
    message(paste("Worksheet", title, "successfully created in Spreadsheet",
                  ss$sheet_title))
  else
    message("Bad Request, something wrong on client side.")
}


#' Delete a worksheet from spreadsheet
#'
#' The worksheet and all of its data will be removed from spreadsheet.
#'
#' @param ss spreadsheet object
#' @param ws worksheet object
#' @importFrom httr DELETE
#' @importFrom httr status_code
#' @export
del_worksheet<- function(ss, ws) 
{
  the_url <- build_req_url("worksheets", key = ss$sheet_id, ws_id = ws$id)
  
  auth <- gsheets_auth(get_google_token())
  req <- DELETE(the_url, auth)
  
  if(status_code(req) == 200)
    message(
      paste("Worksheet", ws$title, "successfully deleted from", ss$sheet_title))
  else 
    message("Bad Request, something wrong on client side.")
}


#' Get all values in a row
#'
#' Specify row of values to get from worksheet.
#'
#' @param ws worksheet object
#' @param row row
#' @param vis either "private" or "public", set to "public" for public for 
#' worksheets
#' @return A data frame. 
#' @seealso \code{\link{get_rows}}, \code{\link{get_col}}, 
#' \code{\link{get_cols}}, \code{\link{get_all}}, \code{\link{read_region}}
#' @importFrom plyr ddply
#' @export
get_row <- function(ws, row, vis = "private") 
{
  if(row > ws$nrow)
    stop("Specified row exceeds the number of rows contained in the worksheet.")
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = row, max_row = row, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  ddply(tbl, "row", check_missing)[-1] # to remove grouping var
}


#' Get all values in range of rows
#'
#' Specify range of rows to get from worksheet.
#'
#' @param ws worksheet object
#' @param from,to start and end row indexes
#' @return A data frame.
#' @seealso \code{\link{get_row}}, \code{\link{get_col}}, 
#' \code{\link{get_cols}}, \code{\link{get_all}}, \code{\link{read_region}}
#' @importFrom plyr dlply
#' @importFrom dplyr rbind_all
#' @importFrom plyr rbind.fill
#' @export
get_rows <- function(ws, from, to, header = FALSE, vis = "private")
{
  if(to > ws$nrow)
    to <- ws$nrow
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = from, max_row = to, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)

  list_of_vec <- dlply(tbl, "row", check_missing)
  
  list_of_df <- 
    lapply(list_of_vec, 
           function(x) as.data.frame(t(x), stringsAsFactors = FALSE))

  my_df <- rbind.fill(list_of_df)
  
  if(header) {
    set_header(my_df)
  } else {
    my_df
  }
  
  # doesnt work if rows of different length
  #ddply(tbl, "row", check_missing)[-1] # to remove grouping var
}


#' Get all values in a column.
#'
#' @param ws worksheet object
#' @param col column number or letter (case insensitive)
#' @param vis either "private" or "public"
#' @return A data frame.
#' @seealso \code{\link{get_cols}}, \code{\link{get_row}}, 
#' \code{\link{get_rows}}, \code{\link{get_all}}, \code{\link{read_region}}
#' @importFrom plyr ddply
#' @export
get_col <- function(ws, col, vis = "private") 
{
  if(!is.numeric(col)) 
    col <- letter_to_num(col)
  
  if(col > ws$ncol)
    stop("Column exceeds current worksheet size")
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = col, max_col = col, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  check_missing(tbl, by_col = FALSE)
}


#' Get all values in range of columns.
#'
#' Specify range of columns to get from worksheet.
#'
#' @param ws worksheet object
#' @param from,to start and end column indexes either integer or letter
#' @return A data frame.
#' @examples
#' get_cols(ws, 1, 2)
#' get_cols(ws, 30, 40)
#' 
#' get_cols(ws, "A", "B")
#' get_cols(ws, "c", "f")
#' @seealso \code{\link{get_col}}, \code{\link{get_row}}, 
#' \code{\link{get_rows}}, \code{\link{get_all}}, \code{\link{read_region}}
#' @importFrom plyr ddply
#' @export
get_cols <- function(ws, from, to, header = TRUE, vis = "private") 
{
  if(!is.numeric(from) & !is.numeric(to)) {
    from <- letter_to_num(from)
    to <- letter_to_num(to)
  }
  
  if(to > ws$ncol) 
    to <- ws$ncol
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = from, max_col = to, visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  list_of_vec <- dlply(tbl, "row", check_missing)
  
  list_of_df <- 
    lapply(list_of_vec, 
           function(x) as.data.frame(t(x), stringsAsFactors = FALSE))
  
  my_df <- rbind.fill(list_of_df)
  
  if(header) {
    set_header(my_df)
  } else {
    my_df
  }
  
  # doesnt work if cols of diff length
  # ddply(tbl, "row", check_missing)[-1] # to remove grouping var
}


#' Get the value of a cell
#'
#' Get the value of a cell using label (A1) notation or coordinate (R1C1) 
#' notation.
#'
#' @param ws worksheet object
#' @param cell character string specifying cell position, 
#' either in label or coordinate notation
#' @return The value of the cell as a character string. 
#' @examples
#' get_cell(ws, "A1")
#' get_cell(ws, "R1C1")
#' get_cell(ws, "AB1")
#' get_cell(ws, "R1C27")
#' @export
get_cell <- function(ws, cell)
{
  if(grepl("[R][[:digit:]]+[C][[:digit:]]+", cell)) {
    cell
  } else {
    if(grepl("^[[:alpha:]]+[[:digit:]]+$", cell)) {
      cell <- label_to_coord(cell)
    } else {
      stop("Please check cell notation.")
    }
  }
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id)
  new_url <- paste(the_url, cell, sep = "/")
  
  system.time(req <- gsheets_GET(new_url))
  feed <- gsheets_parse(req)
  
  cell_val <- 
    getNodeSet(feed, "//ns:entry//gs:cell", c("ns" = default_ns, "gs"),
               xmlValue)
  unlist(cell_val)
}


#' Get all values in a worksheet.
#'
#' Extract the entire worksheet and turn it into a data frame. This function
#' uses the rightmost cell with value as the max columns and bottom most 
#' cell as max row.
#'
#' @param ws worksheet object 
#' @param header logical for if first row should be taken as header
#' @param vis either "private" or "public"
#' @return A dataframe. 
#' 
#' This function calls on \code{\link{get_cols}} with to set as number of 
#' columns of the worksheet.
#' @seealso \code{\link{read_region}}, \code{\link{get_row}}, 
#' \code{\link{get_rows}}, \code{\link{get_col}}, \code{\link{get_cols}}
#' @export
get_all <- function(ws, header = TRUE, vis = "private") 
{
  get_cols(ws, 1, ws$ncol, header, vis = vis)
}


#' Get a region of a worksheet by min/max rows and columns
#'
#' Extract cells of a worksheet according to specified range. If range is beyond
#' the dimensions of the worksheet, the boundary will be used as range.
#'
#' @param ws Worksheet object
#' @param from_row,to_row range of rows to extract
#' @param from_col,to_col range of cols to extract
#' @param vis Either \code{private} or \code{public}
#' @return A data frame.
#' @seealso \code{\link{get_all}}, \code{\link{get_row}}, \code{\link{get_rows}},
#' \code{\link{get_col}}, \code{\link{get_cols}}
#' @importFrom plyr ddply
#' @export
read_region <- function(ws, from_row, to_row, from_col, to_col, header = TRUE, 
                        vis = "private")
{
  if(to_row > ws$nrow)
    to_row <- ws$nrow
  
  if(to_col > ws$ncol)
    to_col <- ws$ncol
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = from_row, max_row = to_row,
                           min_col = from_col, max_col = to_col, 
                           visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  my_df <- ddply(tbl, "row_adj", check_missing)[-1] # to remove grouping var
  
  if(header) {
    set_header(my_df)
  } else {
    my_df
  }
}


#' Get a region of a worksheet by range
#'
#' 
#' @param ws Worksheet object
#' @param x character string for range separated by ":"
#' @param header \code{logical} for whether or not first row should be taken as 
#' header
#' @param vis either "private" (default) or "public" for public spreadsheets
#' @examples
#' read_range("A1:B10")
#' read_range("C10:D20")
#' @importFrom plyr ddply
#' @export
read_range <- function(ws, x, header = TRUE, vis = "private") {
  
  if(!grepl("[[:alpha:]]+[[:digit:]]+:[[:alpha:]]+[[:digit:]]+", x)) 
    stop("Please check cell notation.")
  
  bounds <- unlist(strsplit(x, split = ":"))
  rows <- as.numeric(gsub("[^0-9]", "", bounds))  
  cols <- unname(sapply(gsub("[^A-Z]", "", bounds), letter_to_num))
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = rows[1], max_row = rows[2],
                           min_col = cols[1], max_col = cols[2], 
                           visibility = vis)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  my_df <- ddply(tbl, "row_adj", check_missing)[-1] # to remove grouping var
  
  if(header) 
    set_header(my_df)
  else
    my_df
  
}


#' Get a list of worksheet objects
#'
#' This list enables \code{plyr} functions to operate on mutiple worksheets at once.
#' 
#' @param ss spreadsheet object
#' @importFrom plyr llply
#' @export
list_worksheet_objs <- function(ss) 
{
  llply(ss$worksheets, function(x) open_worksheet(ss, x$title))
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
#' @return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets.
#' This function extracts the key from the url and calls on open_by_key().
#' @export
open_by_url <- function(url) {
  key <- unlist(strsplit(url, "/"))[6] # TODO: fix hardcoding
  open_by_key(key)
}

