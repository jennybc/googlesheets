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

