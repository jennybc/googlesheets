# default namespace for querying xml feed returned by GET
default_ns = "http://www.w3.org/2005/Atom"

#' Get list of spreadsheets for authenticated user
#'
#' Retrieve the names of spreadsheets owned by user.
#'
#' @param client a client object returned by \code{\link{login}} 
#' or \code{\link{authorize}}
#'
#' @export
list_spreadsheets <- function(client) {
  titles <- spreadsheets_info(client)$sheet_title
  titles
}

#' Open spreadsheet by title 
#'
#' Use title of spreadsheet to get object of class spreadsheet.
#'
#' @param client a client object returned by \code{\link{login}} 
#' or \code{\link{authorize}}.
#' @param title the title of a spreadsheet.
#' @return Object of class spreadsheet. 
#' 
#' @export
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
open_spreadsheet <- function(client, title) {
  ssfeed_df <- spreadsheets_info(client) # return spreadsheet feed info df
  
  index <- match(title, ssfeed_df$sheet_title)
  if(is.na(index)) stop("Spreadsheet not found.")
  sheet_key <- ssfeed_df[index, "sheet_key"]
  
  req <- gsheets_GET("worksheets", client, sheet_key) # get # of ws and ws names
  wsfeed <- gsheets_parse(req)
  wsfeed_list <- xmlToList(wsfeed)
  
  ss <- spreadsheet()
  ss$sheet_id <- sheet_key
  ss$sheet_title <- wsfeed_list$title$text
  ss$updated <- wsfeed_list$updated
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  
  ws_nodes <- getNodeSet(wsfeed, "//ns:entry", c(ns = default_ns))
  ws_objs <- lapply(ws_nodes, fetch_ws)
  ws_objs <- lapply(ws_objs, function(x) {x$sheet_id <- ss$sheet_id ; x})
  
  names(ws_objs) <- lapply(ws_objs, function(x) x$title)
  ss$ws_names <- names(ws_objs)
  ss$worksheets <- ws_objs
  ss
}

#' The worksheets contained in Spreadsheet
#'
#' Get list of worksheet titles contained in spreadsheet. 
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

#' Open worksheet given worksheet title
#'
#' Use title of worksheet to retrieve object of class worksheet.
#'
#' @param client Client object 
#' @param ss Spreadsheet object containing worksheet
#' @param title title of worksheet to retrieve
#' @return An object of class worksheet and number of rows and cols attribute. 
#' @export
get_worksheet <- function(client = NULL, ss, title) {
  # find index of specified worksheet
  index <- match(title, names(ss$worksheets))
  
  if(is.na(index))
    stop("Worksheet not found.")
  
  ws <- ss$worksheets[[index]]
  worksheet_dim(client, ws)
}


#' Get worksheet object as a dataframe
#'
#' Use worksheet object and turn it into a dataframe.
#'
#' @param client Client object
#' @param ws Worksheet object 
#' @return A dataframe. 
#' @export
#' @importFrom XML getNodeSet
#' @importFrom XML xmlSApply
#' @importFrom XML xmlAttrs
get_dataframe <- function(client = NULL, ws) {
  #since making another API call, must pass in client 
  if(is.null(client))
    req <- gsheets_GET("cells", key = ws$sheet_id, ws_id = ws$id,
                       visibility = "public") 
  else
    req <- req <- gsheets_GET("cells", client, ws$sheet_id, ws$id)
  
  cellsfeed <- gsheets_parse(req)
  cell_nodes <- getNodeSet(cellsfeed, "//ns:entry//gs:cell",
                           c("ns" = default_ns, "gs"))
  
  vals <- xmlSApply(cell_nodes, xmlValue)
  
  # calculate index for last node to get ncol and nrow
  last_node <- unlist(tail(cell_nodes, n=1))
  dat <- unlist(lapply(last_node, xmlAttrs))
  
  n_row <- as.numeric(dat[1])
  n_col <- as.numeric(dat[2])
  
  my_data <- data.frame(matrix(vals, nrow = n_row, ncol = n_col, byrow = TRUE),
                        row.names = NULL)
  
  names(my_data) <- vals[1:n_col]
  my_data <- my_data[-1, ]
  
  row.names(my_data) <- NULL
  
  my_data
}

#' Add new worksheet to spreadsheet
#'
#' Add a new worksheet to spreadsheet, specify name, number of rows and cols.
#'
#' @param client Client object
#' @param ss Spreadsheet object
#' @param name character string for name of new worksheet 
#' @param rows Number of rows
#' @param cols Number of columns
#' @export
#' @importFrom XML xmlNode
#' @importFrom XML toString.XMLNode
#' @importFrom httr POST
#' @importFrom httr status_code
add_worksheet<- function(client, ss, name, rows, cols) {
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", 
                    ss$sheet_id, "/private/full")
  
  the_body <- 
    xmlNode("entry", 
            namespaceDefinitions = c("http://www.w3.org/2005/Atom",
                                     gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("title", name),
            xmlNode("gs:rowCount", rows),
            xmlNode("gs:colCount", cols))
  
  auth <- gsheets_auth(client)
  
  req <- 
    POST(the_url, auth, add_headers("Content-Type" = "application/atom+xml"),
         body = toString.XMLNode(the_body))
  
  if(status_code(req) == 201)
    message(paste("Worksheet", name, "successfully created in Spreadsheet",
                  ss$sheet_title))
  else
    message("Bad Request, something wrong on client side.")
}

#' Delete worksheet from spreadsheet
#'
#' Delete worksheet, worksheet and all of its data will be removed from spreadsheet.
#'
#' @param client Client object
#' @param ss Spreadsheet object
#' @param ws Worksheet object
#' @importFrom httr DELETE
#' @importFrom httr status_code
#' @export
del_worksheet<- function(client, ss, ws) {
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", 
                    ss$sheet_id, "/private/full/", ws$id, "/version")
  
  auth <- gsheets_auth(client)
  req <- DELETE(the_url, auth)
  
  if(status_code(req) == 200)
    message(paste("Worksheet", ws$title, "successfully deleted from", ss$sheet_title))
  else 
    message("Bad Request, something wrong on client side.")
}

# Public worksheets only -----

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
  req <- gsheets_GET("worksheets", key = key, visibility = "public")
  
  wsfeed <- gsheets_parse(req)
  wsfeed_list <- xmlToList(wsfeed)
  
  ss <- spreadsheet()
  ss$sheet_id <- key
  ss$updated <- wsfeed_list$updated
  ss$sheet_title <- wsfeed_list$title$text
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  
  # return list of entry nodes
  ws_nodes <- getNodeSet(wsfeed, "//ns:entry", c("ns" = default_ns))
  
  ws_objs <- lapply(ws_nodes, fetch_ws)
  ws_objs <- lapply(ws_objs, function(x) {x$sheet_id <- ss$sheet_id ; x})
  
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
  # extract key from url 
  key <- unlist(strsplit(url, "/"))[6] # TODO: fix hardcoding
  open_by_key(key)
}

# HELPERS -----

#' Retrieve worksheet object from worksheets feed 
#' store info from <entry> ... </entry>
#' @importFrom XML xmlName
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
#' @importFrom XML xmlApply
#' @importFrom XML xmlGetAttr
fetch_ws <- function(node) {
  nodes_list <- xmlToList(node)
  
  listfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#listfeed']", "ns")
  cellsfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']", "ns")
  ws_listfeed <- unlist(xmlApply(listfeed, function(x) xmlGetAttr(x, "href")))
  ws_cellsfeed <- unlist(xmlApply(cellsfeed, function(x) xmlGetAttr(x, "href")))
  
  ws <- worksheet()
  ws$id <- unlist(strsplit(nodes_list$id, "/"))[[9]]
  ws$title <- (nodes_list$title)$text
  ws$listfeed <- ws_listfeed
  ws$cellsfeed <- ws_cellsfeed
  ws
}

#' Get information from spreadsheets feed 
#'
#' Get spreadsheets titles, keys, and date/time of last update.
#'
#' @param client Client object returned by \code{\link{login}} or 
#' \code{\link{authorize}}
#' @importFrom XML xmlApply
#' @importFrom XML xmlValue
#' @importFrom XML xmlGetAttr
spreadsheets_info <- function(client) {
  req <- gsheets_GET("spreadsheets", client)
  ssfeed <- gsheets_parse(req)
  
  ss_titles <- getNodeSet(ssfeed, "//ns:entry//ns:title", c("ns" = default_ns))
  ss_updated <- getNodeSet(ssfeed, "//ns:entry//ns:updated", c("ns" = default_ns))
  ss_wsfeed <- getNodeSet(ssfeed, "//ns:link[@rel='http://schemas.google.com/spreadsheets/2006#worksheetsfeed']", c("ns" = default_ns))
  
  ss_titles <- unlist(xmlApply(ss_titles, xmlValue))
  ss_updated <- unlist(xmlApply(ss_updated, xmlValue))
  ss_wsfeed <- unlist(xmlApply(ss_wsfeed, function(x) xmlGetAttr(x, "href")))
  
  ss_key_pre <- sub(".*worksheets/", "", ss_wsfeed)
  ss_key <- sub("/.*", "", ss_key_pre)
  
  ssdata_df <- data.frame(sheet_title = ss_titles,
                            last_updated = ss_updated,
                            sheet_key = ss_key,
                            stringsAsFactors = FALSE)
  ssdata_df
}

#'Given client, worksheet object and spreadsheet id, find nrows and ncols of worksheet
#'need client because making a request for cellfeed
#'@param client Client object
#'@param ws Worksheet object
#'@importFrom XML getNodeSet
#'@importFrom XML xmlApply
#'@importFrom XML xmlGetAttr
worksheet_dim <- function(client = NULL, ws) {
  if(is.null(client))
    req <- gsheets_GET("cells", client, key = ws$sheet_id, ws_id = ws$id, 
                       visibility = "public")
  else
    req <- gsheets_GET("cells", client, key = ws$sheet_id, ws_id = ws$id)
  
  feed <- gsheets_parse(req)
  nodes <- getNodeSet(feed, "//ns:entry//gs:*", c("ns" = default_ns, "gs"))
  
  cell_row_num <- xmlSApply(nodes, 
                            function(x) as.numeric(xmlGetAttr(x, "row")))
  
  cell_col_num <- xmlSApply(nodes, 
                            function(x) as.numeric(xmlGetAttr(x, "col")))
  
  # returns warning for -Inf because cellfeed is empty when retrieving from empty worksheet
  ws$rows <- max(unlist(cell_row_num))
  ws$cols <- max(unlist(cell_col_num))
  ws
}

