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
#'@examples
#'spreadsheets_GET("spreadsheets", NULL, 
#'"1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-cmEaZU", visibility = "public")

spreadsheets_GET <- function(feed_type, client = NULL, key = NULL,
                             ws_id = NULL, visibility = "private", 
                             projection = "full")
{
  base_url <- "https://spreadsheets.google.com/feeds"
  
  switch(
    feed_type,
    spreadsheets = {
      the_url <- paste(base_url, feed_type, visibility, projection, sep = "/")
    },
    worksheets = {
      the_url <- paste(base_url, feed_type, key, visibility, projection, sep = "/")
    },
    listfeed = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, projection , sep = "/")
    },
    cellsfeed = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, projection, sep = "/")
    }
  )
  
  if(!is.null(client))
    auth <- spreadsheets_auth(client)
  
  req <- GET(the_url, auth)
  req
}

