#' Create GET request
#' 
#' Make GET request to Google Sheets API.
#' 
#' @param url URL for GET request
#' @param to_list whether to convert response contents to list or not
#' @param ... optional; further named parameters, such as \code{query}, 
#'   \code{path}, etc, passed on to \code{\link[httr]{modify_url}}. Unnamed 
#'   parameters will be combined with \code{\link[httr]{config}}.
#'
#' @keywords internal
gsheets_GET <- function(url, to_list = TRUE, ...) {
  
  if(grepl("public", url)) {
    req <- httr::GET(url, ...)
  } else { 
    req <- httr::GET(url, get_google_token(), ...)
  }
  httr::stop_for_status(req)
  ## TO DO: interpret some common problems for user? for example, a well-formed
  ## ws_feed for a non-existent spreadsheet will trigger "client error: (400)
  ## Bad Request" ... can we confidently say what the problem is?
  if(!grepl("application/atom+xml; charset=UTF-8",
            req$headers[["content-type"]], fixed = TRUE)) {
    
    # DIAGNOSTIC EXPERIMENT: If I always call list_sheets() here, which seems to
    # trigger token refresh more reliably when needed (vs register_ss), does 
    # this problem go away? If so, I'll put that info to good use with a less
    # stupid fix.
    if(grepl("public", url)) {
      req <- httr::GET(url, ...)
    } else { 
      req <- httr::GET(url, get_google_token(), ...)
    }
    httr::stop_for_status(req)
    if(!grepl("application/atom+xml; charset=UTF-8",
              req$headers[["content-type"]], fixed = TRUE)) {
      stop(sprintf(paste("Was expecting content-type to be:\n%s\nbut instead",
                         "it's:\n%s\n"),
                   "application/atom+xml; charset=UTF-8",
                   req$headers[["content-type"]]))
    }
  }
  # usually when the content-type is unexpectedly binary, it means we need to 
  # refresh the token ... we should have a better message or do something
  # constructive when this happens ... sort of waiting til I can review all the
  # auth stuff
  
  ## TO DO: eventually we will depend on xml2 instead of XML and then we should
  ## use it to parse the XML instead of httr:content()
  ## see https://github.com/hadley/httr/issues/189
  ## Hadley: Yeah, I think you should be parsing this yourself, with e.g.,
  ## xml2::xml(context(r, "raw"))
  req$content <- httr::content(req, type = "text/xml", encoding = "UTF-8")
  
  if(to_list) {
    req$content <- XML::xmlToList(req$content)
  }
  
  req

}

#' Create POST request
#'
#' Make POST request to Google Sheets API.
#'
#' @param url URL for POST request
#' @param the_body body of POST request
#' 
#' @keywords internal
gsheets_POST <- function(url, the_body) {
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized user in order to perform request")
  } else {
    # send xml to sheets api
    content_type <- "application/atom+xml"
    
    req <- 
      httr::POST(url, 
                 config = c(token, 
                            httr::add_headers("Content-Type" = content_type)),
                 body = the_body)
    req$content <- httr::content(req, type = "text/xml")
    if(!is.null(req$content)) {
      ## known example of this: POST request triggered by add_ws()
      req$content <- XML::xmlToList(req$content)
    }
    
    httr::stop_for_status(req)
    
    req
    
  }
}

#' Create DELETE request
#'
#' Make DELETE request to Google Sheets API.
#'
#' @param url URL for DELETE request
#' 
#' @keywords internal
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
#'
#' @keywords internal
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


#' Make POST request to Google Drive API
#'
#' Used in new_ss(), delete_ss(), copy_ss()
#' 
#' @param url URL for POST request
#' @param ... optional; further named parameters, such as \code{query}, 
#'   \code{path}, etc, passed on to \code{\link[httr]{modify_url}}. Unnamed 
#'   parameters will be combined with \code{\link[httr]{config}}.
#' 
#' @keywords internal
gdrive_POST <- function(url, ...) {
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized user in order to perform request")
  } else {
    
    req <- httr::POST(url, config = token, encode = "json", ...)
    httr::stop_for_status(req)
    req
  }
}

#' Make PUT request to Google Drive API
#'
#' Used in upload_ss() 
#'
#' @param url URL for PUT request
#' @param the_body body of PUT request 
#' 
#' @keywords internal
gdrive_PUT <- function(url, the_body) {
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized in order to perform request")
  } else {
    
    req <- httr::PUT(url, query = list(uploadType = "media", convert = "true"), 
                     config = token, 
                     body = httr::upload_file(the_body))
  }
  
  httr::stop_for_status(req)
  
  req
  
}


#' Make GET request to Google Drive API
#'
#' Used in download_ss() 
#'
#' @param url URL for GET request
#' @param ... optional; further named parameters, such as \code{query}, 
#'   \code{path}, etc, passed on to \code{\link[httr]{modify_url}}. Unnamed 
#'   parameters will be combined with \code{\link[httr]{config}}.
#'   
#' @keywords internal
gdrive_GET <- function(url, ...) {
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized in order to perform request")
  } else {
    req <- httr::GET(url, config = token, ...)
  }
  
  httr::stop_for_status(req)
  
  req$content <- httr::content(req)
  
  req
  
}
