#' Overview of a Google spreadsheet registered with gspreadr
#' 
#' Display the structure of a spreadsheet that has been registered with 
#' \code{gspreadr}: the title of the spreadsheet, the number of worksheets 
#' contained and the corresponding worksheet dimensions.
#' 
#' @param object spreadsheet object returned by \code{register}
#' @param ... potential further arguments (required for Method/Generic reasons)
#'   
#' @export
str.spreadsheet <- function(object, ...) {  
  
  sprintf("              Spreadsheet title: %s\n", object$sheet_title) %>% cat
  sprintf("     Date of gspreadr::register: %s\n",
          object$get_date %>% format.POSIXct(usetz = TRUE)) %>% cat
  sprintf("Date of last spreadsheet update: %s\n",
          object$updated %>% format.POSIXct(usetz = TRUE)) %>% cat
  cat("\n")
  
  ws_string <- "%s: %d x %d"
  ws_output <- plyr::daply(object$ws, ~ ws_title, function(x) {
    sprintf(ws_string, x$ws_title, x$row_extent, x$col_extent)})
  sprintf("Contains %d worksheets:\n", object$n_ws) %>% cat
  cat("(Title): (Nominal worksheet extent as rows x columns)\n")
  cat(ws_output, sep = "\n")
  
  cat("\n")
  sprintf("Key: %s\n", object$sheet_key) %>% cat
  sprintf("Worksheets feed: %s\n", object$ws_feed) %>% cat
  
}
