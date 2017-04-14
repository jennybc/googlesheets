
#' Clear Cells
#' 
#' A function to clear the values of all cells in a range. The function allows 
#' for clearing worksheets or everything in the entire spreedsheet. Use with caution!
#' There is an option to clear formatting as well, but the default is to only 
#' clear the values of the cells.
#'
#' @name gs_clear_cells
#' @template ss
#' @template ws
#' @template range
#' @param clear_type a character string that indicates what type of data to clear:  
#' "values", "formats", or "all" data associated with the cell.
#' @template verbose
#' @examples
#' \dontrun{
#' 
#' gs_clear_cells(gap_ss, ws = 1, range = "A1:B2")
#' 
#' # clear cell values in A1 on every worksheet
#' gs_clear_cells(gap_ss, range = "A1")
#' 
#' # clear cell formatting in the first 2 rows
#' gs_clear_cells(gap_ss, ws = 1, range = cell_rows(1:2), clear_type = 'formats')
#' 
#' # you can clear all cells on a worksheet
#' gs_clear_cells(gap_ss, ws = 1)
#' 
#' # or even clear all cell values in the entire spreadsheet
#' gs_clear_cells(gap_ss, clear_type = 'values')
#' 
#' # or the nuclear option to clear values, formats, all cell data across all worksheets
#' gs_clear_cells(gap_ss, clear_type = 'all')
#' 
#' }
#' @export
gs_clear_cells <- function(ss,
                           ws = NULL,
                           range = NULL,
                           clear_type = c('values', 'formats', 'all'),
                           verbose = FALSE){
  
  clear_type <- match.arg(clear_type)
  if(clear_type == 'values'){
    field_name <- 'userEnteredValue'
  } else if(clear_type == 'formats'){
    field_name <- 'userEnteredFormat'
  } else {
    field_name <- '*'
  }

  if(is.null(ws)){
    this_ws_id <- as.integer(ss$ws$gid)
  } else {
    this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
    this_ws_id <- as.integer(this_ws$gid)    
  }

  if(is.null(range)){
    range_limits <- cellranger::cell_limits()
  } else {
    range_limits <- cellranger::as.cell_limits(range)
  }
  
  prepped_requests <- list()
  for(i in 1:length(this_ws_id)){
    range_limits$sheet <- this_ws_id[i]
    prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
    prepped_requests[[i]] <- gsv4_Request(updateCells = 
                                            gsv4_UpdateCellsRequest(range = prepped_range, 
                                                                    fields = field_name))
  }
  names(prepped_requests) <- NULL
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=prepped_requests))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}
