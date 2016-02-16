# store base urls in the '.state' internal environment (created in gs_auth.R)
.state$gd_base_url_v2 <- "https://www.googleapis.com"
#.state$gd_base_url_v2 <- "https://www.googleapis.com/drive/v2"
#.state$gd_base_url_v3 <- "https://www.googleapis.com/drive/v3"
#.state$gs_base_url <- "https://spreadsheets.google.com/feeds"

#' Create GET request
#'
#' Make GET request to Google Sheets API.
#'
#' @param url the url of the page to retrieve
#' @param to_xml whether to convert response contents to an \code{xml_doc} or
#'   leave as character string
#' @param use_auth logical; indicates if authorization should be used, defaults
#'   to \code{FALSE} if \code{url} implies public visibility and \code{TRUE}
#'   otherwise
#' @param ... optional; further named parameters, such as \code{query},
#'   \code{path}, etc, passed on to \code{\link[httr]{modify_url}}. Unnamed
#'   parameters will be combined with \code{\link[httr]{config}}.
#'
#' @keywords internal
gsheets_GET <-
  function(url, to_xml = TRUE, use_auth = !grepl("public", url), ...) {

  if(use_auth) {
    req <- httr::GET(url, get_google_token(), ...)
  } else {
    req <- httr::GET(url, ...)
  }
  httr::stop_for_status(req)
  ## TO DO: interpret some common problems for user? for example, a well-formed
  ## ws_feed for a non-existent spreadsheet will trigger "client error: (400)
  ## Bad Request" ... can we confidently say what the problem is?

  ok_content_types <- c("application/atom+xml; charset=UTF-8", "text/csv")
  if(!(req$headers$`content-type` %in% ok_content_types)) {
    stop(sprintf(paste("Not expecting content-type to be:\n%s"),
                 req$headers[["content-type"]]))
    # usually when the content-type is unexpectedly binary, it means we need to
    # refresh the token ... we should have a better message or do something
    # constructive when this happens ... sort of waiting til I can review all
    # the auth stuff
  }

  # This is only FALSE when calling gs_ws_modify() where we are using regex
  # substitution, waiting for xml2 to support XML editing
  if(to_xml) {
    req$content <- req %>%
      httr::content(as = "text", encoding = "UTF-8") %>%
      xml2::read_xml()
  }

  req

}

#' Create POST request
#'
#' Make POST request to Google Sheets API.
#'
#' @param url the url of the page to retrieve
#' @param the_body body of POST request
#'
#' @keywords internal
gsheets_POST <- function(url, the_body) {

  # send xml to sheets api
  content_type <- "application/atom+xml"

  req <-
    httr::POST(url,
               config = c(get_google_token(),
                          httr::add_headers("Content-Type" = content_type)),
               body = the_body)
  httr::stop_for_status(req)

  req$content <- httr::content(req, as = "text", encoding = "UTF-8")

  if(!is.null(req$content)) {
    ## known example of this: POST request triggered by gs_ws_new()
    req$content <- req$content %>% xml2::read_xml()
  }

  req

}

#' Make POST request to Google Drive API
#'
#' Used in gs_new(), gs_delete(), gs_copy()
#'
#' @param url the url of the page to retrieve
#' @param ... optional; further named parameters, such as \code{query},
#'   \code{path}, etc, passed on to \code{\link[httr]{modify_url}}. Unnamed
#'   parameters will be combined with \code{\link[httr]{config}}.
#'
#' @keywords internal
gdrive_POST <- function(url, ...) {

  req <- httr::POST(url, get_google_token(), encode = "json", ...)
  httr::stop_for_status(req)
  req
}
