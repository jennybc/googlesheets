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
  xml2::read_xml(httr::content(req, as = "raw"))
}

## http://www.iana.org/assignments/http-status-codes/http-status-codes-1.csv

VERB_n <- function(VERB, n = 5) {
  function(...) {
    for (i in seq_len(n)) {
      out <- VERB(...)
      status <- httr::status_code(out)
      if (status < 500 || i == n) break
      backoff <- stats::runif(n = 1, min = 0, max = 2 ^ i - 1)
      ## TO DO: honor a verbose argument or option
      mess <- paste("HTTP error %s on attempt %d ...\n",
                    "  backing off %0.2f seconds, retrying")
      mpf(mess, status, i, backoff)
      Sys.sleep(backoff)
    }
    out
  }
}

rGET <- VERB_n(httr::GET)
