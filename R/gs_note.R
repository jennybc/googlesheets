
#' Insert or Clear Notes
#' 
#' Insert or clear cell notes on a particular cell or range of cells. These 
#' functions allow you to manipulate notes, which are strings as part of the 
#' cell's metadata. Notes are different than comments, which do not appear to be 
#' supported by the Sheets V4 API at this time.
#'
#' @template ss
#' @template ws
#' @template range
#' @template verbose
#' @name gs_note
#' @examples
#' \dontrun{
#' 
#' gs_insert_note(gap_ss, ws = 1, range = "A1", note = "Test Note")
#' gs_insert_note(gap_ss, ws = 1, range = "E1:E2", note = c("Note- E1", "Note - E2"))
#' gs_insert_note(gap_ss, ws = 1, range = "B1:D4", note = "Hello, This is a Note Test!")
#' 
#' gs_clear_note(gap_ss, ws = 1, range = "A1:B2")
#' gs_clear_note(gap_ss, ws = 1, range = cell_rows(3))
#' gs_clear_note(gap_ss, ws = 1)
#' 
#' }
NULL


#' @rdname gs_note
#' @inheritParams gs_note
#' @param note character; a single string or vector of strings to populate the note 
#' of cells in the range. If the range contains more cells than the note vector is 
#' long, then the elements are recycled.
#' @param byrow logical; should we take the note vector and apply to the range
#' going across a row (byrow = TRUE) or down a column (byrow = FALSE, default)
#' @export
gs_insert_note <- function(ss,
                           ws = 1,
                           range = "A1",
                           note = '',
                           byrow = FALSE,
                           verbose = FALSE){
  
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  
  range_limits <- cellranger::as.cell_limits(range)
  range_limits$sheet <- this_ws_id
  prepped_range <- gsv4_limits_to_grid_range(range_limits)
  
  range_rows <- dim(range_limits)[1]
  range_cols <- dim(range_limits)[2]
  total_cell_cnt <- range_rows * range_cols
  note <- rep(note, length.out = total_cell_cnt)
  note <- matrix(note, nrow = range_rows, ncol = range_cols, byrow = byrow)
  prepped_rows <- apply(note, 1, FUN=function(x){gsv4_RowData(data.frame(note=x))})
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(updateCells=gsv4_UpdateCellsRequest(
                       range = prepped_range,
                       rows = prepped_rows,
                       fields = "note")))))
                       
  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_note
#' @inheritParams gs_note
#' @details The default value for the range argument is NULL, which implies that 
#' notes should be cleared from the entire sheet. Make sure to specify a range
#' if you do not want this behavior.
#' @export
gs_clear_note <- function(ss,
                          ws = 1,
                          range = NULL,
                          verbose = FALSE){
  
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  
  if(is.null(range)){
    range_limits <- cellranger::as.cell_limits()
  } else {
    range_limits <- cellranger::as.cell_limits(range)  
  }
  
  range_limits$sheet <- this_ws_id
  prepped_range <- gsv4_limits_to_grid_range(range_limits)
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(repeatCell=gsv4_RepeatCellRequest(
                       range = prepped_range,
                       cell = gsv4_CellData(note = ''),
                       fields = "note")))))
                       
  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}
