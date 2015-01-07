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
      the_url <- paste(base_url, feed_type, visibility, projection, 
                       sep = "/")
    },
    worksheets = {
      if(!is.null(ws_id))
        the_url <- paste(base_url, feed_type, key, visibility, projection, ws_id,
                         sep = "/")
      else
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


#' Build query string for GET URL
#'
#' Form the query string to append to GET URL.
#'
#' @param min_row,max_row,min_col,max_col query parameters
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
#' @param token Google auth token obtained from \code{\link{login}} 
#' or \code{\link{authorize}} 
#' @importFrom httr GET stop_for_status
gsheets_GET <- function(url, token = NULL) 
{ 
  if(grepl("public", url)) {
    req <- GET(url)
  } else {
    token = get_google_token()
    req <- GET(url, gsheets_auth(token))
  }
  stop_for_status(req)
  req
}


#' Create PUT request
#'
#' Make PUT request to Google Sheets API.
#'
#' @param url URL for PUT request
#' @param the_body body of PUT request
#' @param token Google auth token obtained from \code{\link{login}} 
#' or \code{\link{authorize}} 
#' @importFrom httr PUT stop_for_status
gsheets_PUT <- function(url, the_body, token = get_google_token()) 
{ 
  body_as_string <- toString.XMLNode(the_body)
  leng <- as.character(nchar(body_as_string))
  
  if(is.null(token)) {
    stop("Must be authorized in order to perform request")
  } else {
    req <- PUT(url, gsheets_auth(token), 
               add_headers("Content-Type" = "application/atom+xml",
                           "Content-Length" = leng),
               body = body_as_string)
    stop_for_status(req)
  }
}


#' Create POST request
#'
#' Make POST request to Google Sheets/Drive API.
#'
#' @param url URL for POST request
#' @param the_body body of POST request
#' @param content_type the content type, default is "atom+xml" for posting to 
#' Sheets API, "json" for posting to Drive API 
#' @param token Google auth token obtained from \code{\link{login}} 
#' or \code{\link{authorize}} 
#' @importFrom httr POST stop_for_status
gsheets_POST <- function(url, the_body, content_type = "atom+xml", 
                         token = get_google_token())
{
  if(is.null(token)) {
    stop("Must be authorized in order to perform request")
  } else {
    req <- POST(url, gsheets_auth(token), 
                add_headers("Content-Type" = 
                              paste0("application/", content_type)),
                body = the_body)
    stop_for_status(req)
  }
}


#' Create DELETE request
#'
#' Make DELETE request to Google Sheets API.
#'
#' @param url URL for DELETE request
#' @param token Google auth token obtained from \code{\link{login}} 
#' or \code{\link{authorize}} 
#' @importFrom httr DELETE stop_for_status
gsheets_DELETE <- function(url, token = get_google_token())
{
  req <- DELETE(url, gsheets_auth(token))
  stop_for_status(req)
}



