# Example public spreadsheet ----
#KEY <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-cmEaZU" # Spreadsheet with 1 worksheet
# Spreadsheet with 4 worksheets
#spreadsheet_key <- "1nKnfjLX7L76eWlLJjthq_qf0FF1lprDv7rYs6Sm1iCw"
# URL to public spreadsheet
#URL <- "https://docs.google.com/spreadsheets/d/1nKnfjLX7L76eWlLJjthq_qf0FF1lprDv7rYs6Sm1iCw/pubhtml"


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

  spreadsheets_feed <- get_spreadsheets_feed(key) 
  
  # convert to list
  spreadsheets_feed_list <- xmlToList(spreadsheets_feed)
  
  ss <- spreadsheet()
  
  ss$sheet_id <- spreadsheets_feed_list$id
  
  ss$updated <- spreadsheets_feed_list$updated
  
  ss$sheet_title <- spreadsheets_feed_list$title[[1]]
  
  ss$nsheets <- as.numeric(spreadsheets_feed_list$totalResults)
  
  # return list of entry nodes
  sheets <- getNodeSet(spreadsheets_feed, "//ns:entry", "ns") 
  
  # get values for all worksheet elements stored in entry node
  # returns list of worksheet objects
  sheets_elements <- lapply(sheets, fetch_sheets) 
  
  # name list of worksheets by title of worksheet 
  # names(sheets_elements) <- sapply(sheets_elements, sheets_elements[[2]])
  
  # set worksheet objects
  ss$worksheets <- sheets_elements
  
  # set list of worksheet names in spreadsheet
  ss$sheet_names <- names(sheets_elements)
  
  return(ss)
  
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

# helper function
# Make worksheet object from spreadsheet feed 
# store info from <entry> ... </entry>
fetch_sheets <- function(node) {
  
  # check if node is entry node (represents worksheet)
  if(xmlName(node) != "entry") 
    stop("Node is not 'entry'.")
  
  feed_list <- xmlToList(node)
  
  ws <- worksheet()
  
  ws$id <- unlist(strsplit(feed_list$id, "/"))[[9]]
  ws$title <- (feed_list$title)$text # TODO
  ws$url <- (feed_list$title)$text # TODO
  ws$listfeed <- (feed_list$link)['href']
  ws$cellsfeed <- (feed_list[[7]])['href'] # TODO: fix hardcoding
  
  return(ws)
}


# helper function
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
  spreadsheets_feed <- xmlInternalTreeParse(x) #return "XMLInternalDocument"
  
  spreadsheets_feed
}
