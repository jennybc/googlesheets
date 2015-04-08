#' Get a listing of spreadsheets
#' 
#' Lists spreadsheets that the authorized user would see in the Google Sheets 
#' home screen: \url{https://docs.google.com/spreadsheets/}. For these sheets, 
#' get sheet title, sheet key, owner, user's permission, date-time of last
#' update, version (old vs new Sheets), various links, and an alternative key
#' (only relevant to old Sheets).
#' 
#' This function returns the information available from the 
#' \href{https://developers.google.com/google-apps/spreadsheets/#retrieving_a_list_of_spreadsheets}{spreadsheets
#' feed} of the Google Sheets API.
#' 
#' This listing give the user a partial view of the sheets available for access
#' (why just partial? see below). It also gives a map between readily available
#' information, such as sheet title, and more obscure information you might use
#' in scripts, such as the sheet key. This sort of "table lookup" is implemented
#' in the \code{googlesheets} helper function \code{\link{identify_ss}}.
#' 
#' Which sheets show up here? Certainly those owned by the authorized user. But 
#' also a subset of the sheets owned by others but visible to the authorized 
#' user. We have yet to find explicit Google documentation on this matter. 
#' Anecdotally, sheets shared by others seem to appear in this listing if the
#' authorized user has visited them in the browser. This is an important point
#' for usability because a sheet can be summoned by title instead of key only if
#' it appears in this listing. For shared sheets that may not appear in this
#' listing, a more robust workflow is to extract the key from the browser URL
#' via \code{\link{extract_key_from_url}} and explicitly specify the sheet in
#' \code{googlesheets} functions by key.
#' 
#' @return a tbl_df, one row per sheet
#'   
#' @examples
#' \dontrun{
#' list_sheets()
#' }
#' 
#' @export
list_sheets <- function() {

  # only calling spreadsheets feed from here, so hardwiring url
  the_url <- "https://spreadsheets.google.com/feeds/spreadsheets/private/full"

  req <- gsheets_GET(the_url)

  sheet_list <- req$content %>% lfilt("^entry$")
  
  links <- plyr::ldply(sheet_list, function(x) {
    links <- x %>%
      lfilt("^link$") %>%
      unname() %>% 
      do.call("cbind", .)
    dplyr::data_frame(ws_feed =
                        links["href",
                              grepl("2006#worksheetsfeed", links["rel", ])],
                      alternate_link =
                        links["href",
                              grepl("alternate", links["rel", ])],
                      self_link = links["href",
                                        grepl("self", links["rel", ])])
  }) %>% dplyr::select_(quote(-.id))

  dplyr::data_frame(
    sheet_title = plyr::laply(sheet_list, function(x) x$title$text),
    sheet_key = sheet_list %>%
      lapluck("id") %>%
      basename,
    owner = plyr::laply(sheet_list,
                        function(x) paste0(x$author$name, " <",
                                           x$author$email, ">")),
    perm = links$ws_feed %>%
      stringr::str_detect("values") %>%
      ifelse("r", "rw"),
    last_updated = sheet_list %>%
      lapluck("updated") %>%
      as.POSIXct(format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
    version = ifelse(grepl("^https://docs.google.com/spreadsheets/d",
                           links$alternate_link), "new", "old"),
    ws_feed = links$ws_feed,
    alternate = links$alternate_link,
    self = links$self_link,
    alt_key = ifelse(version == "new", NA_character_,
                     extract_key_from_url(links$alternate_link)))

}

#' Retrieve the identifiers for a spreadsheet
#' 
#' Initialize a googlesheet object that holds identifying information for a 
#' specific spreadsheet. Intended primarily for internal use. Unless 
#' \code{verify = FALSE}, it calls \code{\link{list_sheets}} and attempts to 
#' return information from the row uniquely specified by input \code{x}. The 
#' listing provided by \code{\link{list_sheets}} is only available to an 
#' authorized user, so authorization will be required. A googlesheet object 
#' contains much more information than that available via 
#' \code{\link{list_sheets}}, so many components will not be populated until the
#' sheet is registered properly, such as via \code{\link{register_ss}}, which is
#' called internally in many \code{googlesheets} functions. If \code{verify = 
#' FALSE}, then user must provide either sheet key, URL or a worksheets feed, as
#' opposed to sheet title. In this case, the information will be taken at face
#' value, i.e. no proactive verification or look-up on Google Drive.
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
      ws_feed <- x %>%
        identify_ss(visibility = TRUE, verbose = verbose) %>%
        `[[`("ws_feed")
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

  ss <- googlesheet()
  
  ss$sheet_key <- ws_feed %>% extract_key_from_url()
  ss$sheet_title <- req$content[["title"]][["text"]]
  ss$n_ws <- req$content[["totalResults"]] %>% as.integer()

  ss$ws_feed <- req$url               # same as sheet_id ... pick one?
  ss$sheet_id <- req$content[["id"]]  # same as ws_feed ... pick one?
  # for that matter, this URL appears a third time as the "self" link below :(

  ss$updated <- req$headers$`last-modified` %>% httr::parse_http_date()
  ss$get_date <- req$headers$date %>% httr::parse_http_date()

  ss$visibility <- req$url %>% dirname() %>% basename()
  ss$is_public <- ss$visibility == "public"
  
  ss$author_name <- req$content[["author"]][["name"]]
  ss$author_email <- req$content[["author"]][["email"]]

  ss$links <- req$content %>%
    lfilt("^link$") %>%
    plyr::ldply() %>% dplyr::select_(quote(-.id))
  ## select_() will be unnecessary when this PR gets merged into plyr
  ## https://github.com/hadley/plyr/pull/207
  ## and ldply handles '.id = NULL' correctly

  ws_list <- req$content %>% lfilt("^entry$")
  ws_info <-
    dplyr::data_frame_(
      list(ws_id = ~ ws_list %>% lapluck("id"),
           ws_key = ~ ws_id %>% basename,
           ws_title = ~ plyr::laply(ws_list, function(x) x$title$text),
           row_extent = ~ ws_list %>%
             lapluck("rowCount") %>%
             as.integer(),
           col_extent = ~ ws_list %>% lapluck("colCount") %>% as.integer()))
  ws_links <- plyr::ldply(ws_list, function(x) {
    links <- x %>%
      lfilt("^link$") %>%
      do.call("cbind", .)
    links["href", ] %>%
      setNames(links["rel", ] %>%
                 basename %>%
                 stringr::str_replace("[0-9]{4}#", ""))
  }) %>%
    dplyr::select_(quote(-.id))
  ## see comment above about ldply(.id = NULL)

  ss$ws <- dplyr::bind_cols(ws_info, ws_links)
  ss
}
