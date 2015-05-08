#' Retrieve a worksheet-describing list from a googlesheet
#'
#' From a \code{\link{googlesheet}}, retrieve a list (actually a row of a
#' data.frame) giving everything we know about a specific worksheet.
#'
#' @inheritParams get_via_lf
#' @param verbose logical, indicating whether to give a message re: title of the
#'   worksheet being accessed
#'
#' @keywords internal
gs_ws <- function(ss, ws, verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"),
            length(ws) == 1L,
            is.character(ws) || (is.numeric(ws) && ws > 0))

  if(is.character(ws)) {
    index <- match(ws, ss$ws$ws_title)
    if(is.na(index)) {
      stop(sprintf("Worksheet %s not found.", ws))
    } else {
      ws <- index
    }
  }
  ws <- ws %>% as.integer()
  if(ws > ss$n_ws) {
    stop(sprintf("Spreadsheet only contains %d worksheets.", ss$n_ws))
  }
  if(verbose) {
    message(sprintf("Accessing worksheet titled \"%s\"", ss$ws$ws_title[ws]))
  }
  ss$ws[ws, ]
}

#' List the worksheets in a Google Sheet
#'
#' Retrieve the titles of all the worksheets in a \code{\link{googlesheet}}.
#'
#' @inheritParams get_via_lf
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- gs_key(gap_key)
#' gs_ws_ls(gap_ss)
#' }
#' @export
gs_ws_ls <- function(ss) {

  stopifnot(inherits(ss, "googlesheet"))

  ss$ws$ws_title
}

#' Extract sheet key from its browser URL
#'
#' @param url URL seen in the browser when visiting the sheet
#'
#' @examples
#' \dontrun{
#' gap_url <- "https://docs.google.com/spreadsheets/d/1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA/"
#' gap_key <- extract_key_from_url(gap_url)
#' gap_ss <- gs_key(gap_key)
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
