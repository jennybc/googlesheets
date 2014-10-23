#' Authorize client using ClientLogin
#'
#' Authorize using email and password. 
#'
#'@param email User's email.
#'@param passwd Password for user's email.
#'@return Object of class client which stores the token used to subsequent requests.
#'
#'This method is using API as described at: 
#'https://developers.google.com/accounts/docs/AuthForInstalledApps
#'
#'Authorization token will be stored in http_session object which then gets
#'stord in client object. 
#'  
login <- function(email, passwd) {
  
  service = "wise" 
  account_type = "HOSTED_OR_GOOGLE"
  the_url = "https://www.google.com/accounts/ClientLogin"
  
  r <- POST(the_url, body = list("accountType" = account_type, 
                                 "Email" = email, 
                                 "Passwd" = passwd, 
                                 "service" = service))
  
  # prompt error msg Google returns status 200 (success) or 403 (failure)
  if(status_code(r) == 403)
    if(grepl("BadAuthentication", content(r))) {
      stop("Incorrect username or password.") 
    } else {
      stop("Unable to authenticate")
    }
  
  #SID, LSID not active, extract Auth (authorization token)
  token <- unlist(strsplit(content(r), "\n"))[3]
  
  token <- gsub("Auth", "auth", token) #incorrect syntax if capital
  auth_header <- paste0("GoogleLogin ", token)
  
  #make http_session object to store token
  session <- http_session()
  session$headers <- auth_header
  
  #instantiate client object to store credentials
  new_client <- client()
  new_client$auth <- c(email, passwd)
  new_client$http_session <- session
  
  new_client
  
}

#' Get list of spreadsheets for authenticated user
#'
#' Retrive list of spreadsheets 
#'
#'@param x Client object returned by login(email, passwd)
#'@return Dataframe of spreadsheet names. 
#'
#'Use auth token stored in http_session object of client object to make GET request. 
#'  
list_spreadsheets <- function(client) {
  
  titles <- sheets(client)$sheet_title
  
  titles
  
}


#' Open spreadsheet by title 
#'
#' Use key found in browser URL and return an object of class spreadsheet.
#'
#'@param client Client object returned by login(email, passwd)
#'@param title Name of spreadsheet
#'@return Object of class spreadsheet.
#'
open_sheet <- function(client, title) {
  
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

#' Get list of worksheets contained in spreadsheet.
#'
#' Retrieve list of worksheets contained in spreadsheet 
#'
#'@param x A spreadsheet object returned by open_sheet(client, title)
#'@return The names of worksheets contained in spreadsheet. 
#'
#'This is a mini wrapper for x$ws_names.
#'  
list_worksheets <- function(x) {
  
  titles <- x$ws_names
  
  titles
  
}

#' Open spreadsheet by key 
#'
#' Use key found in browser URL and return an object of class spreadsheet.
#'
#'@param spreadsheet_key A key of a spreadsheet as it appears in browser URL.
#'@return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets (visibility = TRUE and projection = FULL).
#'  
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
#'  
open_by_url <- function(url) {
  
  # extract key from url 
  key <- unlist(strsplit(url, "/"))[6] # TODO: fix hardcoding
  
  open_by_key(key)
  
}


# INTERNAL HELPERS -----

# Make worksheet object from spreadsheet feed 
# store info from <entry> ... </entry>
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
#  
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

