#' Retrieve a worksheet-describing list from a googlesheet
#' 
#' From a googlesheet, retrieve a list (actually a row of a data.frame) giving
#' everything we know about a specific worksheet.
#'
#' @inheritParams get_via_lf
#' @param verbose logical, indicating whether to give a message re: title of the
#'   worksheet being accessed
#'
#' @keywords internal
get_ws <- function(ss, ws, verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"),
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

#' List the worksheets in a googlesheet
#' 
#' Retrieve the titles of all the worksheets in a gpreadsheet.
#'
#' @inheritParams get_via_lf
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- register_ss(gap_key)
#' list_ws(gap_ss)
#' }
#' @export
list_ws <- function(ss) {

  stopifnot(inherits(ss, "googlesheet"))
  
  ss$ws$ws_title
}

#' Convert column IDs from letter representation to numeric
#'
#' @param x character vector of letter-style column IDs (case insensitive)
#'
#' @keywords internal
letter_to_num <- function(x) {
  x %>%
    toupper() %>%
    strsplit('') %>% 
    plyr::llply(match, table = LETTERS) %>%
    plyr::laply(function(z) sum(26 ^ rev(seq_along(z) - 1) * z)) %>%
    unname()
}

#' Convert column IDs from numeric to letter representation
#'
#' @param x vector of numeric column IDs
#'
#' @keywords internal
num_to_letter <- function(x) {
  stopifnot(x <= letter_to_num('ZZ')) # Google spreadsheets have 300 columns max
  paste0(c("", LETTERS)[((x - 1) %/% 26) + 1],
         LETTERS[((x - 1) %% 26) + 1], sep = "")
}

#' Convert A1 positioning notation to R1C1 notation
#'
#' @param x cell position in A1 notation
#'
#' @keywords internal
label_to_coord <- function(x) {
  paste0("R", stringr::str_extract(x, "[[:digit:]]*$") %>% as.integer(),
         "C", stringr::str_extract(x, "^[[:alpha:]]*") %>% letter_to_num())
}

#' Convert R1C1 positioning notation to A1 notation
#'
#' @param x cell position in R1C1 notation
#'
#' @keywords internal
coord_to_label <- function(x) {
  paste0(sub("^R[0-9]+C([0-9]+)$", "\\1", x) %>%
           as.integer() %>% num_to_letter(),
         sub("^R([0-9]+)C[0-9]+$", "\\1", x))
}

#' Convert a cell range into a limits list
#'
#' @param range character vector, length one, such as "A1:D7"
#'
#' @keywords internal
convert_range_to_limit_list <- function(range) {

  tmp <- range %>%
    ## revive next two lines when CRAN stringr > 0.6.2
    #stringr::str_split_fixed(":", 2) %>% ## A1:C5 -> "A1", "D5" as 1-row matrix
    #drop() %>%                           ## 1-row matrix --> vector
    strsplit(":") %>%               ## A1:C5 --> c("A1", "D5") as 1 element list
    unlist() %>%                        ## c("A1", "D5") as atomic vector
    `[`(seq_len(min(2, length(.)))) %>% ## first two elements only, just in case
    {                                   ## handle case of single cell input
      x <- .[. != ""]                   ## replicate the single address
      rep_len(x, 2)                     ## "C5" --> "C5", "" --> "C5", "C5"
    }

  A1_regex <- "^[A-Za-z]{1,2}[0-9]+$"
  R1C1_regex <- "^R([0-9]+)C([0-9]+$)"
  valid_regex <- stringr::str_c(c(A1_regex, R1C1_regex), collapse = "|")
  if(!all(tmp %>% stringr::str_detect(valid_regex))) {
    mess <- sprintf(paste("Trying to set cell limits, but requested range is",
                          "invalid:\n %s\n"), paste(tmp, collapse = ", "))
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

#' Convert a limits list to a cell range
#'
#' @param limits limits list
#' @param pn positioning notation
#'
#' @keywords internal
convert_limit_list_to_range <- function(limits, pn = c('R1C1', 'A1')) {

  pn <- match.arg(pn)

  range <- c(paste0("R", limits$`min-row`, "C", limits$`min-col`),
             paste0("R", limits$`max-row`, "C", limits$`max-col`))

  if(pn == 'A1') {
    range <- range %>% coord_to_label()
  }

  paste(range, collapse = ":")
}


## functions for annoying book-keeping tasks with lists
## probably more naturally done via rlist or purrr
## see #12 for plan re: getting outside help for FP w/ lists

#' Filter a list by name
#'
#' @param x a list
#' @param name a regular expression
#' @param ... other parameters you might want to pass to grep
#'
#' @keywords internal
lfilt <- function(x, name, ...) {
  x[grep(name, names(x), ...)]
}

#' Pluck out elements from list components by name
#'
#' @param x a list
#' @param xpath a string giving the name of the component you want, XPath style
#'
#' @keywords internal
llpluck <- function(x, xpath) {
  x %>% plyr::llply("[[", xpath) %>% plyr::llply(unname)
}
lapluck <- function(x, xpath, .drop = TRUE) {
  x %>% plyr::laply("[[", xpath, .drop = .drop) %>% unname()
}

# OMG this is just here to use during development, i.e. after
# devtools::load_all(), when inspecting big hairy lists
#' @keywords internal
str1 <- function(...) str(..., max.level = 1)

#' Extract sheet key from its browser URL
#'
#' @param url URL seen in the browser when visiting the sheet
#'
#' @examples
#' \dontrun{
#' gap_url <- "https://docs.google.com/spreadsheets/d/1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA/"
#' gap_key <- extract_key_from_url(gap_url)
#' gap_ss <- register_ss(gap_key)
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
    "https://spreadsheets.google.com/feeds/worksheets/KEY/VISIBILITY/full"
  tmp %>%
    stringr::str_replace('KEY', key) %>%
    stringr::str_replace('VISIBILITY', visibility)
}
