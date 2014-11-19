# Constructor functions for spreadsheet, worksheet, classes

#' Spreadsheet 
#'
#' This function creates spreadsheet objects.
#'
#'@return Object of class spreadsheet.
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
#'@return Object of class worksheet.
#'
worksheet <- function() {
  structure(list(sheet_id = character(),
                 id = character(),
                 title = character(),
                 rows = numeric(),
                 cols = numeric()),
                 class = "worksheet")
}
