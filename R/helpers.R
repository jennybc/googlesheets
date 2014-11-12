# default namespace for querying xml feed returned by GET
default_ns = "http://www.w3.org/2005/Atom"

#' Create GET request
#'
#' Construct GET requests to Google Sheets API. This function handles the 
#' construction of urls and making GET requests so urls arent lying around.
#'
#'@param feed_type One of the following: spreadsheets, worksheets, list, cells
#'@param client Client object or NULL if accessing public worksheets feed
#'@param key Spreadsheet key
#'@param worksheet_id id of worksheet contained in spreadsheet
#'@param visibility Either private or public
#'@param projection Either full or basic
#'@importFrom httr GET
#'@importFrom httr stop_for_status
#'@examples
#'gsheets_GET("spreadsheets", NULL, 
#'"1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-cmEaZU", visibility = "public")

gsheets_GET <- function(feed, client = NULL, key = NULL,
                        ws_id = NULL, visibility = "private", 
                        projection = "full", min_row = NULL, max_row = NULL, 
                        min_col = NULL, max_col = NULL)
{
  base_url <- "https://spreadsheets.google.com/feeds"
  
  switch(
    feed,
    spreadsheets = {
      the_url <- paste(base_url, feed, visibility, projection, sep = "/")
    },
    worksheets = {
      the_url <- paste(base_url, feed, key, visibility, projection, sep = "/")
    },
    list = {
      the_url <- paste(base_url, feed, key, ws_id, visibility, projection , sep = "/")
    },
    cells = {
      the_url <- paste(base_url, feed, key, ws_id, visibility, projection, sep = "/")
    },
    cells_query = {
      base_url <- paste(base_url, "cells", key, ws_id, visibility, projection, sep = "/")
      
      if(is.null(min_col)) {
        query <- paste0("?min-row=", min_row, "&max-row=", max_row)
      } else {
        query <- paste0("?min-col=", min_col, "&max-col=", max_col)
      }
      
      the_url <- paste0(base_url, query)
    }
  )
  
  if(!is.null(client))
    auth <- gsheets_auth(client)
  else 
    auth <- NULL
  
  req <- GET(the_url, auth)
  stop_for_status(req)
  req
}

#' Check if client is using Google login or oauth2.0
#' 
#' @param client Client object
#' @importFrom httr config
#' @importFrom httr add_headers
gsheets_auth <- function(client) {
  if(class(client$auth) != "character")
    auth <- config(token = client$auth)
  else 
    auth <- add_headers('Authorization' = client$auth)
}


#' Check status of http response
#' 
#' Google returns status 200 (success) or 403 (failure), show error msg if 403.
#' 
#' @param req response from \code{\link{gsheets_GET}} request
#' @importFrom httr status_code
#' @importFrom httr content
gsheets_check <- function(req) {
  if(status_code(req) == 403) {
    if(grepl("BadAuthentication", content(req)))
      stop("Incorrect username or password.")
    else
      stop("Unable to authenticate")
  }
}

#' Wrapper around xmlInternalTreeParse
#'
#' @param req response from \code{\link{gsheets_GET}} request
#' @importFrom XML xmlInternalTreeParse
gsheets_parse <- function(req) {
  xmlInternalTreeParse(req)
}



#' Retrieve worksheet object from worksheets feed
#' 
#' Store worksheet info (spreadsheet id, worksheet id, worksheet title, 
#' listfeed and cellfeed uris) from entry nodes
#' 
#' @importFrom XML xmlName
#' @importFrom XML xmlToList
#' @importFrom XML getNodeSet
#' @importFrom XML xmlApply
#' @importFrom XML xmlGetAttr
fetch_ws <- function(node, sheet_id) {
  nodes_list <- xmlToList(node)
  
  listfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#listfeed']", "ns",
                         function(x) xmlGetAttr(x, "href"))
  cellsfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']", "ns",
                          function(x) xmlGetAttr(x, "href"))
  
  ws <- worksheet()
  ws$sheet_id <- sheet_id
  ws$id <- unlist(strsplit(nodes_list$id, "/"))[[9]]
  ws$title <- (nodes_list$title)$text
  ws$listfeed <- listfeed
  ws$cellsfeed <- cellsfeed
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

#' Find number of rows and columns of worksheet
#' 
#' Get the rows and columns of worksheet by making a request for cellfeed, hence 
#' client object is required if accessing private spreadsheet.
#' 
#'@param client Client object
#'@param ws Worksheet object
#'@importFrom XML getNodeSet
#'@importFrom XML xmlApply
#'@importFrom XML xmlGetAttr
worksheet_dim <- function(client = NULL, ws) {
  if(is.null(client)) {
    req <- gsheets_GET("cells", client, key = ws$sheet_id, ws_id = ws$id, 
                       visibility = "public")
  } else {
    req <- gsheets_GET("cells", client, key = ws$sheet_id, ws_id = ws$id)
  }
  
  feed <- gsheets_parse(req)
  
  #check for any entry nodes
  cell_nodes <- getNodeSet(feed, "//ns:feed//ns:entry", c("ns" = default_ns))
  
  if(length(cell_nodes) == 0) {
    dims <- getNodeSet(feed, "//ns:feed//gs:*", c("ns" = default_ns, "gs"), xmlValue)
    ws$rows <- as.numeric(dims[[1]])
    ws$cols <- as.numeric(dims[[2]])
  } else {
    cell_row_num <- getNodeSet(feed, "//ns:entry//gs:*", c("ns" = default_ns, "gs"),
                               function(x) as.numeric(xmlGetAttr(x, "row")))
    
    cell_col_num <- getNodeSet(feed, "//ns:entry//gs:*", c("ns" = default_ns, "gs"),
                               function(x) as.numeric(xmlGetAttr(x, "col")))
    
    ws$rows <- max(unlist(cell_row_num))
    ws$cols <- max(unlist(cell_col_num))
  }
  
  ws
}

#' Create lookup table for cell indices and its values 
#'
#' Convert cell row and col attributes stored in entry nodes, along with 
#' input values into a single data frame and serve as a lookup table for 
#' further processing.
#'
#' @param cellsfeed Cell based feed parsed with  \code{\link{gsheets_parse}} 
#' @return A data frame with cell row and col number and corresponding input value.
#' @importFrom XML getNodeSet
#' @importFrom XML xmlAttrs
#' @importFrom XML xmlValue
create_lookup_tbl <- function(cellsfeed) {
  val <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", c("ns" = default_ns, "gs"), xmlValue)
  
  row_num <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", c("ns" = default_ns, "gs"),
                        function(x) as.numeric(xmlAttrs(x)["row"]))
  
  col_num <-  getNodeSet(cellsfeed, "//ns:entry//gs:cell", c("ns" = default_ns, "gs"),
                         function(x) as.numeric(xmlAttrs(x)["col"]))
  
  lookup_tbl <- data.frame(row = unlist(row_num), 
                           col = unlist(col_num), 
                           val = unlist(val),
                           stringsAsFactors = FALSE)
  lookup_tbl
}

#' Check for missing cells in row or column 
#'
#' Loop through cell indices and substitute NA for missing cell values. 
#'
#' @param x data frame returned from \code{\link{create_lookup_tbl}} 
#' @return A vector of values contained in row with NAs for missing values.
check_missing <-function(x) {
  row_vals <- c()
  xx <- x$col
  
  for(i in 1:max(xx)) {
    
    if(any(xx ==  i)) {
      ind <- which(xx == i)
      row_vals <- c(row_vals, x[ind, "val"])
    } else {
      row_vals <- c(row_vals, NA) 
    }
    
  }
  row_vals
}

