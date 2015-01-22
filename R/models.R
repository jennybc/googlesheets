#' The spreadsheet object
#'
#' The spreadsheet object stores information about a spreadsheet. It includes the fields:
#' 
#' \itemize{
#'   \item \code{sheet_id} the key of the spreadsheet
#'   \item \code{sheet_title} the title of the spreadsheet
#'   \item \code{updated} the time of last update
#'   \item \code{nsheets} the number of worksheets contained in the spreadsheet
#'   \item \code{ws_names} the names of the worksheets contained in the 
#'   spreadsheet
#'   \item \code{visibility} visibility of spreadsheet, determines whether 
#'   authorization is required for request
#'   \item \code{worksheets} a list of worksheet objects for every worksheet 
#'   contained in the spreadsheet
#' }
#' 
#' @name spreadsheet
spreadsheet <- function() {
  structure(list(sheet_id = character(),
                 sheet_title = character(),
                 updated = character(),
                 nsheets = integer(),
                 ws_names = character(),
                 visibility = character(),
                 worksheets = list()), class = "spreadsheet")
}

#' The worksheet object
#'
#' The worksheet object stores information about a worksheet. It includes the fields:
#' 
#' \itemize{
#'   \item \code{sheet_id} the key of the spreadsheet housing the worksheet
#'   \item \code{id} the id of the worksheet
#'   \item \code{title} the title of the worksheet
#'   \item \code{ncol} the number of columns contained in the worksheet,
#'    measured by the leftmost and rightmost columns that contains values
#'   \item \code{nrow} the number of rows contained in the worksheet,
#'    measured by the top-most and bottom-most rows that contains values
#'   \item \code{col_extent} the actual number of columns contained in the 
#'    worksheet even if cells are empty
#'   \item \code{row_extent} the actual number of rows contained in the 
#'    worksheet even if cells are empty  
#'   \item \code{visibility} visibility of worksheet, determines whether 
#'   authorization is required for request
#' }
#' 
#' @name worksheet
worksheet <- function() {
  structure(list(sheet_id = character(),
                 id = character(),
                 title = character(),
                 ncol = numeric(),
                 nrow = numeric(),
                 col_extent = numeric(),
                 row_extent = numeric(),
                 visibility = character()),
            class = "worksheet")
}
