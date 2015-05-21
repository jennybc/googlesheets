#' Extract sheet key from a URL
#'
#' Extract a sheet's unique key from a wide variety of URLs, i.e. a browser URL
#' for both old and new Sheets, the "worksheets feed", and other links returned
#' by the Sheets API.
#'
#' @param url character; a URL associated with a Google Sheet
#'
#' @examples
#' \dontrun{
#' GAP_URL <- gs_gap_url()
#' GAP_KEY <- extract_key_from_url(GAP_URL)
#' gap_ss <- gs_key(GAP_KEY)
#' gap_ss
#' }
#'
#' @export
extract_key_from_url <- function(url) {
  url_start_list <-
    c(ws_feed_start = "https://spreadsheets.google.com/feeds/worksheets/",
      self_link_start = "https://spreadsheets.google.com/feeds/spreadsheets/private/full/",
      url_start_new = "https://docs.google.com/spreadsheets/d/",
      url_start_old = "https://docs.google.com/spreadsheet/ccc\\?key=",
      url_start_old2 = "https://docs.google.com/spreadsheet/pub\\?key=",
      url_start_old3 = "https://spreadsheets.google.com/ccc\\?key=")
  url_start <- url_start_list %>% stringr::str_c(collapse = "|")
  url %>% stringr::str_replace(url_start, '') %>%
    stringr::str_split_fixed('[/&#]', n = 2) %>%
    `[`(, 1)
}

#' Construct a worksheets feed from a key
#'
#' @param key character, unique key for a spreadsheet
#' @param visibility character, either "private" (default) or "public",
#'   indicating whether further requests will be made with or without
#'   authentication, respectively
#'
#' @keywords internal
construct_ws_feed_from_key <- function(key, visibility = "private") {
  tmp <-
    "https://spreadsheets.google.com/feeds/worksheets/%s/%s/full"
  sprintf(tmp, key, visibility)
}

#' Construct a browser URL from a key
#'
#' @param key character, unique key for a spreadsheet
#'
#' @keywords internal
construct_url_from_key <- function(key) {
  tmp <- "https://docs.google.com/spreadsheets/d/%s/"
  sprintf(tmp, key)
}
