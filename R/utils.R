#' Retrieve a worksheet-describing list from a spreadsheet
#' 
#' From a registered spreadsheet, retrieve a list (actually a row of a 
#' data.frame) giving everything we know about a specific worksheet.
#' 
#' @inheritParams get_via_lf
#' @param verbose logical, indicating whether to give a message re: title of the
#'   worksheet being accessed
get_ws <- function(ss, ws, verbose = TRUE) {
  
  stopifnot(inherits(ss, "spreadsheet"),
            length(ws) == 1L,
            is.character(ws) || (is.numeric(ws) && ws > 0))
  
  if(is.character(ws)) {
    index <- match(ws, ss$ws$ws_title)
    if(is.na(index)) {
      stop(sprintf("Worksheet %s not found.", ws))    
    } else {
      ws <- index %>% as.integer()
    }
  }
  if(ws > ss$n_ws) {
    stop(sprintf("Spreadsheet only contains %d worksheets.", ss$n_ws)) 
  }
  if(verbose) {
    message(sprintf("Accessing worksheet titled \"%s\"", ss$ws$ws_title[ws]))
  }
  ss$ws[ws, ]
}

#' List the worksheets in a spreadsheet
#' 
#' Retrieve the titles of all the worksheets in registered spreadsheet.
#' 
#' @inheritParams get_via_lf
#' @export
list_ws <- function(ss) {
  
  stopifnot(inherits(ss, "spreadsheet"))
  
  ss$ws$ws_title

}


#' Convert column IDs from letter representation to numeric
#'
#' @param x character vector of letter-style column IDs (case insensitive)
letter_to_num <- function(x) {
  x %>%
    stringr::str_to_upper() %>%
    stringr::str_split('') %>% 
    plyr::llply(match, table = LETTERS) %>%
    plyr::laply(function(z) sum(26 ^ rev(seq_along(z) - 1) * z)) %>%
    unname()
}


#' Convert column IDs from numeric to letter representation
#'
#' @param x vector of numeric column IDs
num_to_letter <- function(x) {
  stopifnot(x <= letter_to_num('ZZ')) # Google spreadsheets have 300 columns max
  paste0(c("", LETTERS)[((x - 1) %/% 26) + 1],
         LETTERS[((x - 1) %% 26) + 1], sep = "")
}

#' Convert label (A1) notation to coordinate (R1C1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells.
#'
#' @param x label notation for position of cell
label_to_coord <- function(x) {
  paste0("R", stringr::str_extract(x, "[[:digit:]]*$") %>% as.integer(),
         "C", stringr::str_extract(x, "^[[:alpha:]]*") %>% letter_to_num())
}


#' Convert coordinate (R1C1) notation to label (A1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells.
#'
#' @param x coord notation for position of cell
coord_to_label <- function(x) {
  paste0(sub("^R[0-9]+C([0-9]+)$", "\\1", x) %>%
           as.integer() %>% num_to_letter(),
         sub("^R([0-9]+)C[0-9]+$", "\\1", x))
}

#' Convert a cell range into a limits list
#'
#' @param range character vector, length one, such as "A1:D7"
convert_range_to_limit_list <- function(range) {
  
  tmp <- range %>%
    stringr::str_split_fixed(":", 2) %>% ## A1:C5 --> "A1", "D5" as 1-row matrix
    drop() %>%                           ## 1-row matrix --> vector
    {                                    ## handle case of single cell input
      x <- .[. != ""]                    ## replicate the single address
      rep_len(x, 2)                      ## "C5" --> "C5", "" --> "C5", "C5"
    }
  
  A1_regex <- "^[A-Za-z]{1,2}[0-9]+$"
  R1C1_regex <- "^R([0-9]+)C([0-9]+$)"
  valid_regex <- stringr::str_c(c(A1_regex, R1C1_regex), collapse = "|")
  if(!all(tmp %>% stringr::str_detect(valid_regex))) {
    mess <- sprintf("Trying to set cell limits, but requested range is invalid:\n %s\n", paste(tmp, collapse = ", "))
    stop(mess)
  }
  
  ## convert addresses like "B4" to "R4C2"
  rcrc <- all(tmp %>% stringr::str_detect("^R[0-9]+C[0-9]+$"))
  if(!rcrc) {
    tmp <- tmp %>% label_to_coord()    ## "A1", "C5" --> "R1C1", "R5C4"
  }
  
  ## complete conversion to a limits list
  tmp %>% 
    ## "R1C1", "R5C4" --> matrix w/ 2 rows, one per cell
    ## 3 columns: full address, the row part, the column part
    stringr::str_match("^R([0-9]+)C([0-9]+$)") %>%
    `[`( , -1) %>%                       ## drop the column holding full address
    as.integer() %>%                     ## convert character to integer
    as.list() %>%                        ## convert to a list
    setNames(c("min-row", "max-row", "min-col", "max-col")) ## names matter!
  
}

## functions for annoying book-keeping tasks with lists
## probably more naturally done via rlist or purrr
## see #12 for plan re: getting outside help for FP w/ lists

#' Filter a list by name
#' 
#' @param x a list
#' @param name a regular expression
#' @param ... other parameters you might want to pass to grep
lfilt <- function(x, name, ...) {
  x[grep(name, names(x), ...)]
}

#' Pluck out elements from list components by name
#' 
#' @param x a list
#' @param xpath a string giving the name of the component you want, XPath style
#' 
#' Examples: ...
llpluck <- function(x, xpath) {
  x %>% plyr::llply("[[", xpath) %>% plyr::llply(unname)
}
lapluck <- function(x, xpath) {
  x %>% plyr::laply("[[", xpath) %>% unname()
}

# OMG this is just here to use during development, i.e. after
# devtools::load_all(), when inspecting big hairy lists
str1 <- function(...) str(..., max.level = 1)

#' Extract sheet key from its browser URL
#' 
#' @param url URL seen in the browser when visiting the sheet
#' 
#' @export
extract_key_from_url <- function(url) {
  url_start_list <-
    c(ws_feed_start = "https://spreadsheets.google.com/feeds/worksheets/",
      url_start_new = "https://docs.google.com/spreadsheets/d/",
      url_start_old = "https://docs.google.com/spreadsheet/ccc\\?key=",
      url_start_old2 = "https://docs.google.com/spreadsheet/pub\\?key=")
  url_start <- url_start_list %>% stringr::str_c(collapse = "|")
  url %>% stringr::str_replace(url_start, '') %>%
    stringr::str_split_fixed('[/&#]', n = 2) %>%
    `[`(1)
}

#' Construct a worksheets feed from a key
#' 
#' @param key character, unique key for a spreadsheet
#' @param visibility character, either "private" (default) or "public",
#'   indicating whether further requests will be made with or without
#'   authentication, respectively
#'   
#' @export
construct_ws_feed_from_key <- function(key, visibility = "private") {
  tmp <-
    "https://spreadsheets.google.com/feeds/worksheets/KEY/VISIBILITY/full"
  tmp %>%
    stringr::str_replace('KEY', key) %>%
    stringr::str_replace('VISIBILITY', visibility)
}



#' Determine the cell range spanned by vector, data.frame, or matrix
#'
#' @param limits from convert_range_limit_list
#' @param input a vector, data.frame, or matrix
#'
#' @return character string for the range spanned by the input
build_range <- function(limits, input) {
  
  if(!is.data.frame(input)) {
    # input is a vector
    rows_to_add  <- 0
    cols_to_add <- length(input) - 1
  } else {
    # input is a data frame
    cols_to_add <- ncol(input) - 1
    rows_to_add <- nrow(input)
  }
  
  left_bound_row <- limits[["max-row"]]
  left_bound_col <- limits[["max-col"]] 

  right_bound_row <- sum(left_bound_row, rows_to_add) 
  right_bound_col <- sum(left_bound_col, cols_to_add) %>% num_to_letter()
  
  left_bound_col <- left_bound_col %>% num_to_letter()
  
  paste0(left_bound_col, left_bound_row, ":", right_bound_col, right_bound_row)
}
