#' paste with separator set to slash
#' 
#' paste with separator set to slash, for use in building URLs 
#' 
#' @param ... one or more R objects, to be converted to character vectors
slaste <- function(...) paste(..., sep = "/")

#' Retrieve a worksheet-describing list from a spreadsheet
#' 
#' From a registered spreadsheet, retrieve a list (actually a row of a
#' data.frame) giving everything we know about a specific worksheet.
#' 
#' @param ss a registered spreadsheet
#' @param ws a positive integer or character string specifying which worksheet
get_ws <- function(ss, ws) {
  
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
  ss$ws[ws, ]
}

#' Convert column IDs from letter representation to numeric
#'
#' @param x character vector of letter-style column IDs (case insensitive)
letter_to_num <- function(x) {
  x %>%
    stringr::str_to_upper %>%
    stringr::str_split('') %>% 
    plyr::llply(match, table = LETTERS) %>%
    plyr::laply(function(z) sum(26 ^ rev(seq_along(z) - 1) * z)) %>%
    unname
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
  paste0("R", stringr::str_extract(x, "[[:digit:]]*$") %>% as.integer,
         "C", stringr::str_extract(x, "^[[:alpha:]]*") %>% letter_to_num)
}


#' Convert coordinate (R1C1) notation to label (A1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells.
#'
#' @param x coord notation for position of cell
coord_to_label <- function(x) {
  paste0(sub("^R[0-9]+C([0-9]+)$", "\\1", x) %>% as.integer %>% num_to_letter,
         sub("^R([0-9]+)C[0-9]+$", "\\1", x))
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
  x %>% plyr::laply("[[", xpath) %>% unname
}

# OMG this is just here to use during development, i.e. after
# devtools::load_all(), when inspecting big hairy lists
str1 <- function(...) str(..., max.level = 1)
