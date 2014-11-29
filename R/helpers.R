# default namespace for querying xml feed returned by gsheets_GET
default_ns = "http://www.w3.org/2005/Atom"

#' Build URL for GET requests
#'
#' Construct URL for talking to Google Sheets API. 
#'
#' @param feed_type one of the following: spreadsheets, worksheets, list, cells
#' @param key spreadsheet key
#' @param ws_id id of worksheet contained in spreadsheet
#' @param visibility Either private or public
#' @param projection Either full or basic
#' @return URL
build_req_url <- function(feed_type, key = NULL, ws_id = NULL, 
                          visibility = "private", projection = "full", 
                          min_row = NULL, max_row = NULL, 
                          min_col = NULL, max_col = NULL) 
{
  base_url <- "https://spreadsheets.google.com/feeds"
  
  switch(
    feed_type,
    spreadsheets = {
      the_url <- paste(base_url, feed_type, visibility, projection, 
                       sep = "/")
    },
    worksheets = {
      the_url <- paste(base_url, feed_type, key, visibility, projection, 
                       sep = "/")
    },
    list = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, 
                       projection , sep = "/")
    },
    cells = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, 
                       projection, sep = "/")
      
      if(sum(min_row, max_row, min_col, max_col) > 0) {
        query <- build_query(min_row, max_row, min_col, max_col)
        the_url <- paste0(the_url, query)
      } 
    }
  )
  the_url
}


#' Build query suffix for GET URL
#'
#' Create query to qppend to GET URL.
#'
#' @param min_row, max_row,min_col,max_col query parameters
build_query <- function(min_row, max_row, min_col, max_col) 
{
  if(!is.null(min_row) && !is.null(min_col)) {
    query <- paste0("?min-row=", min_row, "&max-row=", max_row, 
                    "&min-col=", min_col, "&max-col=", max_col)
  } else {
    if(is.null(min_row)) {
      query <- paste0("?&min-col=", min_col, "&max-col=", max_col)
    } else {
      query <- paste0("?&min-row=", min_row, "&max-row=", max_row)
    }
  }
  query
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
gsheets_GET <- function(url, token = get_google_token()) 
{ 
  if(is.null(token)) {
    req <- GET(url)
  } else {
    req <- GET(url, gsheets_auth(token))
  }
  stop_for_status(req)
  req
}


#' Check if token is obtained from Google login or oauth2.0
#' 
#' Add token as a header or token in configuations in URL request.
#' 
#' @param token Google token
#' @importFrom httr config
#' @importFrom httr add_headers
gsheets_auth <- function(token) 
{
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
gsheets_parse <- function(req) 
{
  xmlInternalTreeParse(req)
}


#' Create worksheet objects from worksheets feed
#' 
#' Extract worksheet info (spreadsheet id, worksheet id, worksheet title) 
#' from entry nodes in worksheets feed as worksheet objects.
#' 
#' @param node entry node for worksheet
#' @param sheet_id spreadsheet id housing worksheet
#' 
#' @importFrom XML xmlToList
make_ws_obj <- function(node, sheet_id) 
{
  attr_list <- xmlToList(node)
  
  ws <- worksheet()
  ws$sheet_id <- sheet_id
  ws$id <- unlist(strsplit(attr_list$id, "/"))[[9]]
  ws$title <- (attr_list$title)$text
  ws
}


#' Get information from spreadsheets feed 
#'
#' Get spreadsheets titles, keys, and date/time of last update.
#'
#' @importFrom XML xmlValue
#' @importFrom XML xmlGetAttr
#' @importFrom XML getNodeSet
ssfeed_to_df <- function() 
{
  the_url <- build_req_url("spreadsheets")
  req <- gsheets_GET(the_url)
  ssfeed <- gsheets_parse(req)
  
  ss_titles <- getNodeSet(ssfeed, "//ns:entry//ns:title", c("ns" = default_ns),
                          xmlValue)
  
  ss_updated <- getNodeSet(ssfeed, "//ns:entry//ns:updated", 
                           c("ns" = default_ns), xmlValue)
  
  ss_wsfeed <- 
    getNodeSet(ssfeed, '//ns:entry//ns:link[@rel="self"]', c("ns" = default_ns),
               function(x) xmlGetAttr(x, "href"))
  
  ss_key <- sub(".*full/", "", unlist(ss_wsfeed)) # extract spreadsheet key
  
  ssdata_df <- data.frame(sheet_title = unlist(ss_titles),
                          last_updated = unlist(ss_updated),
                          sheet_key = ss_key,
                          stringsAsFactors = FALSE)
  ssdata_df
}


#' Find number of rows and columns of worksheet

#' Get the rows and columns of worksheet by making a request for cellfeed

#' @param ws Worksheet object
#' @param auth Google token
#' @param visibility set to \code{public} for public sheets
#' @importFrom XML getNodeSet
#' @importFrom XML xmlApply
#' @importFrom XML xmlGetAttr
#' @export
worksheet_dim <- function(ws, auth = get_google_token(), visibility = "private")
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           visibility = visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  cell_nodes <- getNodeSet(feed, "//ns:feed//ns:entry", c("ns" = default_ns)) 
  
  if(length(cell_nodes) == 0) {
    dims <- getNodeSet(feed, "//ns:feed//gs:*", c("ns" = default_ns, "gs"), xmlValue)
    ws$nrow <- as.numeric(dims[[1]])
    ws$ncol <- as.numeric(dims[[2]])
  } else {
    cell_col_num <- getNodeSet(feed, "//ns:entry//gs:*", c("ns" = default_ns, "gs"),
                               function(x) c(as.numeric(xmlGetAttr(x, "col")), 
                                             as.numeric(xmlGetAttr(x, "row"))))
    
    ws$nrow <- max(sapply(cell_col_num, "[[", 2))
    ws$ncol <- max(sapply(cell_col_num, "[[", 1))
  }
  ws
}

# #' Find number of rows and columns of worksheet
# #' 
# #' Get the rows and columns of worksheet by making a request for cellfeed
# #' 
# #' dparam ws Worksheet object
# #' param auth Google token
# #' param visibility set to \code{public} for public sheets
# #'  
# #' The is faster but with a trade-off. For listfeeds, data will stop before an 
# #' entire blank row. For example if row 2 is entirely blank, no data will be 
# #' returned. Blank columns are also ignored. The number of columns will be the 
# #' maximum number of cells in a row that contain a value, regardless
# #' of spacing.
# #' 
# #' importFrom XML getNodeSet
# #' importFrom XML xmlChildren
# worksheet_dim <- function(ws, auth = get_google_token(), visibility = "private")
# {
#   the_url <- build_req_url("list", key = ws$sheet_id, ws_id = ws$id, 
#                            visibility = visibility)
#   
#   req <- gsheets_GET(the_url)
#   feed <- gsheets_parse(req)
# 
#   cell_nodes <- getNodeSet(feed, "//ns:feed//ns:entry", c("ns" = default_ns),
#                            function(x) length(xmlChildren(x)) - 7)
#   
#   ws$ncol <- max(unlist(cell_nodes))
#   ws$nrow <- length(cell_nodes) + 1 # to include header row
#   ws
# }

#' Create lookup table for cell indices and its values 
#'
#' Convert cell row and col attributes stored in entry nodes, along with 
#' input values into a single data frame and serve as a lookup table for 
#' further processing.
#'
#' @param cellsfeed Cell based feed parsed with \code{\link{gsheets_parse}} 
#' @return A data frame with cell row and col number and corresponding input value.
#' @importFrom XML getNodeSet
#' @importFrom XML xmlAttrs
#' @importFrom XML xmlValue
create_lookup_tbl <- function(cellsfeed) {
  val <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", 
                    c("ns" = default_ns, "gs"), xmlValue)
  
  row_num <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", 
                        c("ns" = default_ns, "gs"),
                        function(x) as.numeric(xmlAttrs(x)["row"]))
  
  col_num <-  getNodeSet(cellsfeed, "//ns:entry//gs:cell", 
                         c("ns" = default_ns, "gs"),
                         function(x) as.numeric(xmlAttrs(x)["col"]))
  
  rows <- unlist(row_num)
  cols <- unlist(col_num)
  
  row_diff <- min(unlist(row_num)) - 1
  col_diff <- min(unlist(col_num)) - 1
  
  row_adj <- rows - row_diff
  col_adj <- cols - col_diff
  
  lookup_tbl <- data.frame(row = rows, col = cols, 
                           row_adj = row_adj, col_adj = col_adj,
                           val = unlist(val),
                           stringsAsFactors = FALSE)
  
  lookup_tbl
}


#' Set header for data frame 
#'
#' Take first row of data frame and make it the header. Rownames are also reset.
#'
#' @param x a data frame.
set_header <- function(x)
{
  names(x) <- x[1, ]
  x <- x[2:nrow(x), ]
  rownames(x) <- NULL
  x
}


#' Convert column letter to column number
#'
#' @param x column letter (case insensitive)
#' @examples
#' letter_to_num("A")
#' letter_to_num("AB")
#' letter_to_num("a")
#' letter_to_num("ab")
letter_to_num <- function(x)
{
  ascii_tbl <- data.frame(alpha = LETTERS, num = 65:90)
  x <- toupper(x)
  
  m <- c()
  for(i in 1:nchar(x)) {
    k <- unlist(strsplit(x, "")) # list of characters
    ind <- grep(k[i], ascii_tbl$alpha)
    y <- (ascii_tbl[ind, "num"] - 64) * (26 ^ (nchar(x) - i))
    m <- c(m, y)
  }
  sum(m)
}


#' Convert column number to column letter
#'
#' @param x column number
#' @examples
#' num_to_letter(1)
#' num_to_letter(26)
num_to_letter <- function(x)
{
  ascii_tbl <- data.frame(alpha = LETTERS, num = 65:90)
  letter <- ""
  
  while(x > 0)
  {
    temp <- (x - 1) %% 26
    ind <-  grep(temp + 65, ascii_tbl$num)
    letter <- paste0(ascii_tbl$alpha[ind], letter)
    x <- (x - temp - 1) / 26
  }
  letter
}


#' Convert label (A1) notation to coordinate (R1C1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells, but R1C1 
#' notation is used in queries. 
#'
#' @param x label notation for position of cell
#' @examples
#' label_to_coord("A1")
#' label_to_coord("AB23")
label_to_coord <- function(x)
{
  letter <- unlist(strsplit(x, "[0-9]+"))
  col_num <- letter_to_num(letter)
  row_num <- gsub("[[:alpha:]]", "", x)
  paste0("R", row_num, "C", col_num)
}


#' Fill in missing columns in row
#' 
#' The lookup table returned by create_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every column up to the right-most column of the row.
#' 
#' @param x data frame returned by \code{\link{create_look_tbl}}
#' 
#' This function operates on the lookup table grouped by row.
#'
fill_missing_col <- function(x) 
{
  for(i in 1: max(x$col)) {
    if(is.na(match(i, x$col))) {
      new_tuple <- c(unique(x$row), i, unique(x$row), i, NA)
      x <- rbind(x, new_tuple)
    }
  }
  x
} 


#' Fill in missing rows in column
#' 
#' The lookup table returned by create_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of the column.
#' 
#' @param x data frame returned by \code{\link{create_look_tbl}}
#' 
#' This function operates on the lookup table grouped by column.
#'
fill_missing_row <- function(x) {
  for(i in 1: max(x$row)) {
    if(is.na(match(i, x$row))) {
      new_tuple <- c(i, unique(x$col), i, unique(x$col), NA)
      x <- rbind(x, new_tuple)
    }
  }
  x
}


#' Fill in missing tuples for lookup table
#' 
#' The lookup table returned by create_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of every column or every column 
#' up to the right-most column of every row. 
#' 
#' @param lookup_tbl data frame returned by \code{\link{create_look_tbl}}
#' 
#' @importFrom dplyr arrange
#' @importFrom plyr ddply
fill_missing_tbl <- function(lookup_tbl, fill_by = "col") {
  
  if(fill_by == "col")
    lookup_tbl_clean <- ddply(lookup_tbl, "row", fill_missing_col)
  else
    lookup_tbl_clean <- ddply(lookup_tbl, "col", fill_missing_row)
  
  arrange(lookup_tbl_clean, row, col)
}

