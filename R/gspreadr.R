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
open_by_key <- function(spreadsheet_key) {

  # Construct url for worksheets feed
  the_url <- paste0("https://spreadsheets.google.com/feeds/worksheets/", spreadsheet_key,
                    "/public/full")
  
  # make request
  x <- GET(the_url)
  
  if(x$status != 200) 
    stop("The spreadsheet at this URL could not be found. Make sure that you have the right key.")
  
  # parse response to get worksheets feed
  xml_feed <- xmlInternalTreeParse(x) #return "XMLInternalDocument"
  
  # convert to list
  xml_feed_list <- xmlToList(xml_feed)
  
  ss <- spreadsheet()
  
  ss$sheet_id <- xml_feed_list$id
  
  ss$updated <- xml_feed_list$updated
  
  ss$sheet_title <- xml_feed_list$title[[1]]
  
  ss$nsheets <- as.numeric(xml_feed_list$totalResults)
  
  # return list of entry nodes
  sheets <- getNodeSet(xml_feed, "//ns:entry", "ns") 
  
  # get values for all worksheet elements stored in entry node
  # returns list of worksheet objects
  sheets_elements <- lapply(sheets, make_worksheet_obj) 
  
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
make_worksheet_obj <- function(node) {
  
  # check if node is entry node (represents worksheet)
  if(xmlName(node) != "entry") 
    stop("Node is not 'entry'.")
  
  ws_feed_list <- xmlToList(node)
  
  ws <- worksheet()
  
  ws$ws_id <- unlist(strsplit(ws_feed_list$id, "/"))[[9]]
  ws$ws_title <- (ws_feed_list$title)$text # TODO
  ws$ws_url <- (ws_feed_list$title)$text # TODO
  ws$ws_listfeed <- (ws_feed_list$link)['href']
  ws$ws_cellsfeed <- (ws_feed_list[[7]])['href'] # TODO: fix hardcoding
  
  return(ws)
}

