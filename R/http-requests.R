#' Create GET request
#'
#' Make GET request to Google Sheets API.
#'
#' @param url URL for GET request
#' @param to_list whether to convert response contents to list or not
gsheets_GET <- function(url, to_list = TRUE) {

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
  ## TO DO: eventually we will depend on xml2 instead of XML and then we should
  ## use it to parse the XML instead of httr:content()
  ## see https://github.com/hadley/httr/issues/189
  req$content <- httr::content(req, type = "text/xml")
  
  if(to_list) {
    req$content <- XML::xmlToList(req$content)
  }
  
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
      # send json to drive api
      req <- httr::POST(url, config = get_google_token(),
                        body = the_body, encode = "json")
      
    } else {
      # send xml to sheets api
      content_type <- "application/atom+xml"
      
      req <- httr::POST(url, config = c(token, 
                        httr::add_headers("Content-Type" = content_type)),
                        body = the_body)
      req$content <- httr::content(req, type = "text/xml")
      if(!is.null(req$content)) {
        ## known example of this: POST request triggered by add_ws()
        req$content <- XML::xmlToList(req$content)
      }
      
    } 

    httr::stop_for_status(req)
    
    ## 2015-02-28 I want us to return req because useful info can be extracted
    ## from it, for example the title of a newly created spreadsheet copy
    ## there's tons of potentially useful info there ...
    req

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
  req <- httr::DELETE(url, get_google_token())
  httr::stop_for_status(req)
  ## I haven't found any use yet for this return value, but adding for symmetry
  ## with other http functions
  req
}


#' Create PUT request
#'
#' Make PUT request to Google Sheets API.
#'
#' @param url URL for PUT request
#' @param the_body body of PUT request 
gsheets_PUT <- function(url, the_body) {
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized in order to perform request")
  }
  
  req <-
    httr::PUT(url, 
              config = c(token,
                         httr::add_headers("Content-Type" = "application/atom+xml")), 
              body = the_body)
  
  httr::stop_for_status(req)

  req$content <- httr::content(req, type = "text/xml")
  if(!is.null(req$content)) {
    ## known example of this: POST request triggered by add_ws()
    req$content <- XML::xmlToList(req$content)
  }  
  
  req
  
}
