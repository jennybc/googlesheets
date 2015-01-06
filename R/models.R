# Constructor functions for spreadsheet and worksheet classes

#' Spreadsheet 
#'
#' Create a spreadsheet spreadsheet object.
#'
#' @return spreadsheet object
#'
spreadsheet <- function() {
  structure(list(sheet_id = character(),
                 sheet_title = character(),
                 updated = character(),
                 nsheets = integer(),
                 ws_names = character(),
                 visibility = character(),
                 worksheets = list()), class = "spreadsheet")
}

#' Worksheet
#'
#' Create a worksheet object.
#'
#' @return worksheet object
#'
worksheet <- function() {
  structure(list(sheet_id = character(),
                 id = character(),
                 title = character(),
                 ncol = numeric(),
                 nrow = numeric(),
                 visibility = character()),
            class = "worksheet")
}
