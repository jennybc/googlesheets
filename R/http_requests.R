#' Create GET request
#'
#' Make GET request to Google Sheets API.
#'
#' @param url the url of the page to retrieve
#' @param to_xml whether to convert response contents to \code{xml_doc()} or
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

    # DIAGNOSTIC EXPERIMENT: If I always call gs_ls() here, which seems to
    # trigger token refresh more reliably when needed (vs registration), does
    # this problem go away? If so, I'll put that info to good use with a less
    # stupid fix. NOTE added later: I am NOT calling gs_ls() here, but am simply
    # trying the GET a second time. Can this be ripped out now?
    if(grepl("public", url)) {
      req <- httr::GET(url, ...)
    } else {
      req <- httr::GET(url, get_google_token(), ...)
    }
    httr::stop_for_status(req)
    if(!any(req$headers[["content-type"]] %>%
            stringr::str_detect(ok_content_types))) {
      stop(sprintf(paste("Not expecting content-type to be:\n%s"),
                   req$headers[["content-type"]]))
    }
  }
  # usually when the content-type is unexpectedly binary, it means we need to
  # refresh the token ... we should have a better message or do something
  # constructive when this happens ... sort of waiting til I can review all the
  # auth stuff

  # This is only FALSE when calling gs_ws_modify() where we are using regex
  # substitution, waiting for xml2 to support changing xml_doc()
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
    req$content <- httr::content(req, as = "text", encoding = "UTF-8")

    if(!is.null(req$content)) {
      ## known example of this: POST request triggered by gs_ws_new()
      req$content <- req$content %>% xml2::read_xml()
    }

    httr::stop_for_status(req)

    req

  }
}

#' Create DELETE request
#'
#' Make DELETE request to Google Sheets API.
#'
#' @param url the url of the page to retrieve
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
#' @param url the url of the page to retrieve
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
    ## known example of this: POST request triggered by gs_ws_new()
    req$content <- XML::xmlToList(req$content)
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
#' Used in gs_upload()
#'
#' @inheritParams gdrive_POST
#'
#' @keywords internal
gdrive_PUT <- function(url, ...) {

  token <- get_google_token()

  if(is.null(token)) {
    stop("Must be authorized in order to perform request")
  } else {

    req <- httr::PUT(url, config = token, ...)
  }

  httr::stop_for_status(req)

  req

}


#' Make GET request to Google Drive API
#'
#' Used in gs_download()
#'
#' @inheritParams gdrive_POST
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
