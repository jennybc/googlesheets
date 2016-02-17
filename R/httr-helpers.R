stop_for_content_type <- function(req, expected) {
  actual <- req$headers$`Content-Type`
  if (actual != expected) {
    stop(
      sprintf(
        paste0("Expected content-type:\n%s",
               "\n",
               "Actual content-type:\n%s"),
        expected, actual
      )
    )
  }
  invisible(NULL)
}

content_as_json_UTF8 <- function(req) {
  stop_for_content_type(req, expected = "application/json; charset=UTF-8")
  jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
}

content_as_xml_UTF8 <- function(req) {
  stop_for_content_type(req, expected = "application/atom+xml; charset=UTF-8")
  xml2::read_xml(httr::content(req, as = "text", encoding = "UTF-8"))
}
