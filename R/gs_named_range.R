
#' Get, Add, Update, or Delete Named Ranges
#' 
#' These functions provide basic CRUD (Create-Read-Update-Delete) functionality 
#' with respect to named ranges in Google Sheets. 
#'
#' @name gs_named_range
#' @template ss
#' @template verbose
#' @examples
#' \dontrun{
#' 
#' gs_add_named_range(gap_ss, name = "RangeAtAfricaA2", range = "Africa!A2")
#' gs_get_named_range(gap_ss)
#' 
#' gs_update_named_range(gap_ss, named_range = "RangeAtAfricaA2", name = "RangeAtAfricaA3", range = "Africa!A3")
#' gs_update_named_range(gap_ss, named_range = "RangeAtAfricaA3", name = "Range1")
#' gs_update_named_range(gap_ss, named_range = "Range1", range = "Africa!A4")
#' gs_get_named_range(gap_ss)
#' 
#' gs_delete_named_range(gap_ss, named_range = "Range1")
#' gs_get_named_range(gap_ss)
#' }
NULL


#' @rdname gs_named_range
#' @inheritParams gs_named_range
#' @param name character; a string to name this range when created
#' @template range
#' @export
gs_add_named_range <- function(ss,
                               name,
                               range = "A1",
                               verbose = FALSE){
  
  range_limits <- cellranger::as.cell_limits(range)
  prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(addNamedRange=gsv4_AddNamedRangeRequest(
                       namedRange = gsv4_NamedRange(name = name, 
                                                    range = prepped_range))))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_named_range
#' @inheritParams gs_named_range
#' @param named_range string; id or name of a named range in the sheet. Use 
#' \code{\link{gs_get_named_range}} to get details on all named ranges in a sheet.
#' @param name character; a string to name this range when created
#' @template range
#' @export
gs_update_named_range <- function(ss,
                                  named_range,
                                  name = NULL,
                                  range = NULL,
                                  verbose = FALSE){
  
  fields <- character(0)
  
  if(!is.null(range)){
    fields <- c(fields, 'range')
  } else {
    range <- "A1" # just a dummy value to pass typecheck
  }
  range_limits <- cellranger::as.cell_limits(range)
  prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
  
  if(!is.null(name)){
    fields <- 'name' 
  } else {
    name <- ''
  }

  if(length(fields) == 0){
    stop('In order to update the range you must specify a new name and/or range.')
  }
  field_mask_list <- paste0(fields, collapse=',')
  
  all_named_ranges <- gs_get_named_range(ss)
  target_named_range <- all_named_ranges[all_named_ranges$name == named_range, 'namedRangeId']
  
  if(length(target_named_range) == 0){
   # attempt to verify that the supplied named_range argument is the actual id of a named range 
   if(named_range %in% all_named_ranges$namedRangeId){
     target_named_range <- named_range
   } else {
      stop(sprintf('A named range could not be found in the spreadsheet by id or name: %s', named_range))
   }
  }
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(updateNamedRange=gsv4_UpdateNamedRangeRequest(
                       namedRange = gsv4_NamedRange(namedRangeId = target_named_range, 
                                                    name = name, 
                                                    range = prepped_range), 
                       fields = field_mask_list)))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_named_range
#' @inheritParams gs_named_range
#' @param named_range string; id or name of a named range in the sheet. Use 
#' \code{\link{gs_get_named_range}} to get details on all named ranges in a sheet.
#' @export
gs_delete_named_range <- function(ss,
                                  named_range,
                                  verbose = FALSE){
  
  all_named_ranges <- gs_get_named_range(ss)
  target_named_range <- all_named_ranges[all_named_ranges$name == named_range, 'namedRangeId']
  
  if(length(target_named_range) == 0){
   # attempt to verify that the supplied named_range argument is the actual id of a named range 
   if(named_range %in% all_named_ranges$namedRangeId){
     target_named_range <- named_range
   } else {
      stop(sprintf('A named range could not be found in the spreadsheet by id or name: %s', named_range_id))
   }
  }
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(deleteNamedRange=
                                    gsv4_DeleteNamedRangeRequest(
                                      namedRangeId = target_named_range)))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_named_range
#' @inheritParams gs_named_range
#' @importFrom purrr map_df
#' @export
gs_get_named_range <- function(ss, 
                               verbose = FALSE){
  
  res <- gsv4_get(spreadsheetId = ss$sheet_key, 
                  fields = 'namedRanges')
  
  if(length(res) > 0){
    res$namedRanges %>% map_df(as.data.frame, stringsAsFactors=FALSE)  
  } else {
    data.frame()
  }
}
