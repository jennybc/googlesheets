
#' Get, Add, Update, or Delete Protected Ranges
#' 
#' These functions provide basic CRUD (Create-Read-Update-Delete) functionality 
#' with respect to protected ranges in Google Sheets. 
#'
#' @name gs_protected_range
#' @template ss
#' @param protected_range string; id or name of a Protected Range in the sheet. Use 
#' \code{\link{gs_get_protected_range}} to get details on all Protected Ranges in a sheet.
#' @param description character; The description of this protected range.
#' @template range
#' @param named_range string; id or name of a named range in the sheet. Use 
#' \code{\link{gs_get_named_range}} to get details on all named ranges in a sheet.
#' @param editors vector, list, or 1 column data.frame with the email addresses 
#' of people to have edit access to the protected range. If this argument is left 
#' NULL then only the creating user will have edit access to the protected range.
#' @param domain_users_can_edit logical; True if anyone in the document's domain 
#' has edit access to the protected range. Domain protection is only supported 
#' on documents within a domain.
#' @param warning_only logical; True if this protected range will show a warning 
#' when editing. Warning-based protection means that every user can edit data 
#' in the protected range, except editing will prompt a warning asking the user 
#' to confirm the edit. When writing: if this field is true, then editors is ignored. 
#' Additionally, if this field is changed from true to false and the editors field is 
#' not set (nor included in the field mask), then the editors will be set to all 
#' the editors in the document.
#' @template verbose
#' @examples
#' \dontrun{
#' 
#' gs_add_protected_range(gap_ss, range = "Africa!A1", description = "PR - Test")
#' gs_add_protected_range(gap_ss, range = cell_limits(sheet="Africa")) # protect whole sheet!
#' gs_get_protected_range(gap_ss)
#' 
#' gs_update_protected_range(gap_ss, protected_range = "PR - Test", range = "Africa!A2")
#' gs_update_protected_range(gap_ss, protected_range = "PR - Test", description = "PR - Test2")
#' gs_update_protected_range(gap_ss, protected_range = "PR - Test2", named_range = 'Range1')
#' 
#' gs_delete_protected_range(gap_ss, protected_range = "PR - Test2")
#' pr <- gs_get_protected_range(gap_ss)
#' gs_delete_protected_range(gap_ss, protected_range = pr$protectedRangeId[1])
#' gs_get_protected_range(gap_ss)
#' }
NULL


#' @rdname gs_protected_range
#' @inheritParams gs_protected_range
#' @export
gs_add_protected_range <- function(ss,
                                   description,
                                   range = "A1",
                                   named_range = NULL,
                                   editors = NULL,
                                   domain_users_can_edit = FALSE,
                                   warning_only = FALSE,
                                   verbose = FALSE){
  
  if(!is.null(named_range)){
    # set prepped_range to null so it can be passed to the function
    # but ignored because "When writing, only one of range or namedRangeId may be set."
    prepped_range <- NA
    class(prepped_range) <- 'GridRange'
    
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
    
  } else {
    # set target_named_range to null named_range so it can be passed to the function
    # but ignored because "When writing, only one of range or namedRangeId may be set."
    target_named_range <- ''
    range_limits <- cellranger::as.cell_limits(range)
    prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
  }
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(addProtectedRange=gsv4_AddProtectedRangeRequest(
                       protectedRange = gsv4_ProtectedRange(description = description, 
                                                            range = prepped_range,
                                                            namedRangeId = target_named_range,
                                                            editors = gsv4_Editors(users=unname(as.list(editors)), 
                                                                                   domainUsersCanEdit = domain_users_can_edit),
                                                            warningOnly = warning_only))))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_protected_range
#' @inheritParams gs_protected_range
#' @export
gs_update_protected_range <- function(ss,
                                      protected_range,
                                      description = NULL,
                                      range = NULL,
                                      named_range = NULL,
                                      editors = NULL,
                                      domain_users_can_edit = NULL,
                                      warning_only = NULL,
                                      verbose = FALSE){
  
  fields <- character(0)
  
  # not a vectorized operation
  stopifnot(length(protected_range) == 1)
  
  all_protected_ranges <- gs_get_protected_range(ss)
  target_protected_range <- all_protected_ranges[all_protected_ranges$description == protected_range, 'protectedRangeId']
  target_protected_range <- target_protected_range[!is.na(target_protected_range)]
  
  if(length(target_protected_range) == 0){
   # attempt to verify that the supplied protected_range argument is the actual id of a Protected Range 
   if(protected_range %in% all_protected_ranges$protectedRangeId){
     target_protected_range <- protected_range
   } else {
      stop(sprintf('A Protected Range could not be found in the spreadsheet by id or name: %s', protected_range))
   }
  }
  
  if(length(target_protected_range) > 1){
    warning(sprintf('More than 1 protected range matches the supplied protected_range argument: "%s". Only deleting the first match.', protected_range))
    target_protected_range <- target_protected_range[1]
  }
  
  if(!is.null(named_range)){
    
    fields <- c(fields, 'namedRangeId')
    # set range to dummy value so it can be passed to the function
    # but ignored because "When writing, only one of range or namedRangeId may be set."
    range <- "A1"
    
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
  } else {
    # set target_named_range to null named_range so it can be passed to the function
    # but ignored because "When writing, only one of range or namedRangeId may be set."
    target_named_range <- ''
    if(is.null(range)){
      range <- "A1" # just a dummy value to pass typecheck
    } else {
      fields <- c(fields, 'range')
    }
  }
  range_limits <- cellranger::as.cell_limits(range)
  prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
  
  if(!is.null(description)){
    fields <- c(fields, 'description')
  } else {
    description <- ''
  }
  if(!is.null(editors)){
    fields <- c(fields, 'editors.users')
  }
  if(!is.null(domain_users_can_edit)){
    fields <- c(fields, 'editors.domainUsersCanEdit')
  } else {
    domain_users_can_edit <- FALSE # just a dummy value to pass typecheck
  }
  if(!is.null(warning_only)){
    fields <- c(fields, 'warningOnly')
  } else {
    warning_only <- FALSE # just a dummy value to pass typecheck
  }
  field_mask_list <- paste0(fields, collapse=',')
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(updateProtectedRange=gsv4_UpdateProtectedRangeRequest(
                       protectedRange = gsv4_ProtectedRange(protectedRangeId = as.integer(target_protected_range),
                                                            description = description, 
                                                            range = prepped_range,
                                                            namedRangeId = target_named_range,
                                                            editors = gsv4_Editors(users=unname(as.list(editors)), 
                                                                                   domainUsersCanEdit = domain_users_can_edit),
                                                            warningOnly = warning_only), 
                       fields = field_mask_list)))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_protected_range
#' @inheritParams gs_protected_range
#' @export
gs_delete_protected_range <- function(ss,
                                      protected_range,
                                      verbose = FALSE){
  
  # not a vectorized operation
  stopifnot(length(protected_range) == 1)
  
  all_protected_ranges <- gs_get_protected_range(ss)
  target_protected_range <- all_protected_ranges[all_protected_ranges$description == protected_range, 'protectedRangeId']
  target_protected_range <- target_protected_range[!is.na(target_protected_range)]
  
  if(length(target_protected_range) == 0){
   # attempt to verify that the supplied protected_range argument is the actual id of a Protected Range 
   if(protected_range %in% all_protected_ranges$protectedRangeId){
     target_protected_range <- protected_range
   } else {
      stop(sprintf('A Protected Range could not be found in the spreadsheet by id or name: %s', protected_range))
   }
  }
  
  if(length(target_protected_range) > 1){
    warning(sprintf('More than 1 protected range matches the supplied protected_range argument: "%s". Only deleting the first match.', protected_range))
    target_protected_range <- target_protected_range[1]
  }
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(deleteProtectedRange=
                                    gsv4_DeleteProtectedRangeRequest(
                                      protectedRangeId = as.integer(target_protected_range))))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_protected_range
#' @inheritParams gs_protected_range
#' @importFrom purrr map_df
#' @importFrom dplyr %>%
#' @export
gs_get_protected_range <- function(ss, 
                                   verbose = FALSE){
  
  res <- gsv4_get(spreadsheetId = ss$sheet_key, 
                  fields = 'sheets.protectedRanges')
  all_ranges_list <- unlist(unlist(res$sheets, recursive = FALSE), recursive = FALSE)
  
  if(!is.null(all_ranges_list)){
    all_ranges <- all_ranges_list %>% 
      map_df(.f=function(x){y <- as.data.frame(t(unlist(x, recursive = TRUE)), stringsAsFactors=FALSE); y$editors <- list(x$editors$users); return(y)})
    all_ranges <- all_ranges[,!grepl('editors\\.users', names(all_ranges))]
  } else {
    all_ranges <- data.frame()
  }
  return(all_ranges)
}
