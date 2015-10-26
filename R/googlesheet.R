## nothing here is exported
## where do googlesheet objects come from?
## from the user-facing sheet registration functions in gs_register.R:
## gs_title(), gs_key(), gs_url(), gs_ws_feed()
## in all cases, sheet-identifying info is parlayed into a ws_feed
## then as.googlesheet.ws_feed() gets called to register the sheet
## and produce a googlesheet object

googlesheet <- function() {
  structure(list(sheet_key = character(),
                 sheet_title = character(),
                 n_ws = integer(),
                 ws_feed = character(),
                 browser_url = character(),
                 updated = character() %>% as.POSIXct(),
                 reg_date = character() %>% as.POSIXct(),
                 visibility = character(),
                 lookup = NA,
                 is_public = logical(),
                 author = character(),
                 email = character(),
                 perm = character(),
                 version = character(),
                 links = character(), # initialize as data.frame?
                 ws = list(),
                 ## from the spreadsheets feed
                 alt_key = NA_character_),
            class = c("googlesheet", "list"))
}

as.googlesheet <-
  function(x, ssf = NULL, lookup, verbose = TRUE, ...) UseMethod("as.googlesheet")

as.googlesheet.ws_feed <-
  function(x, ssf = NULL, lookup, verbose = TRUE, ...) {

  req <- gsheets_GET(x)

  if(grepl("html", req$headers[["content-type"]])) {
    ## TO DO: give more specific error message. Have they said "public" when
    ## they meant "private" or vice versa? What's the actual problem and
    ## solution?
    stop("Please check visibility settings.")
  }

  ns <- xml2::xml_ns_rename(xml2::xml_ns(req$content), d1 = "feed")

  ss <- googlesheet()

  ss$sheet_key <- req$url %>% extract_key_from_url()
  ss$sheet_title <- req$content %>%
    xml2::xml_find_one("./feed:title", ns) %>% xml2::xml_text()
  ss$n_ws <- req$content %>%
    xml2::xml_find_one("./openSearch:totalResults", ns) %>%
    xml2::xml_text() %>%
    as.integer()

  ss$ws_feed <- req$url          # same as the "self" link below  ... pick one?
  ss$browser_url <- construct_url_from_key(ss$sheet_key)

  ss$updated <- req$headers$`last-modified` %>% httr::parse_http_date()
  ss$reg_date <- req$headers$date %>% httr::parse_http_date()

  ss$visibility <- req$url %>% dirname() %>% basename()
  ss$lookup <- lookup
  ss$is_public <- ss$visibility == "public"

  ss$author <- req$content %>%
    xml2::xml_find_one("./feed:author/feed:name", ns) %>% xml2::xml_text()
  ss$email <- req$content %>%
    xml2::xml_find_one("./feed:author/feed:email", ns) %>% xml2::xml_text()

  ss$perm <- ss$ws_feed %>%
    stringr::str_detect("values") %>%
    ifelse("r", "rw")
  ss$version <- "old" ## we revise this once we get the links, below ...

  links <- req$content %>% xml2::xml_find_all("./feed:link", ns)
  ss$links <- dplyr::data_frame_(list(
    rel = ~ links %>% xml2::xml_attr("rel"),
    type = ~ links %>% xml2::xml_attr("type"),
    href = ~ links %>% xml2::xml_attr("href")
  ))

  if(grepl("^https://docs.google.com/spreadsheets/d",
           ss$links$href[ss$links$rel == "alternate"])) {
    ss$version <- "new"
  }

  ws <- req$content %>% xml2::xml_find_all("./feed:entry", ns)
  ws_info <- dplyr::data_frame_(list(
    ws_id = ~ ws %>% xml2::xml_find_all("feed:id", ns) %>% xml2::xml_text(),
    ws_key = ~ ws_id %>% basename(),
    ws_title =
      ~ ws %>% xml2::xml_find_all("feed:title", ns) %>% xml2::xml_text(),
    row_extent =
      ~ ws %>% xml2::xml_find_all("gs:rowCount", ns) %>%
      xml2::xml_text() %>% as.integer(),
    col_extent =
      ~ ws %>% xml2::xml_find_all("gs:colCount", ns) %>%
      xml2::xml_text() %>% as.integer()
  ))

  ## use the first worksheet to learn about the links available
  ## why we do this?
  ## because the 'edit' link will not be available for sheets accessed via
  ## public visibility or to which user does not have write permission
  link_rels <- ws[1] %>%
    xml2::xml_find_all("feed:link", ns) %>%
    xml2::xml_attrs() %>%
    vapply(`[`, FUN.VALUE = character(1), "rel")
  ## here's what we expect here
  #   [1] "http://schemas.google.com/spreadsheets/2006#listfeed"
  #   [2] "http://schemas.google.com/spreadsheets/2006#cellsfeed"
  #   [3] "http://schemas.google.com/visualization/2008#visualizationApi"
  #   [4] "http://schemas.google.com/spreadsheets/2006#exportcsv"
  #   [5] "self"
  #   [6] "edit"  <-- absent in some cases
  names(link_rels) <-
    link_rels %>% basename() %>% gsub("200[[:digit:]]\\#", '', .)
  ## here's what we expect here
  ## "listfeed" "cellsfeed" "visualizationApi" "exportcsv" "self" ?"edit"?

  ws_links <- ws %>% xml2::xml_find_all("feed:link", ns)
  ws_links <- lapply(link_rels, function(x) {
    xpath <- paste0("../*[@rel='", x, "']")
    ws_links %>%
      xml2::xml_find_all(xpath, ns) %>%
      xml2::xml_attr("href")
  }) %>%
    dplyr::as_data_frame()

  ss$ws <- dplyr::bind_cols(ws_info, ws_links)

  if(!is.null(ssf)) {
    ss$alt_key <- ssf$alt_key
  }

  ss

}
