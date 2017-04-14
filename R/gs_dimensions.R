
#' Insert Rows, Columns, or Cells
#' 
#' Insert rows above or below an anchor reference. Insert columns to the right or
#' left of an anchor reference. Insert cells by shifting existing cells right or 
#' down. Each function includes an input argument to write data into the spot 
#' where the insert was made.
#'
#' @name gs_insert_range
#' @template ss
#' @template ws
#' @template anchor
#' @param dim integer vector, of length one or two, holding the number of rows
#' and/or columns of the targetted rectangle; ignored if \code{input} is provided
#' @param input a one- or two-dimensional input object, used to determine the
#' extent of the targetted rectangle
#' @param col_names logical, indicating whether a row should be reserved for
#' the column or variable names of a two-dimensional input; if omitted, will be
#' determined by checking whether \code{input} has column names
#' @param byrow logical, indicating whether a one-dimensional input should run
#' down or to the right
#' @param side character, of either "below" or "above" specifying on which side of the
#' anchor that the inserted rows should go
#' @param shift_direction character, of either "right" or "down" specifying
#' which direction to shift the existing cells when the new ones are inserted
#' @template verbose
#' @examples
#' \dontrun{
#' 
#' gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", dim = 2)
#' gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", dim = 2, side = 'above')
#' gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = head(iris))
#' gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3,4,5,6))
#' gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3,4,5,6), byrow=TRUE)
#' 
#' gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", dim = 2)
#' gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", dim = 2, side = 'left')
#' gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = head(iris))
#' gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3))
#' gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3), byrow=TRUE)
#' 
#' gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", dim = c(2,2))
#' gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", dim = c(2,2), shift_direction = 'down')
#' gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = iris[1:2,1:2])
#' gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3))
#' gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3), byrow=TRUE, shift_direction = 'down')
#' 
#' }
NULL


#' @rdname gs_insert_range
#' @inheritParams gs_insert_range
#' @export
gs_insert_rows <- function(ss,
                           ws = 1,
                           anchor = "A1",
                           dim = c(1L),
                           input = NULL,
                           col_names = NULL,
                           byrow = FALSE,
                           side = c('below', 'above'),
                           verbose = FALSE){

  googlesheets:::catch_hopeless_input(input)
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  this_ws_name <- this_ws$ws_title
  side <- match.arg(side)

  # subtract 1 since the API is indexed at zero
  anchor_row <- cellranger::as.cell_limits(anchor)$ul[1] - 1
  anchor_row <- if(side == 'below') anchor_row + 1 else anchor_row
  inherit_style <- side == 'below'

  if (is.null(dim(input))) { # input is 1-dimensional
    col_names <- FALSE
    if(!is.null(input)){ # if there is some input figure out if the data needs to go long or wide
      dim <- if(byrow) length(input) else 1
    }
  } else if (is.null(col_names)) {
    col_names <- !is.null(colnames(input))
  }

  new_rows <- if(!is.null(dim(input))) dim(input)[1] else dim[1]
  new_rows <- if(col_names) new_rows + 1 else new_rows

  ret <- gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                          input = gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                            gsv4_Request(insertDimension = gsv4_InsertDimensionRequest(
                              range = gsv4_DimensionRange(sheetId = this_ws_id,
                                                          start = anchor_row,
                                                          end = anchor_row + new_rows,
                                                          dimension = 'ROWS'),
                              inheritFromBefore = inherit_style)))))

  if(!is.null(input)){
    target_anchor <- paste0(this_ws_name, '!A', anchor_row + 1)
    if(is.null(dim(input))){
      input <- if(byrow) t(t(input)) else t(input)
    }
    ret <- gsv4_values_update(spreadsheetId = ss$sheet_key,
                              valueInputOption = 'USER_ENTERED',
                              range = target_anchor,
                              input = gsv4_ValueRange(values =
                                                        gsv4_prep_values(input, col_names = col_names),
                                                      majorDimension = 'ROWS',
                                                      range = target_anchor))
  }

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_insert_range
#' @inheritParams gs_insert_range
#' @export
gs_insert_columns <- function(ss,
                              ws = 1,
                              anchor = "A1",
                              dim = c(1L),
                              input = NULL,
                              col_names = NULL,
                              byrow = FALSE,
                              side = c('right', 'left'),
                              verbose = FALSE){

  googlesheets:::catch_hopeless_input(input)
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  this_ws_name <- this_ws$ws_title
  side <- match.arg(side)

  # subtract 1 since the API is indexed at zero
  anchor_col <- cellranger::as.cell_limits(anchor)$ul[2] - 1
  anchor_col <- if(side == 'right') anchor_col + 1 else anchor_col
  inherit_style <- side == 'right'

  if (is.null(dim(input))) { # input is 1-dimensional
    col_names <- FALSE
    if(!is.null(input)){ # if there is some input figure out if the data needs to go long or wide
      dim <- if(!byrow) length(input) else 1
    }
  } else if (is.null(col_names)) {
    col_names <- !is.null(colnames(input))
  }

  new_cols <- if(!is.null(dim(input))) dim(input)[2] else dim[1]
  
  ret <- gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                          input = gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                            gsv4_Request(insertDimension = gsv4_InsertDimensionRequest(
                              range = gsv4_DimensionRange(sheetId = this_ws_id,
                                                          start = anchor_col,
                                                          end = anchor_col + new_cols,
                                                          dimension = 'COLUMNS'),
                              inheritFromBefore = inherit_style)))))

  if(!is.null(input)){
    target_anchor <- paste0(this_ws_name, '!', cellranger::num_to_letter(anchor_col + 1), 1)
    if(is.null(dim(input))){
      input <- if(byrow) t(t(input)) else t(input)
    }
    ret <- gsv4_values_update(spreadsheetId = ss$sheet_key,
                              valueInputOption = 'USER_ENTERED',
                              range = target_anchor,
                              input = gsv4_ValueRange(values =
                                                        gsv4_prep_values(input, col_names = col_names),
                                                      majorDimension = 'ROWS',
                                                      range = target_anchor))
  }

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_insert_range
#' @inheritParams gs_insert_range
#' @export
gs_insert_cells <- function(ss,
                            ws = 1,
                            anchor = "A1",
                            dim = c(1L, 1L),
                            input = NULL,
                            col_names = NULL,
                            byrow = FALSE,
                            shift_direction = c('right', 'down'), 
                            verbose = FALSE){
  
  googlesheets:::catch_hopeless_input(input)
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  this_ws_name <- this_ws$ws_title
  shift_direction <- match.arg(shift_direction)
  shift_dim <- if(shift_direction == 'right') 'COLUMNS' else 'ROWS'

  # subtract 1 since the API is indexed at zero
  anchor_row <- cellranger::as.cell_limits(anchor)$ul[1] - 1
  anchor_col <- cellranger::as.cell_limits(anchor)$ul[2] - 1

  if (is.null(dim(input))) { # input is 1-dimensional
    col_names <- FALSE
    if(!is.null(input)){ # if there is some input figure out if the data needs to go long or wide
      dim <- if(byrow) c(length(input), 1) else c(1, length(input))
    }
  } else if (is.null(col_names)) {
    col_names <- !is.null(colnames(input))
  }

  new_rows <- if(!is.null(dim(input))) dim(input)[1] else dim[1]
  new_rows <- if(col_names) new_rows + 1 else new_rows
  
  new_cols <- if(!is.null(dim(input))) dim(input)[2] else dim[2]
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                 input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                   gsv4_Request(insertRange=gsv4_InsertRangeRequest(
                     range = gsv4_GridRange(sheetId = this_ws_id,
                                            startRowIndex = anchor_row,
                                            startColumnIndex = anchor_col,
                                            endRowIndex = anchor_row + new_rows,
                                            endColumnIndex = anchor_col + new_cols),
                     shiftDimension = shift_dim)))))
  
  if(!is.null(input)){
    target_anchor <- paste0(this_ws_name, '!', cellranger::num_to_letter(anchor_col + 1), anchor_row + 1)
    if(is.null(dim(input))){
      input <- if(byrow) t(t(input)) else t(input)
    }
    ret <- gsv4_values_update(spreadsheetId = ss$sheet_key,
                              valueInputOption = 'USER_ENTERED',
                              range = target_anchor,
                              input = gsv4_ValueRange(values =
                                                        gsv4_prep_values(input, col_names = col_names),
                                                      majorDimension = 'ROWS',
                                                      range = target_anchor))
  }

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}



#' Delete Rows, Columns, or Cells
#' 
#' Delete rows or columns occupying a range. Also, delete cells and shift 
#' the remaining cells left or up to fill in the gap.
#'
#' @name gs_delete_range
#' @template ss
#' @template ws
#' @template range
#' @param shift_direction character, of either "left" or "up" specifying
#' which direction to shift the existing cells when the range is deleted
#' @template verbose
#' @examples
#' \dontrun{
#' 
#' gs_delete_rows(gap_ss, ws = "Africa", range = "A2:F4")
#' gs_delete_rows(gap_ss, ws = "Africa", range = cell_rows(1:3))
#' 
#' gs_delete_columns(gap_ss, ws = "Africa", range = "A2:C4")
#' gs_delete_columns(gap_ss, ws = "Africa", range = cell_cols(1:2))
#' 
#' gs_delete_cells(gap_ss, ws = "Africa", range = "C3:E5")
#' gs_delete_cells(gap_ss, ws = "Africa", range = "B3:B5", shift_direction = 'up')
#' 
#' }
NULL


#' @rdname gs_delete_range
#' @inheritParams gs_delete_range
#' @export
gs_delete_rows <- function(ss,
                           ws = 1,
                           range = "A1",
                           verbose = FALSE){
  
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  
  # subtract 1 since the API is indexed at zero
  limits <- cellranger::as.cell_limits(range)
  min_row <- limits$ul[1] - 1
  max_row <- limits$lr[1]
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(deleteDimension=gsv4_DeleteDimensionRequest(
                       range=gsv4_DimensionRange(sheetId = this_ws_id,
                                                 start = min_row,
                                                 end = max_row,
                                                 dimension = 'ROWS'))))))
  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_delete_range
#' @inheritParams gs_delete_range
#' @export
gs_delete_columns <- function(ss,
                              ws = 1,
                              range = "A1",
                              verbose = FALSE){
  
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  
  # subtract 1 since the API is indexed at zero
  limits <- cellranger::as.cell_limits(range)
  min_col <- limits$ul[2] - 1
  max_col <- limits$lr[2]
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(deleteDimension=gsv4_DeleteDimensionRequest(
                       range=gsv4_DimensionRange(sheetId = this_ws_id,
                                                 start = min_col,
                                                 end = max_col,
                                                 dimension = 'COLUMNS'))))))
  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_delete_range
#' @inheritParams gs_delete_range
#' @export
gs_delete_cells <- function(ss,
                            ws = 1,
                            range = "A1",
                            shift_direction = c('left', 'up'), 
                            verbose = FALSE){
  
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  limits <- cellranger::as.cell_limits(range)
  shift_direction <- match.arg(shift_direction)
  shift_dim <- if(shift_direction == 'left') 'COLUMNS' else 'ROWS'
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                 input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                   gsv4_Request(deleteRange=gsv4_DeleteRangeRequest(
                     range = gsv4_GridRange(sheetId = this_ws_id,
                                            startRowIndex = limits$ul[1] - 1,
                                            startColumnIndex = limits$ul[2] - 1,
                                            endRowIndex = limits$lr[1],
                                            endColumnIndex = limits$lr[2]),
                     shiftDimension = shift_dim)))))
  
  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}
