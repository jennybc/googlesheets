#' Get a listing of available spreadsheets
#' 
#' For all spreadsheets available to the authenticated user, get spreadsheet 
#' title, owner, user's permission, date-time of last update and, optionally, 
#' the unique key. Should return the spreadsheets that are visible in Google
#' Drive. Return as a data.frame, one row per spreadsheet.
#' 
#' @param include_key \code{logical} to control inclusion of spreadsheet keys
#'   
#' @export
list_spreadsheets <- function(include_key = TRUE) {
  
  the_url <- build_req_url("spreadsheets")
  
  req <- gsheets_GET(the_url)
  
  sheet_list <- req$content %>% lfilt("^entry$")
  
  ## wrangling prep useful for the data.frame formed below; gets the worksheets 
  ## feed for each spreadsheet; if ends with 'values' permission is read only,
  ## if ends with 'full' permission is read/write
  ws_feed <- plyr::laply(sheet_list, function(x) {
    links <- x %>% lfilt("^link$") %>% do.call("rbind", .) %>% 
      as.data.frame(stringsAsFactors = FALSE)
    links$href[grepl("2006#worksheetsfeed", links$rel)]
  })
  
  sheets_df <- dplyr::data_frame(
    sheet_title = plyr::laply(sheet_list, function(x) x$title$text),
    sheet_key = sheet_list %>% lapluck("id") %>% basename,
    owner = plyr::laply(sheet_list, function(x) x$author$name),
    perm = ws_feed %>% stringr::str_detect("values") %>% ifelse("r", "rw"),
    last_updated = sheet_list %>% lapluck("updated") %>%
      as.POSIXct(format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
    ws_feed = ws_feed)
  
  if(include_key) {
    sheets_df
  } else {
    dplyr::select_(sheets_df, quote(-sheet_key))
  }
  
}

#' Register a Google spreadsheet
#' 
#' Specify a Google spreadsheet via its URL, unique key, title, or worksheets 
#' feed and register it for further use. This function returns an object of 
#' class \code{spreadsheet}, which contains all the information other 
#' \code{gspreadr} functions will need to consume data from the spreadsheet or 
#' to edit the spreadsheet. This object also contains spreadsheet information 
#' that may be of interest to the user, such as the time of last update, the 
#' number of worksheets contained, and their titles.
#' 
#' @param x character vector of length one, with spreadsheet-identifying 
#'   information
#' @param visibility either "public" or "private"
#'   
#' @return Object of class spreadsheet.
#'   
#' @note The data extent reported for worksheets is probably not what you think 
#'   or hope it is. It does not report how many rows or columns are actually 
#'   nonempty This cannot be determined via the Google Spreadsheets API without 
#'   consuming the data and noting which cells are populated. Therefore, these 
#'   numbers generally reflect the default extent of a new worksheet, e.g., 1000
#'   rows and 26 columns at the time or writing, and provide an upper bound on 
#'   the true number of rows and columns.
#'   
#' @note The visibility can only be "public" if the spreadsheet is "Published to
#'   the web". Gotcha: this is different from setting the spreadsheet to "Public
#'   on the web" in the visibility options in the sharing dialog of a Google
#'   Sheets file.
#'   
#' @export
register <- function(x, visibility = "private") {
  
  ws_feed <- get_ws_feed(x, visibility)

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

#' Obtain the worksheets feed for a spreadsheet
#' 
#' Given a Google spreadsheet's URL, unique key, title, or worksheets feed, 
#' return its worksheets feed. The worksheets feed is simply a URL -- different 
#' from the one you see when visiting a spreadsheet in the browser! -- and is 
#' the very best way to specify a spreadsheet for API access. There's no simple 
#' way to capture a spreadsheet's worksheets feed, so this function helps you 
#' convert readily available information (spreadsheet title or URL) into the 
#' worksheets feed.
#' 
#' Simple regexes are used to detect if the input is a worksheets feed or the 
#' URL one would see when visiting a spreadsheet in the browser. If it's a URL, 
#' we attempt to extract the spreadsheet's unique key, assuming the URL follows
#' the pattern characteristic of "new style" Google spreadsheets.
#' 
#' Otherwise the input is assumed to be the spreadsheet's title or unique key. 
#' When we say title, we mean the name of the spreadsheet in, say, Google Drive 
#' or in the \code{sheet_title} variable of the data.frame returned by 
#' \code{\link{list_spreadsheets}}. Spreadsheet title or key will be sought in 
#' the listing of spreadsheets visible to the authenticated user and, if a match
#' is found, the associated worksheets feed is returned.
#' 
#' @param x character vector of length one, with spreadsheet-identifying 
#'   information
#' @param visibility either "public" or "private"
#'   
#' @return The worksheets feed for the specified spreadsheet
#'   
#' @export
get_ws_feed <- function(x, visibility = "private") {
  
  is_key <- FALSE
  
  if(!is.character(x)) {
    stop("The information that specifies the spreadsheet must be character, regardless of whether it is the URL, title, key or worksheets feed.")
  } else {
    if(length(x) != 1) {
      stop("The character vector that specifies the spreadsheet must be of length 1.")
    }    
  }
  
  ## is x already worksheets feed? if so, we're done!
  url_start <- "https://spreadsheets.google.com/feeds/worksheets"
  if(x %>%
       stringr::str_detect(stringr::fixed(url_start))) {
    return(x)
  }
  
  ## is x the URL from visiting sheet in browser? if so, try to get key
  ## this is dodgy, definitely assumes "new style sheets"
  url_start <- "https://docs.google.com/spreadsheets/d/"
  if(x %>% stringr::str_detect(stringr::fixed(url_start))) {
    x <- x %>% stringr::str_replace(url_start, '') %>%
      stringr::str_split_fixed('/', n = 2) %>%
      "["(1)
    is_key <- TRUE
  }
  
  ## assume x is a spreadsheet title or key
  
  ## we need listing of spreadsheets visible to this user
  ssfeed_df <- list_spreadsheets()
  
  if(!is_key) {
    
    ## is x a title?
    title_index <- match(x, ssfeed_df$sheet_title)
    
    if(is.na(title_index)) { ## no, not a title ...
      
      ## is x a key?
      key_index <- match(x, ssfeed_df$sheet_key)
      
      if(is.na(key_index)) { ## no, not a key ...
        stop(sprintf("\nThis piece of identifying info:\n\"%s\"\ndoesn't match the title or key of a spreadsheet accessible by the current authenticated user.",
                     x))
      } else { ## yes, x is a key
        x <- ssfeed_df$sheet_key[key_index]
        is_key <- TRUE
      }
    } else { ## yes, x is a title
      
      x <- ssfeed_df$sheet_key[title_index]
      is_key <- TRUE
      
    }  
  }
    
  if(is_key) {
    ## TO DO: set the visibility based on ownership reported in ssfeed_df?
    return(build_req_url("worksheets", key = x, visibility = visibility))
  } else {
    ## honestly, I don't think we should ever get to this point
    stop("This spreadsheet specification seems to be none of these things: URL, title, unique key, or worksheets feed.")
  }
}
