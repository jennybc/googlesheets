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
    token <- get_google_token()
    req <- httr::GET(url, gsheets_auth(token))
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
  ## TO DO: eventually we will depend on xml2 instead of XML and then we should
  ## use it to parse the XML instead of httr:content()
  ## see https://github.com/hadley/httr/issues/189
  req$content <- httr::content(req, type = "text/xml")
  req$content <- XML::xmlToList(req$content)
  req
}



#' Create POST request
#'
#' Make POST request to Google Sheets/Drive API.
#'
#' @param url URL for POST request
#' @param the_body body of POST request
gsheets_POST <- function(url, the_body) {
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized user in order to perform request")
  } else {
    
    # first look at the url to determine contents, 
    # must be either talking to "drive" or "spreadsheets" API
    if(stringr::str_detect(stringr::fixed(url), "drive")) {
      content_type <- "application/json" # send json to drive api
    } else {
      content_type <- "application/atom+xml" # send xml to sheets api
    } 
    
    req <- httr::POST(url, gsheets_auth(token), 
                      httr::add_headers("Content-Type" = content_type),
                      body = the_body)
    
    httr::stop_for_status(req)
    
    ## TO DO: inform users of why client error (404) Not Found may arise when
    ## copying a spreadsheet
    #     message(paste("The spreadsheet can not be found.",
    #                   "Please make sure that the spreadsheet exists and that you have permission to access it.",
    #                   'A "published to the web" spreadsheet does not necessarily mean you have permission for access.',
    #                   "Permission for access is set in the sharing dialog of a sheets file."))
  }
}


#' Create DELETE request
#'
#' Make DELETE request to Google Sheets API.
#'
#' @param url URL for DELETE request
gsheets_DELETE <- function(url) {
  token <- get_google_token()
  req <- httr::DELETE(url, gsheets_auth(token))
  httr::stop_for_status(req)
}
