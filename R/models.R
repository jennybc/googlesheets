# Constructor functions for spreadsheet and worksheet classes

#' Spreadsheet 
#'
#' This function creates spreadsheet objects.
#'
#'@return spreadsheet object
#'
spreadsheet <- function() {
  structure(list(sheet_id = character(),
                 sheet_title = character(),
                 updated = character(),
                 nsheets = integer(),
                 ws_names = character(),
                 worksheets = list()), class = "spreadsheet")
}

#' Worksheet
#'
#' This function creates worksheet objects
#'
#'@return worksheet object
#'
worksheet <- function() {
  structure(list(sheet_id = character(),
                 id = character(),
                 title = character(),
                 ncol = numeric(),
                 nrow = numeric()),
            class = "worksheet")
}
