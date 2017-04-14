
#' Set or Clear Basic Filters
#'
#' Set of clear basic filters. Basic filters are filters that are shared between
#' all users of the spreadsheet. Anytime a user modifies this filter, all changes
#' will be visible to all users. This behavior is different from filter views,
#' which are only visible to the user working with the filter view. There is
#' another set of functions to work with filter views.
#'
#' @name gs_basic_filter
#' @template ss
#' @template ws
#' @template verbose
#' @examples
#' \dontrun{
#'
#' gs_set_basic_filter(gap_ss, ws = 1)
#' gs_set_basic_filter(gap_ss, ws = 1, range = cell_cols(5:6), criteria=list(list(3, "NUMBER_LESS", 1970)))
#' gs_set_basic_filter(gap_ss, ws = "Americas", 
#'                     sort_spec = list(list(3, "DESCENDING")), 
#'                     criteria = list(list(4, "NUMBER_LESS", 50), 
#'                                     list(6, "NUMBER_GREATER_THAN_EQ", 1000)))
#' gs_set_basic_filter(gap_ss, ws = "Americas", range = cell_cols(3:6), sort_spec=list(list(2, "DESCENDING")))
#'
#' gs_clear_basic_filter(gap_ss, ws = 1)
#' gs_clear_basic_filter(gap_ss, ws = "Americas")
#'
#' }
NULL


#' @rdname gs_basic_filter
#' @inheritParams gs_basic_filter
#' @template range
#' @param sort_spec list-of-lists or 2 column data.frame; the list must contain
#' sublists that have 2 elements each. The first element should be an integer
#' representing the targetcolumn index in the range to sort. The second element
#' should be a string specifying either "ASCENDING" or "DESCENDING". If passing
#' a data.frame the first column should be the the target column indices and the
#' second column the sort direction.
#' @param critera list-of-lists or 3 column data.frame; the list must contain
#' sublists that have 3 elements each. The first element should be an integer
#' representing the target column index in the range to filter. The second element
#' should be a string specifying the filter condition type (e.g. "NUMBER_GREATER",
#' "NUMBER_EQ", etc.). All condition types are specified below in the details section.
#' The third element should be the condition value. The value upon which to evaluate
#' the column against using the condition type. If passing a data.frame the first
#' column should be the the target column indices, the second column the condition
#' type, and the third column the condition value.
#' @details When specifying a criteria, you must provide the condition type. The
#' condition type is the guideline for how to compare values in the column against
#' the condition value. The condition type must be one of the following values:
#' \itemize{
#'  \item{CONDITION_TYPE_UNSPECIFIED - The default value, do not use.}
#'  \item{NUMBER_GREATER - The cell's value must be greater than the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_GREATER_THAN_EQ - The cell's value must be greater than or equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_LESS - The cell's value must be less than the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_LESS_THAN_EQ - The cell's value must be less than or equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_EQ - The cell's value must be equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_NOT_EQ - The cell's value must be not equal to the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{NUMBER_BETWEEN - The cell's value must be between the two condition values.
#' Supported by data validation, conditional formatting and filters.
#' Requires exactly two ConditionValues.}
#'  \item{NUMBER_NOT_BETWEEN - The cell's value must not be between the two condition values.
#' Supported by data validation, conditional formatting and filters.
#' Requires exactly two ConditionValues.}
#'  \item{TEXT_CONTAINS - The cell's value must contain the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_NOT_CONTAINS - The cell's value must not contain the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_STARTS_WITH - The cell's value must start with the condition's value.
#' Supported by conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_ENDS_WITH - The cell's value must end with the condition's value.
#' Supported by conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_EQ - The cell's value must be exactly the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{TEXT_IS_EMAIL - The cell's value must be a valid email address.
#' Supported by data validation.
#' Requires no ConditionValues.}
#'  \item{TEXT_IS_URL - The cell's value must be a valid URL.
#' Supported by data validation.
#' Requires no ConditionValues.}
#'  \item{DATE_EQ - The cell's value must be the same date as the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#'  \item{DATE_BEFORE - The cell's value must be before the date of the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_AFTER - The cell's value must be after the date of the condition's value.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_ON_OR_BEFORE - The cell's value must be on or before the date of the condition's value.
#' Supported by data validation.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_ON_OR_AFTER - The cell's value must be on or after the date of the condition's value.
#' Supported by data validation.
#' Requires a single ConditionValue
#' that may be a relative date.}
#'  \item{DATE_BETWEEN - The cell's value must be between the dates of the two condition values.
#' Supported by data validation.
#' Requires exactly two ConditionValues.}
#'  \item{DATE_NOT_BETWEEN - The cell's value must be outside the dates of the two condition values.
#' Supported by data validation.
#' Requires exactly two ConditionValues.}
#'  \item{DATE_IS_VALID - The cell's value must be a date.
#' Supported by data validation.
#' Requires no ConditionValues.}
#'  \item{ONE_OF_RANGE - The cell's value must be listed in the grid in condition value's range.
#' Supported by data validation.
#' Requires a single ConditionValue,
#' and the value must be a valid range in A1 notation.}
#'  \item{ONE_OF_LIST - The cell's value must in the list of condition values.
#' Supported by data validation.
#' Supports any number of condition values,
#' one per item in the list.
#' Formulas are not supported in the values.}
#'  \item{BLANK - The cell's value must be empty.
#' Supported by conditional formatting and filters.
#' Requires no ConditionValues.}
#'  \item{NOT_BLANK - The cell's value must not be empty.
#' Supported by conditional formatting and filters.
#' Requires no ConditionValues.}
#'  \item{CUSTOM_FORMULA - The condition's formula must evaluate to TRUE.
#' Supported by data validation, conditional formatting and filters.
#' Requires a single ConditionValue.}
#' }
#' @export
gs_set_basic_filter <- function(ss,
                                ws = 1,
                                range = NULL,
                                sort_spec = NULL,
                                criteria = NULL,
                                verbose = FALSE){

  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  if(!is.null(range)){
    range_limits <- cellranger::as.cell_limits(range)
  } else {
    range_limits <- cellranger::cell_limits()
  }
  range_limits$sheet <- this_ws_id
  prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)

  if(!is.null(criteria)){
    prepped_criteria <- list()
    for(i in 1:length(criteria)){
      x <- criteria[[i]]
      this_key_name <- as.character(x[[1]] - 1)
      prepped_criteria[[this_key_name]] <- gsv4_FilterCriteria(condition =
                                                                 gsv4_BooleanCondition(type = x[[2]],
                                                                                       values = data.frame(userEnteredValue=as.character(x[[3]]))))
    }
  } else {
    prepped_criteria <- NULL
  }

  # do some bounds checking so we can validate the sort spec
  first_col <- range_limits$ul[2]
  last_col <- range_limits$lr[2]
  offset <- if(is.na(first_col)) 0 else first_col - 1
  if(!is.na(first_col) & !is.na(last_col)){
    range_width <- last_col - first_col + 1  
  } else if(is.na(first_col) & !is.na(last_col)){
    range_width <- last_col - 1 + 1  
  } else if(!is.na(first_col) & is.na(last_col)){
    range_width <- this_ws$col_extent - first_col + 1  
  } else {
    # assume no bounds and set to 10000 to be safe
    range_width <- 10000
  }
  
  if(!is.null(sort_spec)){
    prepped_sort_spec <- list()
    for(i in 1:length(sort_spec)){
      x <- sort_spec[[i]]
      if(x[[1]] < 1 || !all.equal(x[[1]], as.integer(x[[1]]))){
        stop('The sort index must be an integer of at least 1.')
      }
      if(x[[1]] > range_width){
        stop(sprintf('The range you provided is only %s columns wide, but you tried to sort column #%s. Sort by indices within the range argument.', range_width, x[[1]]))
      }
      prepped_sort_spec[[i]] <- gsv4_SortSpec(sortOrder = x[[2]],
                                              dimensionIndex = x[[1]] - 1 + offset)
    }
  } else {
    prepped_sort_spec <- NULL
  }

  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(setBasicFilter = gsv4_SetBasicFilterRequest(filter =
                        gsv4_BasicFilter(range = prepped_range,
                                         sortSpecs = prepped_sort_spec,
                                         criteria = prepped_criteria))))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_basic_filter
#' @inheritParams gs_basic_filter
#' @export
gs_clear_basic_filter <- function(ss,
                                  ws = 1,
                                  verbose = FALSE){

  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)

  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(clearBasicFilter =
                                    gsv4_ClearBasicFilterRequest(sheetId = this_ws_id)))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}
