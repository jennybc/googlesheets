#' The spreadsheet object
#' 
#' The spreadsheet object stores information about a spreadsheet. It includes
#' the fields:
#' 
#' \itemize{
#' \item \code{sheet_key} the key of the spreadsheet
#' \item \code{sheet_id} the id of the spreadsheet
#' \item \code{sheet_title} the title of the spreadsheet
#' \item \code{updated} the time of last update
#' \item \code{n_ws} the number of worksheets contained in the spreadsheet
#' \item \code{visibility} visibility of spreadsheet, determines whether
#' authorization is required for request
#' \item \code{ws} a data.frame about the worksheets contained in the
#' spreadsheet
#' }
#' 
#' TO DO: this documentation is neither here nor there. Either the object is
#' self-explanatory and this isn't really needed. Or this needs to get beefed
#' up.
#' 
#' @name spreadsheet
spreadsheet <- function() {
  structure(list(sheet_key = character(),
                 sheet_title = character(),
                 n_ws = integer(),
                 ws_feed = character(),
                 sheet_id = character(),
                 updated = character(),
                 get_date = character(), # initialize as posix whatever?
                 visibility = character(),
                 author_name = character(),
                 author_email = character(),
                 links = character(), # initialize as data.frame?
                 ws = list()),
            class = c("spreadsheet", "list"))
  
}
