
#' Merge/Unmerge Cells or Get Identify Ranges of Merged Cells
#' 
#' These functions will accept a range to merge. The unmerge function will accept 
#' a range, but the range and ws arguments can be left NULL to unmerge all cells 
#' in a worksheet or the entire spreadsheet. There is a function to determine the 
#' ranges where merges occur which helps to formulate the unmerge request which 
#' must exactly match the range of cells that have been merged.
#'
#' @name gs_merge
#' @template ss
#' @template ws
#' @template range
#' @template verbose
#' @examples
#' \dontrun{
#' 
#' gs_merge_cells(gap_ss, ws = 1, range = "A1:B2")
#' gs_merge_cells(gap_ss, ws = "Africa", range = "A5:E10", merge_type="MERGE_ROWS")
#' gs_merge_cells(gap_ss, ws = "Africa", range = "A11:C15", merge_type="MERGE_COLUMNS")
#' 
#' gs_unmerge_cells(gap_ss, ws = "Africa", range = "A11:C15")
#' gs_unmerge_cells(gap_ss, ws = "Africa", range = "A5:E10")
#' gs_unmerge_cells(gap_ss, ws = 1, range = "A1:B2")
#' 
#' # you can unmerge all cells on a worksheet
#' gs_unmerge_cells(gap_ss, ws = 1)
#' 
#' # or even unmerge all cells in the entire spreadsheet
#' gs_unmerge_cells(gap_ss)
#' 
#' }
NULL

#' @rdname gs_merge
#' @inheritParams gs_merge
#' @param merge_type  string. How the cells should be merged. merge_type must 
#' take one of the following values: MERGE_ALL, MERGE_COLUMNS, MERGE_ROWS
#' See the details section for the definition of each of these values.
#' @details merge_type takes one of the following values:
#' \itemize{
#'  \item{MERGE_ALL - Create a single merge from the range}
#'  \item{MERGE_COLUMNS - Create a merge for each column in the range}
#'  \item{MERGE_ROWS - Create a merge for each row in the range}
#' }
#' @export
gs_merge_cells <- function(ss,
                           ws = 1,
                           range = "A1",
                           merge_type = c('MERGE_ALL', 'MERGE_COLUMNS', 'MERGE_ROWS'),
                           verbose = FALSE){

  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  range_limits <- cellranger::as.cell_limits(range)
  range_limits$sheet <- this_ws_id
  prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
  
  merge_type <- match.arg(merge_type)
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(mergeCells = gsv4_MergeCellsRequest(range = prepped_range, 
                                                                      mergeType = merge_type)))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}

#' @rdname gs_merge
#' @inheritParams gs_merge
#' @export
gs_unmerge_cells <- function(ss,
                             ws = NULL,
                             range = NULL,
                             verbose = FALSE){
  
  if(is.null(ws)){
    this_ws_id <- as.integer(ss$ws$gid)
  } else {
    this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
    this_ws_id <- as.integer(this_ws$gid)    
  }

  if(is.null(range)){
    merged_ranges <- gs_get_merged_cells(ss)
    merged_ranges <- merged_ranges[merged_ranges$sheetId %in% this_ws_id,]
    if(nrow(merged_ranges) < 1){
      message('No merged ranges were found in this spreadsheet.')
      return()
    }
    prepped_requests <- apply(merged_ranges, 1, FUN=function(x){
      gsv4_Request(unmergeCells = gsv4_UnmergeCellsRequest(range = 
                                                             gsv4_GridRange(sheetId = as.integer(x['sheetId']),
                                                                            startRowIndex = as.integer(x['startRowIndex']),
                                                                            endRowIndex = as.integer(x['endRowIndex']),
                                                                            startColumnIndex = as.integer(x['startColumnIndex']),
                                                                            endColumnIndex = as.integer(x['endColumnIndex']))))
    })
    names(prepped_requests) <- NULL
  } else {
    range_limits <- cellranger::as.cell_limits(range)
    range_limits$sheet <- this_ws_id
    prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
    prepped_requests <- list(gsv4_Request(unmergeCells = gsv4_UnmergeCellsRequest(range = prepped_range)))
  }
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=prepped_requests))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}

#' @rdname gs_merge
#' @template ss
#' @template verbose
#' @importFrom purrr map_df
#' @export
gs_get_merged_cells <- function(ss,
                                verbose = FALSE){
  
  res <- gsv4_get(spreadsheetId = ss$sheet_key, 
                  fields = 'sheets.merges')
  all_ranges_list <- unlist(unlist(res$sheets, recursive = FALSE), recursive = FALSE)
  
  if(!is.null(all_ranges_list)){
    all_ranges <- all_ranges_list %>% 
      map_df(as.data.frame, stringsAsFactors=FALSE) 
  } else {
    all_ranges <- data.frame()
  }
  return(all_ranges)
}
