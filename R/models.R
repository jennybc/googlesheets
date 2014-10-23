# Constructors for spreadsheet and worksheet classes ----

#' Spreadsheets 
#'
#' The function creates spreadsheet objects.
#'
#'@return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets (visibility = TRUE and projection = FULL).
#'  
spreadsheet <- function() {
  structure(list(sheet_id = character(),
                 updated = character(),
                 sheet_title = character(),
                 nsheets = integer(),
                 sheet_names = character(),
                 worksheets = list()), class = "spreadsheet")
}

#' Worksheets
#'
#' This function creates worksheet objects
#'
#'@return Object of class worksheet.
#'
#' This function currently only works for public spreadsheets (visibility = TRUE and projection = FULL).
#'  
worksheet <- function() {
  structure(list(id = character(),
                 title = character(),
                 url = character(), 
                 listfeed = character(),
                 cellsfeed = character()), class = "worksheet")
}

# Functions ----

#' Get dimensions of worksheet
#'
#' This function retrives the dimension of a worksheet object
#'
#'@return Vector of length 2 
#'
#' 
get_dim <- function(worksheet) {
  
    xx<- GET(worksheet$listfeed)
    
    xxx <- xmlInternalTreeParse(xx)
    
    nodes_for_rows <- getNodeSet(xxx, "//x:content", "x")
    
    col_counts <- lapply((strsplit(xmlSApply(nodes_for_rows, xmlValue), ",")), length)
    
    col_count <- max(unlist(col_counts)) + 1 # to add back first col
    
    row_count <- length(col_counts) + 1 # to add back header row
    
    dims <- c(row_count, col_count)
    
    names(dims) <- c("row", "col")
    
    dims
   
}

row_count <- function(worksheet) {
  get_dim(worksheet)[1]
}

col_count <- function(worksheet) {
  get_dim(worksheet)[2]
}  
