# Constructors for spreadsheet and worksheet classes ----

#' Spreadsheets 
#'
#' This function creates spreadsheet objects.
#'
#'@return Object of class spreadsheet.
#'
#' 
#'  
spreadsheet <- function() {
  structure(list(sheet_id = character(),
                 updated = character(),
                 sheet_title = character(),
                 nsheets = integer(),
                 ws_names = character(),
                 worksheets = list()), class = "spreadsheet")
}

#' Worksheets
#'
#' This function creates worksheet objects
#'
#'@return Object of class worksheet.
#'
worksheet <- function() {
  structure(list(id = character(),
                 title = character(),
                 #url = character(), 
                 listfeed = character(),
                 cellsfeed = character()), class = "worksheet")
}

