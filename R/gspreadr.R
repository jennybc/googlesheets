# default namespace for querying xml feed returned by GET
default_ns = "http://www.w3.org/2005/Atom"

#' Get list of spreadsheets for authenticated user
#'
#' Retrive list of spreadsheets
#'
#' @param client Object of class client returned by \code{\link{login}}
#' @return Dataframe of spreadsheet titles.
#'
#' @export
list_spreadsheets <- function(client) {
  titles <- spreadsheets_info(client)$sheet_title
  titles
}

#' Open spreadsheet by title 
#'
#' Use title of spreadsheet to retrieve object of class spreadsheet.
#'
#' @param client Client object returned by \code{\link{login}}
#' @param title title of spreadsheet
#' @return Object of class spreadsheet.
#' @export
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
open_spreadsheet <- function(client, title) {
  
  ss_feed <- spreadsheets_info(client) # returns dataframe of spreadsheet feed info
  
  index <- match(title, ss_feed$sheet_title)
  
  if(is.na(index)) stop("Spreadsheet not found.")
  
  sheet_key <- ss_feed[index, "sheet_key"]
  
  req <- gsheets_GET("worksheets", client, sheet_key)
  
  ws_feed <- gsheets_parse(req)
  ws_feed_list <- xmlToList(ws_feed)
  
  ss <- spreadsheet()
  ss$sheet_id <- sheet_key
  ss$updated <- ws_feed_list$updated
  ss$sheet_title <- ws_feed_list$title[[1]]
  ss$nsheets <- as.numeric(ws_feed_list$totalResults)
  
  ws_nodes <- getNodeSet(ws_feed, "//ns:entry", c(ns = default_ns))
  
  # get values for all worksheet elements stored in entry node
  # returns list of worksheet objects
  ws_list <- lapply(ws_nodes, fetch_ws)
  
  ws_list2 <- lapply(ws_list, function(x) {x$sheet_id <- ss$sheet_id ; x})
  
  names(ws_list2) <- lapply(ws_list2, function(x) x$title)
  
  ss$ws_names <- names(ws_list2)
  ss$worksheets <- ws_list2
  
  ss
}

#' Get the titles of the worksheets contained in spreadsheet.
#'
#' Retrieve list of worksheet titles contained in spreadsheet 
#'
#' @param x A spreadsheet object returned by \code{\link{open_spreadsheet}}
#' @return The titles of worksheets contained in spreadsheet. 
#'
#' This is a mini wrapper for x$ws_names.
#' @export  
list_worksheets <- function(x) {
  titles <- x$ws_names
  titles
}

#' Open worksheet given worksheet title
#'
#' Use title of worksheet to retrieve object of class spreadsheet.
#'
#' @param spreadsheet Spreadsheet object housing the desired worksheet
#' @param title title of worksheet to retrieve
#' @return An object of class worksheet. 
#' @export
get_worksheet <- function(spreadsheet, title) {
  # find index of specified worksheet
  index <- match(title, names(spreadsheet$worksheets))
  
  if(is.na(index))
    stop("Worksheet not found.")
  
  ws <- spreadsheet$worksheets[[index]]
  ws
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
get_dataframe <- function(ws, client = NULL) {
  #since making another API call, must pass in client 
  if(!is.null(client))
    req <- gsheets_GET("cells", client, ws$sheet_id, ws$id)
  else
    req <- 
    gsheets_GET("cells", client, ws$sheet_id, ws$id, visibility = "public")
  
  cellsfeed <- gsheets_parse(req)
  cell_nodes <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", c("ns" = default_ns, "gs"))
  
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
#' @param sheet Spreadsheet object
#' @param client Client object
#' @param name character string for name of new worksheet 
#' @param n_row Number of rows
#' @param n_col Number of columns
#' @export
#' @importFrom XML xmlNode
#' @importFrom httr POST
#' @importFrom httr status_code
add_worksheet<- function(client, sheet, name, n_row, n_col) {
  
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", 
                    sheet$sheet_id, "/private/full")
  
  the_body <- xmlNode("entry", 
                      namespaceDefinitions = c("http://www.w3.org/2005/Atom",
                                               gs = "http://schemas.google.com/spreadsheets/2006"),
                      xmlNode("title", name),
                      xmlNode("gs:rowCount", n_row),
                      xmlNode("gs:colCount", n_col))
  
  auth <- gsheets_auth(client)
  
  req <- 
    POST(the_url, auth, add_headers("Content-Type" = "application/atom+xml"),
         body = toString(the_body))
  
  if(status_code(req) == 201)
    message(paste("Worksheet", name, "successfully created in Spreadsheet",
                  sheet$sheet_title))
  else
    message("Bad Request, something wrong on client side.")
}


#' Delete worksheet from spreadsheet
#'
#' Delete worksheet, worksheet and all of its data will be removed from spreadsheet.
#'
#' @param client Client object
#' @param ws Worksheet object
#' @export
del_worksheet<- function(client, ws) {
  
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", 
                    ws$sheet_id, "/private/full/", ws$id, "/version")
  
  auth <- gsheets_auth(client)
  
  req <- DELETE(the_url, auth)
  
  if(status_code(req) == 200)
    message(paste("Worksheet", ws$title, "successfully deleted."))
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
#' This function currently only works for public spreadsheets (visibility = TRUE and projection = FULL).
#' @export
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
open_by_key <- function(key) {
  req <- gsheets_GET("worksheets", key = key, visibility = "public")
  
  # parse response to get worksheets feed
  ws_feed <- gsheets_parse(req)
  
  # convert to list
  ws_feed_list <- xmlToList(ws_feed)
  
  ss <- spreadsheet()
  
  ss$sheet_id <- key
  ss$updated <- ws_feed_list$updated
  ss$sheet_title <- ws_feed_list$title[[1]]
  ss$nsheets <- as.numeric(ws_feed_list$totalResults)
  
  # return list of entry nodes
  ws_nodes <- getNodeSet(ws_feed, "//ns:entry", c("ns" = default_ns))
  
  # get values for all worksheet elements stored in entry node
  # returns list of worksheet objects
  ws_list <- lapply(ws_nodes, fetch_ws)
  
  ws_list2 <- lapply(ws_list, function(x) {x$sheet_id <- ss$sheet_id ; x})
  
  names(ws_list2) <- lapply(ws_list2, function(x) x$title)
  
  ss$ws_names <- names(ws_list2)
  ss$worksheets <- ws_list2
  
  ss
}

#' Open spreadsheet by url
#'
#' Use url of spreadsheet and return an object of class spreadsheet.
#'
#' @param url URL of spreadsheet as it appears in browser
#' @return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets (visibility = TRUE and projection = FULL).
#' This function extracts the key from the url and calls on open_by_key().
#' @export
open_by_url <- function(url) {
  # extract key from url 
  key <- unlist(strsplit(url, "/"))[6] # TODO: fix hardcoding
  open_by_key(key)
}


# INTERNAL HELPERS -----

#' Retrieve worksheet object from worksheets feed 
#' store info from <entry> ... </entry>
#' @importFrom XML xmlName
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
#' @importFrom XML xmlApply
#' @importFrom XML xmlGetAttr
fetch_ws <- function(node) {
  # check if node is entry node (represents worksheet)
  if(xmlName(node) != "entry")
    stop("Node is not 'entry'.")
  
  feed_list <- xmlToList(node)
  
  listfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#listfeed']", "ns")
  cellsfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']", "ns")
  ws_listfeed <- unlist(xmlApply(listfeed, function(x) xmlGetAttr(x, "href")))
  ws_cellsfeed <- unlist(xmlApply(cellsfeed, function(x) xmlGetAttr(x, "href")))
  
  ws <- worksheet()
  
  ws$id <- unlist(strsplit(feed_list$id, "/"))[[9]]
  ws$title <- (feed_list$title)$text
  ws$listfeed <- ws_listfeed
  ws$cellsfeed <- ws_cellsfeed
  
  ws
}

#' Get list of spreadsheets: title, last updated, and key
#'
#' Retrieve dataframe of spreadsheets information
#'
#' @param client Client object returned by \code{\link{login}} or 
#' \code{\link{authorize}}
#' @return A dataframe containing title of spreadsheets, last updated, and uris for worksheets feed.
#' @importFrom XML xmlApply
#' @importFrom XML xmlValue
#' @importFrom XML xmlGetAttr
spreadsheets_info <- function(client) {
  req <- gsheets_GET("spreadsheets", client)
  
  ss_feed <- gsheets_parse(req)
  
  ss_titles <- getNodeSet(ss_feed, "//ns:entry//ns:title", c("ns" = default_ns))
  ss_updated <- getNodeSet(ss_feed, "//ns:entry//ns:updated", c("ns" = default_ns))
  ss_ws_feed <- getNodeSet(ss_feed, "//ns:link[@rel='http://schemas.google.com/spreadsheets/2006#worksheetsfeed']", c("ns" = default_ns))
  
  ss_titles <- unlist(xmlApply(ss_titles, xmlValue))
  ss_updated <- unlist(xmlApply(ss_updated, xmlValue))
  ss_ws_feed <- unlist(xmlApply(ss_ws_feed, function(x) xmlGetAttr(x, "href")))
  
  clean1 <- sub(".*worksheets/", "", ss_ws_feed)
  ssheet_key <- sub("/.*", "", clean1)
  
  sheets_data <- data.frame(sheet_title = ss_titles,
                            last_updated = ss_updated,
                            sheet_key = ssheet_key,
                            stringsAsFactors = FALSE)
  sheets_data
}

#' @importFrom XML xmlInternalTreeParse
gsheets_parse <- function(req) {
  xmlInternalTreeParse(req)
}

