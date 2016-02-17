# store base urls in the '.state' internal environment (created in gs_auth.R)
.state$gd_base_url <- "https://www.googleapis.com"
.state$gd_base_url_files_v2 <-
  file.path(.state$gd_base_url, "drive", "v2", "files")
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
    req$content <- content_as_xml_UTF8(req)
  }

  req

}
