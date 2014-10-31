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

gsheets_GET <- function(feed_type, client = NULL, key = NULL,
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
    list = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, projection , sep = "/")
    },
    cells = {
      the_url <- paste(base_url, feed_type, key, ws_id, visibility, projection, sep = "/")
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

# check if client is using Google login or oauth2.0
#'@importFrom httr config
#'@importFrom httr add_headers
gsheets_auth <- function(client) {
  if(class(client$auth) != "character")
    auth <- config(token = client$auth)
  else 
    auth <- add_headers('Authorization' = client$auth)
}


# Google returns status 200 (success) or 403 (failure), show error msg if 403
#'@importFrom httr status_code
#'@importFrom httr content
gsheets_check <- function(req) {
  if(status_code(req) == 403) {
    if(grepl("BadAuthentication", content(req)))
      stop("Incorrect username or password.")
    else
      stop("Unable to authenticate")
  }
}
