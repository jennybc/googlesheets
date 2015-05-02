#' Get a listing of spreadsheets
#'
#' Please use \code{\link{gs_ls}} instead. This function is going away.
#'
#' @return a \code{googlesheet_ls} object, which is a
#'   \code{\link[dplyr]{tbl_df}} with one row per sheet
#'
#' @examples
#' \dontrun{
#' gs_ls()
#' }
#'
#' @export
list_sheets <- gs_ls

#' Retrieve the identifiers for a spreadsheet
#'
#' Initialize a googlesheet object that holds identifying information for a
#' specific spreadsheet. Intended primarily for internal use. Unless
#' \code{verify = FALSE}, it calls \code{\link{list_sheets}} and attempts to
#' return information from the row uniquely specified by input \code{x}. Since
#' \code{\link{list_sheets}} fetches non-public user data, authorization will be
#' required. A googlesheet object contains much more information than that
#' available via \code{\link{list_sheets}}, so many components will not be
#' populated until the sheet is registered properly, such as via
#' \code{\link{register_ss}}, which is called internally in many
#' \code{googlesheets} functions. If \code{verify = FALSE}, then user must
#' provide either sheet key, URL or a worksheets feed, as opposed to sheet
#' title. In this case, the information will be taken at face value, i.e. no
#' proactive verification or look-up on Google Drive.
#'
#' This function is will be revised to be less dogmatic about only identifying
#' ONE sheet.
#'
#' @param x sheet-identifying information, either a googlesheet object or a
#'   character vector of length one, giving a URL, sheet title, key or
#'   worksheets feed
#' @param method optional character string specifying the method of sheet
#'   identification; if given, must be one of: URL, key, title, ws_feed, or ss
#' @param verify logical, default is TRUE, indicating if sheet should be looked
#'   up in the list of sheets obtained via \code{\link{list_sheets}}
#' @param visibility character, default is "private", indicating whether to form
#'   a worksheets feed that anticipates requests with authentication ("private")
#'   or without ("public"); only consulted when \code{verify = FALSE}
#' @param verbose logical
#'
#' @return a googlesheet object
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_id_only <- identify_ss(gap_key)
#' gap_id_only # see? not much info at this point
#' gap_ss <- register_ss(gap_id)
#' gap_ss      # much more available after registration
#' }
#'
#' @export
identify_ss <- function(x, method = NULL, verify = TRUE,
                        visibility = "private", verbose = TRUE) {

  if(!inherits(x, "googlesheet")) {
    if(!is.character(x)) {
      stop(paste("The information that specifies the sheet must be character,",
                 "regardless of whether it is the URL, title, key or",
                 "worksheets feed."))
    } else {
      if(length(x) != 1) {
        stop(paste("The character vector that specifies the sheet must be of",
                   "length 1."))
      }
    }
  }

  method <-
    match.arg(method,
              choices = c('unknown', 'url', 'key', 'title', 'ws_feed', 'ss'))

  ## is x a googlesheet object?
  if(method == 'ss' || inherits(x, "googlesheet")) {
    if(verify) {
      if(verbose) {
        message("Identifying info is a googlesheet object; googlesheets will re-identify the sheet based on sheet key.")
      }
      x <- x$sheet_key
      method <- 'key'
    } else { ## it's a googlesheet, no verification requested
      ## so just pass it on through
      return(x)
    }
  } ## if x was ss, x is now a key

  ## is x a URL but NOT a worksheets feed?
  ws_feed_start <- "https://spreadsheets.google.com/feeds/worksheets"
  if(method == 'url' ||
     (x %>% stringr::str_detect("^https://") &&
      !(x %>% stringr::str_detect(ws_feed_start))
     )) {
    if(verbose) {
      paste0("Identifying info will be processed as a URL.\n",
             "googlesheets will attempt to extract sheet key from the URL.") %>%
        message()
    }
    x <- x %>% extract_key_from_url()
    method <- 'key'
    if(verbose) {
      mess <- sprintf("Putative key: %s", x)
      message(mess)
    }
  } ## if x was URL (but not ws_feed), x is now a key

  ## x is now known or presumed to be key, title, or ws_feed

  if(!verify) {
    if(method == 'title') {
      stop("Impossible to identify a sheet based on title when verify = FALSE. googlesheets must look up the title to obtain key or worksheets feed.")
    }

    ## if method still unknown, make a guess between key or ws_feed
    if(method == 'unknown') {
      if(x %>% stringr::str_detect(ws_feed_start)) {
        method <- 'ws_feed'
      } else {
        method <- 'key'
      }
    }

    if(verbose) {
      message(sprintf("Identifying info will be handled as: %s.", method))
    }

    ss <- googlesheet()

    if(method == 'key') {
      ss$sheet_key <- x
      ss$ws_feed <- construct_ws_feed_from_key(x, visibility)
    }

    if(method == 'ws_feed') {
      ss$ws_feed <- x
      ss$sheet_key <- x %>% extract_key_from_url()
    }

    if(verbose) {
      message(sprintf("Unverified sheet key: %s.", ss$sheet_key))
      #message(sprintf("Unverified worksheets feed: %s.", ss$ws_feed))
    }

    return(ss)
  }

  ## we need listing of sheets visible to this user
  ssfeed_df <- list_sheets() %>%
    dplyr::select_(~ sheet_title, ~sheet_key, ~ws_feed, ~alt_key)

  ## can we find x in the variables that hold identifiers?
  match_here <- ssfeed_df %>%
    ## using llply, not match, to detect multiple matches
    plyr::llply(function(z) which(z == x))

  n_match <- match_here %>% plyr::laply(length)

  if(any(n_match > 1)) { # oops! multiple matches within identifier(s)
    mess <- sprintf(paste("Identifying info \"%s\" has multiple matches in",
                          "these identifiers: %s\n"), x,
                    names(match_here)[n_match > 1])
    stop(mess)
  } else { # at most one match per identifier, so unlist now
    match_here <- match_here %>% unlist()
  }

  if(all(n_match < 1)) { # oops! no match anywhere
    mess <- sprintf(paste("Identifying info \"%s\" doesn't match title, key,",
                          "or worksheets feed for any sheet listed in the",
                          "Google sheets home screen for authorized user."), x)
    stop(mess)
  }

  if(match_here %>% unique() %>% length() > 1) { # oops! conflicting matches
    mess <- sprintf(paste("Identifying info \"%s\" has conflicting matches in",
                          "multiple identifiers: %s\n"), x,
                    names(match_here)[n_match > 0] %>%
                      stringr::str_c(collapse = ", "))
    stop(mess)
  }

  the_match <- match_here %>% unique()
  x_ss <- ssfeed_df[the_match, ] %>% as.list()

  if(verbose) {
    #mess <- sprintf("Sheet identified!\nsheet_title: %s\nsheet_key: %s\nws_feed: %s\n", x_ss$sheet_title, x_ss$sheet_key, x_ss$ws_feed)
    mess <- sprintf("Sheet identified!\nsheet_title: %s\nsheet_key: %s",
                    x_ss$sheet_title, x_ss$sheet_key)
    message(mess)
    if(!is.na(x_ss$alt_key)) {
      mess <- sprintf("alt_key: %s", x_ss$alt_key)
      message(mess)
    }
  }

  ss <- googlesheet()
  ss$sheet_key <- x_ss$sheet_key
  ss$sheet_title <- x_ss$sheet_title
  ss$ws_feed <- x_ss$ws_feed
  ss$alt_key <- x_ss$alt_key

  ss
}

#' Register a Google spreadsheet
#'
#' Specify a Google spreadsheet via its URL, unique key, title, or worksheets
#' feed and register it for further use. This function returns an object of
#' class \code{googlesheet}, which contains all the information other
#' \code{googlesheets} functions will need to consume data from the sheet or to
#' edit the sheet. This object also contains sheet information that may be of
#' interest to the user, such as the time of last update, the number of
#' worksheets contained, and their titles.
#'
#' @param x character vector of length one, with sheet-identifying information;
#'   valid inputs are title, key, URL, worksheets feed
#' @param key character vector of length one that is guaranteed to be unique key
#'   for sheet; supercedes argument \code{x}
#' @param ws_feed character vector of length one that is guaranteed to be
#'   worksheets feed for sheet; supercedes arguments \code{x} and \code{key}
#' @param visibility either "public" or "private"; used to specify visibility
#'   when sheet identified via \code{key}
#' @param verbose logical; do you want informative message?
#'
#' @return Object of class googlesheet.
#'
#' @note Re: the reported extent of the worksheets. Contain your excitement,
#'   because it may not be what you think or hope it is. It does not report how
#'   many rows or columns are actually nonempty. This cannot be determined via
#'   the Google sheets API without consuming the data and noting which cells are
#'   populated. Therefore, these numbers often reflect the default extent of a
#'   new worksheet, e.g., 1000 rows and 26 columns at the time or writing, and
#'   provide an upper bound on the true number of rows and columns.
#'
#' @note The visibility can only be "public" if the sheet is "Published to the
#'   web". Gotcha: this is different from setting the sheet to "Public on the
#'   web" in the visibility options in the sharing dialog of a Google Sheets
#'   file.
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- register_ss(gap_key)
#' gap_ss
#' get_row(gap_ss, "Africa", row = 1)
#' }
#'
#' @export
register_ss <- function(x, key = NULL, ws_feed = NULL,
                        visibility = "private", verbose = TRUE) {

  if(is.null(ws_feed)) {
    if(is.null(key)) { # get ws_feed from x
      this_ss <- x %>%
        identify_ss(visibility = TRUE, verbose = verbose)
      ws_feed <- this_ss$ws_feed
    } else {           # take key at face value
      ws_feed <- construct_ws_feed_from_key(key, visibility)
    }
  }                    # else ... take ws_feed at face value

  req <- gsheets_GET(ws_feed)

  if(grepl("html", req$headers[["content-type"]])) {
    ## TO DO: give more specific error message. Have they said "public" when
    ## they meant "private" or vice versa? What's the actual problem and
    ## solution?
    stop("Please check visibility settings.")
  }

  ns <- xml2::xml_ns_rename(xml2::xml_ns(req$content), d1 = "feed")

  ss <- googlesheet()

  ss$sheet_key <- ws_feed %>% extract_key_from_url()
  ss$sheet_title <- req$content %>%
    xml2::xml_find_one("./feed:title", ns) %>% xml2::xml_text()
  ss$n_ws <- req$content %>%
    xml2::xml_find_one("./openSearch:totalResults", ns) %>% xml2::xml_text() %>%
    as.integer()

  ss$ws_feed <- req$url               # same as sheet_id ... pick one?
  ss$sheet_id <- req$content %>%      # same as ws_feed ... pick one?
    # for that matter, this URL appears a third time as the "self" link below :(
    xml2::xml_find_one("./feed:id", ns) %>% xml2::xml_text()

  ss$updated <- req$headers$`last-modified` %>% httr::parse_http_date()
  ss$get_date <- req$headers$date %>% httr::parse_http_date()

  ss$visibility <- req$url %>% dirname() %>% basename()
  ss$is_public <- ss$visibility == "public"

  ss$author_name <- req$content %>%
    xml2::xml_find_one("./feed:author/feed:name", ns) %>% xml2::xml_text()
  ss$author_email <- req$content %>%
    xml2::xml_find_one("./feed:author/feed:email", ns) %>% xml2::xml_text()

  links <- req$content %>% xml2::xml_find_all("./feed:link", ns)
  ss$links <- dplyr::data_frame_(list(
    rel = ~ links %>% xml2::xml_attr("rel"),
    type = ~ links %>% xml2::xml_attr("type"),
    href = ~ links %>% xml2::xml_attr("href")
  ))

  ## if we have info from the spreadsheet feed, use it
  ## that's the only way to populate alt_key
  if(exists("this_ss")) {
    ss$alt_key <- this_ss$alt_key
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

  ## use the first worksheet to learn about the links available why we do this?
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
  ss
}
