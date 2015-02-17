#' Build URL for GET requests
#'
#' Construct URL for talking to Google Sheets API. 
#'
#' @param feed_type one of the following: spreadsheets, worksheets, list, cells
#' @param key spreadsheet key
#' @param ws_id id of worksheet contained in spreadsheet
#' @param min_row,max_row minimum and maximum rows
#' @param min_col,max_col miniumum and maximum columns
#' @param visibility either private or public
#' @param projection either full or basic
#' @return URL
build_req_url <- function(feed_type, key = NULL, ws_id = NULL, 
                          min_row = NULL, max_row = NULL, 
                          min_col = NULL, max_col = NULL, 
                          visibility = "private", projection = "full") 
{
  base_url <- "https://spreadsheets.google.com/feeds"
  
  switch(
    feed_type,
    spreadsheets = {
      the_url <- slaste(base_url, feed_type, visibility, projection)
    },
    worksheets = {
      if(!is.null(ws_id))
        the_url <-
        slaste(base_url, feed_type, key, visibility, projection, ws_id)
      else
        the_url <- slaste(base_url, feed_type, key, visibility, projection)
    },
    list = {
      the_url <- slaste(base_url, feed_type, key, ws_id, visibility, 
                        projection)
    },
    NA_character_
  )
  the_url
}

#' Create GET request
#'
#' Make GET request to Google Sheets API.
#'
#' @param url URL for GET request
gsheets_GET <- function(url) {

  if(grepl("public", url)) {
    req <- httr::GET(url)
  } else { 
    req <- httr::GET(url, get_google_token())
  }
  httr::stop_for_status(req)
  ## TO DO: interpret some common problems for user? for example, a well-formed
  ## ws_feed for a non-existent spreadsheet will trigger "client error: (400)
  ## Bad Request" ... can we confidently say what the problem is?
  if(!grepl("application/atom+xml; charset=UTF-8",
            req$headers[["content-type"]], fixed = TRUE)) {
    stop(sprintf("Was expecting content-type to be:\n%s\nbut instead it's:\n%s\n",
                 "application/atom+xml; charset=UTF-8",
                 req$headers[["content-type"]]))
  }
  req$content <- httr::content(req, type = "text/xml")
  req$content <- XML::xmlToList(req$content)
  req
}
