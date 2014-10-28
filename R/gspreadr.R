#' Authorize client using ClientLogin
#'
#' Authorize user using email and password. 
#'
#'@param email User's email.
#'@param passwd Password for user's email.
#'@return Object of class client which stores the token used to subsequent requests.
#'
#'This method is using API as described at: 
#'\url{https://developers.google.com/accounts/docs/AuthForInstalledApps}
#'
#'Authorization token will be stored in http_session object which then gets
#'stored in client object. 
#'@export
#'@importFrom httr POST
#'@importFrom httr status_code
#'@importFrom httr content
login <- function(email, passwd) {
  
  service = "wise" 
  account_type = "HOSTED_OR_GOOGLE"
  the_url = "https://www.google.com/accounts/ClientLogin"
  
  r <- POST(the_url, body = list("accountType" = account_type, 
                                 "Email" = email, 
                                 "Passwd" = passwd, 
                                 "service" = service))
  
  # Google returns status 200 (success) or 403 (failure), show error msg if 403
  if(status_code(r) == 403)
    if(grepl("BadAuthentication", content(r))) {
      stop("Incorrect username or password.")
    } else {
      stop("Unable to authenticate")
    }
  
  # SID, LSID not active, extract auth token
  clean_content <- gsub("\n", "", content(r))
  token <- sub(".*Auth=", "", clean_content)
  
  auth_header <- paste0("GoogleLogin auth=", token)
  
  # make http_session object to store token
  session <- http_session()
  session$headers <- auth_header
  
  # instantiate client object to store credentials
  new_client <- client()
  new_client$auth <- c(email, passwd) 
  new_client$http_session <- session
  
  new_client
  
}

#' Get list of spreadsheets for authenticated user
#'
#' Retrive list of spreadsheets 
#'
#'@param client Object of class client returned by \code{\link{login}}
#'@return Dataframe of spreadsheet names. 
#'
#'Use auth token stored in http_session object of client object to make GET request. 
#'@export
list_spreadsheets <- function(client) {
  
  titles <- sheets(client)$sheet_title
  
  titles
  
}

#' Open spreadsheet by title 
#'
#' Use title of spreadsheet to retrieve object of class spreadsheet.
#'
#'@param client Client object returned by \code{\link{login}}
#'@param title Name of spreadsheet
#'@return Object of class spreadsheet.
#'@export
#'@importFrom httr GET
#'@importFrom httr add_headers
#'@importFrom XML xmlInternalTreeParse
#'@importFrom XML xmlToList
#'@importFrom XML getNodeSet
open_spreadsheet <- function(client, title) {
  
  ss_feed <- sheets(client) # returns dataframe of spreadsheet feed info
  
  index <- match(title, ss_feed$sheet_title)
  
  if(is.na(index))
    stop("Spreadsheet not found.")
  
  # uri for worksheets feed
  ws_url <- ss_feed[index, "worksheetsfeed_uri"]
  
  r <- GET(ws_url, add_headers('Authorization' = client$http_session$headers))
  
  # parse response to get worksheets feed
  ws_feed <- xmlInternalTreeParse(r)
  ws_feed_list <- xmlToList(ws_feed)
  
  ss <- spreadsheet()
  
  ss$sheet_id <- ws_feed_list$id
  ss$updated <- ws_feed_list$updated
  ss$sheet_title <- ws_feed_list$title[[1]]
  ss$nsheets <- as.numeric(ws_feed_list$totalResults)
  
  # return list of entry nodes
  ws_nodes <- getNodeSet(ws_feed, "//ns:entry", "ns") 
  
  # get values for all worksheet elements stored in entry node
  # returns list of worksheet objects
  ws_elements <- lapply(ws_nodes, fetch_ws) 
  
  names(ws_elements) <- lapply(ws_elements, function(x) x$title)
  
  ss$ws_names <- names(ws_elements)
  ss$worksheets <- ws_elements
  
  ss
  
}

#' Get the names of the worksheets contained in spreadsheet.
#'
#' Retrieve list of worksheet names contained in spreadsheet 
#'
#'@param x A spreadsheet object returned by \code{\link{open_spreadsheet}}
#'@return The names of worksheets contained in spreadsheet. 
#'
#'This is a mini wrapper for x$ws_names.
#'@export  
list_worksheets <- function(x) {
  
  titles <- x$ws_names
  
  titles
  
}

#' Open worksheet given worksheet title
#'
#' Use title of worksheet to retrieve object of class spreadsheet.
#'
#'@param spreadsheet Spreadsheet object housing the desired worksheet
#'@param title Name of worksheet to retrieve
#'@return An object of class worksheet. 
#'@export
get_worksheet <- function(spreadsheet, title) {

  # find index of specified worksheet
  index <- match(title, names(sheet$worksheets))
  
  if(is.na(index))
    stop("Worksheet not found.")
  
  ws <- sheet$worksheets[[index]]
  
  ws
}


#' Get worksheet object as a dataframe
#'
#' Use worksheet object and turn it into a dataframe.
#'
#'@param client Client object
#'@param ws Worksheet object 
#'@return A dataframe. 
#'@export
#'@importFrom httr GET
#'@importFrom httr add_headers
#'@importFrom XML xmlInternalTreeParse
#'@importFrom XML getNodeSet
#'@importFrom XML xmlSApply
#'@importFrom XML xmlAttrs
get_dataframe <- function(client, ws) {
  
#   if(is.null(client)) {
#     r <- GET(ws$cellsfeed, add_headers('Authorization' = client$http_session$headers))
#   } else {
  r <- GET(ws$cellsfeed, add_headers('Authorization' = client$http_session$headers))
 # }
  
  cellsfeed <- xmlInternalTreeParse(r)
 
  cell_nodes <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", c("ns", "gs"))

  vals <- xmlSApply(cell_nodes, xmlValue)

  # calculate index for last node to get ncol and nrow
  last_node <- unlist(tail(cell_nodes, n=1))
  dat <- unlist(lapply(last_node, xmlAttrs))

  n_row <- as.numeric(dat[1])
  n_col <- as.numeric(dat[2])
  
  my_data <- data.frame(matrix(vals, nrow = n_row, ncol = n_col, byrow = TRUE), row.names = NULL)

  names(my_data) <- vals[1:n_col]
  my_data <- my_data[-1, ]
  
  row.names(my_data) <- NULL
  
  my_data
}

# Functions ----


# get_dim <- function(ws) {
#   
#   xx<- GET(ws$listfeed, add_headers('Authorization' = client$http_session$headers))
#   
#   xxx <- xmlInternalTreeParse(r)
#   
#   nodes_for_rows <- getNodeSet(xxx, "//x:content", "x")
#   
#   col_counts <- lapply((strsplit(xmlSApply(nodes_for_rows, xmlValue), ",")), length)
#   
#   col_count <- max(unlist(col_counts)) + 1 # to add back first col
#   
#   row_count <- length(col_counts) + 1 # to add back header row
#   
#   dims <- c(row_count, col_count)
#   
#   names(dims) <- c("row", "col")
#   
#   dims
#   
# }
# 
# row_count <- function(worksheet) {
#   get_dim(worksheet)[1]
# }
# 
# col_count <- function(worksheet) {
#   get_dim(worksheet)[2]
# }  


# Public worksheets only -----

#' Open spreadsheet by key 
#'
#' Use key found in browser URL and return an object of class spreadsheet.
#'
#'@param spreadsheet_key A key of a spreadsheet as it appears in browser URL.
#'@return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets (visibility = TRUE and projection = FULL).
#'@export
#'@importFrom XML xmlToList
#'@importFrom XML getNodeSet
open_by_key <- function(key) {
  
  ss_feed <- get_spreadsheets_feed(key) 
  
  # convert to list
  ss_feed_list <- xmlToList(ss_feed)
  
  ss <- spreadsheet()
  
  ss$sheet_id <- ss_feed_list$id
  
  ss$updated <- ss_feed_list$updated
  
  ss$sheet_title <- ss_feed_list$title[[1]]
  
  ss$nsheets <- as.numeric(ss_feed_list$totalResults)
  
  # return list of entry nodes
  sheets <- getNodeSet(ss_feed, "//ns:entry", "ns") 
  
  # get values for all worksheet elements stored in entry node
  # returns list of worksheet objects
  sheets_elements <- lapply(sheets, fetch_ws) 
  
  # set worksheet objects
  ss$worksheets <- sheets_elements
  
  # set list of worksheet names in spreadsheet
  ss$ws_names <- names(sheets_elements)
  
  ss
  
}

#' Open spreadsheet by url 
#'
#' Use url of spreadsheet and return an object of class spreadsheet.
#'
#'@param url URL of spreadsheet as it appears in browser
#'@return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets (visibility = TRUE and projection = FULL).
#' This function extracts the key from the url and calls on open_by_key().
#'@export
open_by_url <- function(url) {
  
  # extract key from url 
  key <- unlist(strsplit(url, "/"))[6] # TODO: fix hardcoding
  
  open_by_key(key)
  
}


# INTERNAL HELPERS -----

# Make worksheet object from spreadsheet feed 
# store info from <entry> ... </entry>
#'@importFrom XML xmlName
#'@importFrom XML xmlToList
#'@importFrom XML getNodeSet
#'@importFrom XML xmlApply
#'@importFrom XML xmlGetAttr
fetch_ws <- function(node) {
  
  # check if node is entry node (represents worksheet)
  if(xmlName(node) != "entry") 
    stop("Node is not 'entry'.")
  
  feed_list <- xmlToList(node)
  
  ws <- worksheet()
  
  ws$id <- unlist(strsplit(feed_list$id, "/"))[[9]]
  
  ws$title <- (feed_list$title)$text
  
  listfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#listfeed']", "ns")
  cellsfeed <- getNodeSet(node, "ns:link[@rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']", "ns")
  
  ws_listfeed <- unlist(xmlApply(listfeed, function(x) xmlGetAttr(x, "href")))
  ws_cellsfeed <- unlist(xmlApply(cellsfeed, function(x) xmlGetAttr(x, "href")))
  
  ws$listfeed <- ws_listfeed
  ws$cellsfeed <- ws_cellsfeed
  
  ws
  
  
}


# Make api call to get spreadsheets feed
#'@importFrom httr GET
#'@importFrom httr url_ok
get_spreadsheets_feed <- function(key) {
  
  # Construct url for worksheets feed
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", key,
                    "/public/full")
  
  if(!url_ok(the_url)) 
    stop("The spreadsheet at this URL could not be found. Make sure that you have the right key.")
  
  # make request
  x <- GET(the_url)
  
  # parse response to get worksheets feed
  ss_feed <- xmlInternalTreeParse(x) #return "XMLInternalDocument"
  
  ss_feed
}

# Get name of spreadsheets, last updated, and worksheets feed uri
# 
# Retrive dataframe of spreadsheets information
# 
# @param x Client object returned by login(email, passwd)
# @return A dataframe containing name of spreadsheets, last updated, and uris for worksheets feed. 
# 
# Use auth token stored in http_session object of client object to make GET request. 
#'@importFrom httr GET
#'@importFrom httr add_headers
#'@importFrom XML xmlApply
#'@importFrom XML xmlValue
#'@importFrom XML xmlGetAttr
sheets <- function(client) {
  
  # to get spreadsheets feed
  the_url <- "https://spreadsheets.google.com/feeds/spreadsheets/private/full"
  r <- GET(the_url, add_headers('Authorization' = client$http_session$headers))
  ss_feed <- xmlInternalTreeParse(r)
  
  ss_titles <- getNodeSet(ss_feed, "//ns:entry//ns:title", "ns")
  ss_updated <- getNodeSet(ss_feed, "//ns:entry//ns:updated", "ns")
  ss_ws_feed <- getNodeSet(ss_feed, "//ns:entry/ns:link[@rel='http://schemas.google.com/spreadsheets/2006#worksheetsfeed']", "ns")
  
  ss_titles <- unlist(xmlApply(ss_titles, xmlValue))
  ss_updated <- unlist(xmlApply(ss_updated, xmlValue))
  ss_ws_feed <- unlist(xmlApply(ss_ws_feed, function(x) xmlGetAttr(x, "href")))
  
  sheets_data <- data.frame(sheet_title = ss_titles, 
                            last_updated = ss_updated, 
                            worksheetsfeed_uri = ss_ws_feed,
                            stringsAsFactors = FALSE)
  
  sheets_data
}

