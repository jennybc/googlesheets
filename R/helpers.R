# default namespace for querying xml feed returned by gsheets_GET
default_ns = "http://www.w3.org/2005/Atom"

#' Build URL for GET requests
#'
#' Construct URL for talking to Google Sheets API. 
#'
#'@param feed_type One of the following: spreadsheets, worksheets, list, cells
#'@param key Spreadsheet key
#'@param ws_id id of worksheet contained in spreadsheet
#'@param visibility Either private or public
#'@param projection Either full or basic
#'@return URL
build_req_url <- function(feed_type, key = NULL, ws_id = NULL, 
                          visibility = "private", projection = "full", 
                          min_row = NULL, max_row = NULL, 
                          min_col = NULL, max_col = NULL) {
  base_url <- "https://spreadsheets.google.com/feeds"
  
  switch(
    feed_type,
    spreadsheets = {
      the_url <- paste(base_url, feed_type, visibility, projection, sep = "/")
    },
    worksheets = {
      the_url <- paste(base_url, feed_type, key, visibility, projection, sep = "/")
    },
    list = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, projection , sep = "/")
    },
    cells = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, projection, sep = "/")
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
  the_url
}


#' Create GET request
#'
#' Make GET request to Google Sheets API.
#'
#' @param url URL for GET request
#' @param auth Google auth token obtained from \code{\link{login}} 
#' or \code{\link{authorize}} 
#' @importFrom httr GET
#' @importFrom httr stop_for_status
gsheets_GET <- function(url, token = get_google_token()) { 
  
  if(is.null(token)) {
    req <- GET(url)
  } else {
    req <- GET(url, gsheets_auth(token))
  }
  stop_for_status(req)
  req
}


#' Check if client is using Google login or oauth2.0
#' 
#' @param client Client object
#' @importFrom httr config
#' @importFrom httr add_headers
gsheets_auth <- function(token) {
  if(class(token) != "character")
    auth <- config(token = .state$token)
  else 
    auth <- add_headers('Authorization' = .state$token)
}


#' Wrapper around xmlInternalTreeParse
#'
#' Simply for code neatness.
#'
#' @param req response from \code{\link{gsheets_GET}} request
#' @importFrom XML xmlInternalTreeParse
gsheets_parse <- function(req) {
  xmlInternalTreeParse(req)
}


#' Create worksheet objects from worksheets feed
#' 
#' Store worksheet info (spreadsheet id, worksheet id, worksheet title) that is 
#' embedded as entry nodes in worksheets feed.
#' 
#' @param node Entry node for worksheet
#' @param sheet_id Spreadsheet id housing worksheet
#' 
#' @importFrom XML xmlToList
fetch_ws <- function(node, sheet_id) {
  attr_list <- xmlToList(node)
  
  ws <- worksheet()
  ws$sheet_id <- sheet_id
  ws$id <- unlist(strsplit(attr_list$id, "/"))[[9]]
  ws$title <- (attr_list$title)$text
  ws
  
  # dont think its necessary
  #listfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#listfeed']", "ns",
  #                       function(x) xmlGetAttr(x, "href"))
  #cellsfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']", "ns",
  #                        function(x) xmlGetAttr(x, "href"))
  #ws$listfeed <- listfeed
  #ws$cellsfeed <- cellsfeed
}


#' Get information from spreadsheets feed 
#'
#' Get spreadsheets titles, keys, and date/time of last update.
#'
#' @importFrom XML xmlValue
#' @importFrom XML xmlGetAttr
#' @importFrom XML getNodeSet
spreadsheets_info <- function() {
  the_url <- build_req_url("spreadsheets")
  req <- gsheets_GET(the_url)
  ssfeed <- gsheets_parse(req)
  
  ss_titles <- getNodeSet(ssfeed, "//ns:entry//ns:title", c("ns" = default_ns),
                          xmlValue)
  ss_updated <- getNodeSet(ssfeed, "//ns:entry//ns:updated", c("ns" = default_ns),
                           xmlValue)
  ss_wsfeed <- 
    getNodeSet(ssfeed, 
               "//ns:link[@rel='http://schemas.google.com/spreadsheets/2006#worksheetsfeed']", 
               c("ns" = default_ns),
               function(x) xmlGetAttr(x, "href"))
  
  
  ss_key_pre <- sub(".*worksheets/", "", unlist(ss_wsfeed))
  ss_key <- sub("/.*", "", ss_key_pre)
  
  ssdata_df <- data.frame(sheet_title = unlist(ss_titles),
                          last_updated = unlist(ss_updated),
                          sheet_key = ss_key,
                          stringsAsFactors = FALSE)
  ssdata_df
}


#' Find number of rows and columns of worksheet
#' 
#' Get the rows and columns of worksheet by making a request for cellfeed
#' 
#'@param client Client object
#'@param ws Worksheet object
#'@importFrom XML getNodeSet
#'@importFrom XML xmlApply
#'@importFrom XML xmlGetAttr
worksheet_dim <- function(ws, auth = get_google_token(), 
                          visibility = "private") {
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           visibility = visibility)
  
  req <- gsheets_GET(the_url)
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

