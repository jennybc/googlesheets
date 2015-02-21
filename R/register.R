#' Get a listing of spreadsheets
#' 
#' Lists spreadsheets that the authorized user would see in the Google Sheets 
#' home screen: \url{https://docs.google.com/spreadsheets/}. For these sheets, 
#' get sheet title, owner, user's permission, date-time of last update, the 
#' unique key, and the worksheets feed.
#' 
#' This function returns the information available from the 
#' \href{https://developers.google.com/google-apps/spreadsheets/#retrieving_a_list_of_spreadsheets}{spreadsheets
#' feed} of the Google Sheets API.
#' 
#' This listing give the user a partial view of the sheets you available for 
#' access (why just partial? see below). It also gives a map between readily 
#' available information, such as sheet title, and more obscure information you 
#' might use in scripts, such as the sheet key. This sort of "table lookup" is 
#' implemented in the \code{gspreadr} helper function 
#' \code{\link{identify_sheet}}.
#' 
#' Which sheets show up here? Certainly those owned by the authorized user. But 
#' also a subset of the sheets owned by others but visible to the authorized 
#' user. We have yet to find explicit Google documentation on this issue 
#' Anecdotally, sheets shared by others seem to appear in this listing if 
#' the authorized user has visited them in the browser. This is an important 
#' point for usability because a sheet can be summoned by title instead of
#' key only if it appears in this listing. For shared sheets that may not appear
#' in this listing, a more robust workflow is to extract the key from the 
#' browser URL via \code{\link{extract_key_from_url}} and explicitly specify the
#' sheet in \code{gspreadr} functions by key.
#' 
#' @return a data.frame, one row per sheet.
#'   
#' @export
list_sheets <- function() {
  
  the_url <- build_req_url("spreadsheets")
  
  req <- gsheets_GET(the_url)
  
  sheet_list <- req$content %>% lfilt("^entry$")
  
  ## wrangling prep useful for the data.frame formed below; gets the worksheets 
  ## feed for each sheet; if ends with 'values' permission is read only,
  ## if ends with 'full' permission is read/write
  ws_feed <- plyr::laply(sheet_list, function(x) {
    links <- x %>% lfilt("^link$") %>% do.call("rbind", .) %>% 
      as.data.frame(stringsAsFactors = FALSE)
    links$href[grepl("2006#worksheetsfeed", links$rel)]
  })
  
  dplyr::data_frame(
    sheet_title = plyr::laply(sheet_list, function(x) x$title$text),
    sheet_key = sheet_list %>% lapluck("id") %>% basename,
    owner = plyr::laply(sheet_list, function(x) x$author$name),
    perm = ws_feed %>% stringr::str_detect("values") %>% ifelse("r", "rw"),
    last_updated = sheet_list %>% lapluck("updated") %>%
      as.POSIXct(format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
    ws_feed = ws_feed)

}

#' Retrieve the identifiers for a spreadsheet
#' 
#' Retrieve a list with all the identifying information for a specific 
#' spreadsheet. It calls \code{\link{list_sheets}} and attempts to return the 
#' row uniquely specified by input \code{x}. The listing provided by 
#' \code{\link{list_sheets}} is only available to an authorized user, so 
#' authorization will be required.
#' 
#' @param x character vector of length one, with sheet-identifying 
#'   information; it will be considered as URL, sheet title or key, until one of
#'   those hopefully make sense and uniquely identifies sheet
#' @param verbose logical
#'   
#' @return a list with information about the sheet
#'   
#' @export
identify_sheet <- function(x, verbose = TRUE) {
  
  if(!is.character(x)) {
    stop("The information that specifies the sheet must be character, regardless of whether it is the URL, title, key or worksheets feed.")
  } else {
    if(length(x) != 1) {
      stop("The character vector that specifies the sheet must be of length 1.")
    }    
  }
  
  ## is x a URL?
  ## look for https as start of string
  if(x %>% stringr::str_detect("^https://")) {
    if(verbose) {
      mess <- sprintf("Identifying info \"%s\" will be processed as a URL; gspreadr will attempt to extract sheet key from the URL.", x)
      message(mess)
    }
    x <- x %>% extract_key_from_url()
  }
  
  ## assume x is a sheet title, key, or ws_feed from now on
  
  ## we need listing of sheets visible to this user
  ssfeed_df <- list_sheets() %>%
    dplyr::select_(~ sheet_title, ~sheet_key, ~ws_feed)
  
  ## can we find x in the variables that hold identifiers?
  match_here <- ssfeed_df %>%
    ## using llply, not match, to detect multiple matches
    plyr::llply(function(z) which(z == x))
  
  n_match <- match_here %>% plyr::laply(length)
  
  if(any(n_match > 1)) { # oops! multiple matches within identifier(s)
    mess <- sprintf("Identifying info \"%s\" has multiple matches in these identifiers: %s\n", x, names(match_here)[n_match > 1])
    stop(mess)
  } else { # at most one match per identifier, so unlist now
    match_here <- match_here %>% unlist()
  }
  
  if(all(n_match < 1)) { # oops! no match anywhere
    mess <- sprintf("Identifying info \"%s\" doesn't match title, key, or worksheets feed for any sheet listed in the Google sheets home screen for authorized user.", x)
    stop(mess)
  }
  
  if(match_here %>% unique() %>% length() > 1) { # oops! conflicting matches
    mess <- sprintf("Identifying info \"%s\" has conflicting matches in multiple identifiers: %s\n", x,
                    names(match_here)[n_match > 0] %>% stringr::str_c(collapse = ", "))
    stop(mess)
  }
  
  the_match <- match_here %>% unique()
  x_ss <- ssfeed_df[the_match, ] %>% as.list()
  
  if(verbose) {
    mess <- sprintf("Sheet identified!\nsheet_title: %s\nsheet_key: %s\nws_feed: %s\n", x_ss$sheet_title, x_ss$sheet_key, x_ss$ws_feed)
    message(mess)
  }
  
  x_ss
  
}

#' Register a Google spreadsheet
#' 
#' Specify a Google spreadsheet via its URL, unique key, title, or worksheets 
#' feed and register it for further use. This function returns an object of 
#' class \code{spreadsheet}, which contains all the information other 
#' \code{gspreadr} functions will need to consume data from the sheet or 
#' to edit the sheet. This object also contains sheet information 
#' that may be of interest to the user, such as the time of last update, the 
#' number of worksheets contained, and their titles.
#' 
#' @param x character vector of length one, with sheet-identifying 
#'   information; valid inputs are title, key, URL, worksheets feed
#' @param key character vector of length one that is guaranteed to be unique key
#'   for sheet; supercedes argument \code{x}
#' @param ws_feed character vector of length one that is guaranteed to be
#'   worksheets feed for sheet; supercedes arguments \code{x} and
#'   \code{key}
#' @param visibility either "public" or "private"; used to specify visibility
#'   when sheet identified via \code{key}
#'   
#' @return Object of class spreadsheet.
#'   
#' @note The data extent reported for worksheets is probably not what you think 
#'   or hope it is. It does not report how many rows or columns are actually 
#'   nonempty This cannot be determined via the Google sheets API without 
#'   consuming the data and noting which cells are populated. Therefore, these 
#'   numbers generally reflect the default extent of a new worksheet, e.g., 1000
#'   rows and 26 columns at the time or writing, and provide an upper bound on 
#'   the true number of rows and columns.
#'   
#' @note The visibility can only be "public" if the sheet is "Published to
#'   the web". Gotcha: this is different from setting the sheet to "Public
#'   on the web" in the visibility options in the sharing dialog of a Google 
#'   Sheets file.
#'   
#' @export
register <- function(x, key = NULL, ws_feed = NULL, visibility = "private") {
  
  if(is.null(ws_feed)) {
    if(is.null(key)) { # figure out the sheet from x
      ws_feed <- x %>% identify_sheet() %>% `[[`("ws_feed")
    } else {           # take key at face value
      template <-
        "https://spreadsheets.google.com/feeds/worksheets/key/visibility/full"
      ws_feed <- template %>%
        stringr::str_replace("key", key) %>% 
        stringr::str_replace("visibility", visibility)
    }
  }                    # else ... take ws_feed at face value
  
  req <- gsheets_GET(ws_feed)
  
  if(grepl("html", req$headers[["content-type"]])) {
    ## TO DO: give more specific error message. Have they said "public" when 
    ## they meant "private" or vice versa? What's the actual problem and
    ## solution?
    stop("Please check visibility settings.")
  }
  
  ss <- spreadsheet()
  
  ss$sheet_key <- ws_feed %>%
    stringr::str_replace("(https://spreadsheets.google.com/feeds/worksheets/)([^/]+)(.*)", "\\2")
  ss$sheet_title <- req$content[["title"]][["text"]]
  ss$n_ws <- req$content[["totalResults"]] %>% as.integer
  
  ss$ws_feed <- req$url               # same as sheet_id ... pick one?
  ss$sheet_id <- req$content[["id"]]  # same as ws_feed ... pick one?
  # for that matter, this URL appears a third time as the "self" link below :(
  
  ss$updated <- req$content[["updated"]] %>%
    as.POSIXct(format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
  ss$get_date <- req$date
  
  ## I'm ambivalent about even storing this; it's baked into the links
  ## holdover from an earlier stage of pkg development ... omit?
  ss$visibility <- req$url %>% dirname %>% basename
  
  ss$author_name <- req$content[["author"]][["name"]]
  ss$author_email <- req$content[["author"]][["email"]]
  
  ss$links <- req$content %>%
    lfilt("^link$") %>%
    plyr::ldply %>% dplyr::select_(quote(-.id))
  ## select_() will be unnecessary when this PR gets merged into plyr
  ## https://github.com/hadley/plyr/pull/207
  ## and ldply handles '.id = NULL' correctly
  
  ws_list <- req$content %>% lfilt("^entry$")
  ws_info <-
    dplyr::data_frame_(
      list(ws_id = ~ ws_list %>% lapluck("id"),
           ws_key = ~ ws_id %>% basename,
           ws_title = ~ plyr::laply(ws_list, function(x) x$title$text),
           row_extent = ~ ws_list %>% lapluck("rowCount") %>% as.integer(),
           col_extent = ~ ws_list %>% lapluck("colCount") %>% as.integer()))
  ws_links <- plyr::ldply(ws_list, function(x) {
    links <- x %>% lfilt("^link$") %>% do.call("cbind", .)
    links["href", ] %>%
      setNames(links["rel", ] %>% basename %>%
                 stringr::str_replace("[0-9]{4}#", ""))
  }) %>% dplyr::select_(quote(-.id))
  ## see comment above about ldply(.id = NULL)
  
  ss$ws <- dplyr::bind_cols(ws_info, ws_links)
  ss
}

