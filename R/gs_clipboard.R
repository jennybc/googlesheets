
#' Cut or Copy and Paste
#' 
#' Designate a source to cut or copy a sources and paste to an anchor or range 
#' with options to paste metadata such as underlying formulas, borders, etc.
#'
#' @name gs_clipboard
#' @template ss
#' @param source a cell range, as described in \code{\link{cell-specification}}, 
#' but should specify the sheet name as well, otherwise it is assumed that the 
#' operation applies to a range on the first sheet.
#' @param paste_type character, indicating what kind of data will be pasted such 
#' as values, formulas, formats, merges, etc.
#' @template verbose
#' @details The source and its corresponding anchor or destination should include 
#' the sheet name. This is different from other operations in this package which 
#' typically specify the worksheet in a separate argument. The reason for including 
#' in the range specification is to allow for copying from one sheet and pasting 
#' into a different one. Unspecified sheet names results in these functions 
#' assuming that the operation applies to the range on the first sheet (e.g. 
#' "A1" referencing "Sheet1!A1").
#' 
#' The paste_type argument can take the following values:
#' \itemize{
#'  \item{PASTE_NORMAL - Paste values, formulas, formats, and merges.}
#'  \item{PASTE_VALUES - Paste the values ONLY without formats, formulas, or merges.}
#'  \item{PASTE_FORMAT - Paste the format and data validation only.}
#'  \item{PASTE_NO_BORDERS - Like PASTE_NORMAL but without borders.}
#'  \item{PASTE_FORMULA - Paste the formulas only.}
#'  \item{PASTE_DATA_VALIDATION - Paste the data validation only.}
#'  \item{PASTE_CONDITIONAL_FORMATTING - Paste the conditional formatting rules only.}
#' }
#' 
#' The paste_orientation argument can take the following values:
#' \itemize{
#'  \item{NORMAL - Paste normally.}
#'  \item{TRANSPOSE - Paste transposed, where all rows become columns and vice versa.}
#' }
#' @examples
#' \dontrun{
#' 
#' gs_cut_paste(gap_ss, source = "A1", anchor = "A2") # assumes sheet 0
#' gs_cut_paste(gap_ss, source = "Africa!A1", anchor = "Americas!A2")
#' 
#' gs_copy_paste(gap_ss, source = "A1", destination = "A4") # assumes sheet 0
#' gs_copy_paste(gap_ss, source = "Africa!A1", destination = "Americas!A1")
#' gs_copy_paste(gap_ss, source = "Africa!A1:C2", destination = "Americas!A1")
#' gs_copy_paste(gap_ss, 
#'               source = "Africa!A1:C2", destination = "Americas!A3", 
#'               paste_orientation='TRANSPOSE')
#' 
#' }
NULL


#' @rdname gs_clipboard
#' @inheritParams gs_clipboard
#' @template anchor
#' @export
gs_cut_paste <- function(ss,
                         source = "A1",
                         anchor = "A1",
                         paste_type = c('PASTE_NORMAL', 'PASTE_VALUES', 'PASTE_FORMAT', 
                                        'PASTE_NO_BORDERS', 'PASTE_FORMULA', 
                                        'PASTE_DATA_VALIDATION', 'PASTE_CONDITIONAL_FORMATTING'),
                         verbose = FALSE){
  
  paste_type <- match.arg(paste_type)
  
  src_limits <- cellranger::as.cell_limits(source)
  prepped_src <- gsv4_limits_to_grid_range(src_limits, ss)
  prepped_dest <- gsv4_anchor_to_grid_coordinate(anchor, ss)
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(cutPaste=gsv4_CutPasteRequest(
                       source = prepped_src, 
                       destination = prepped_dest, 
                       pasteType = paste_type)))))
                       
  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}


#' @rdname gs_clipboard
#' @inheritParams gs_clipboard
#' @param destination a cell range, as described in \code{\link{cell-specification}}. 
#' If the range covers a span that's a multiple of the source's height or width, 
#' then the data will be repeated to fill in the destination range. If the range 
#' is smaller than the source range, the entire source data will still be copied 
#' (beyond the end of the destination range).
#' @param paste_orientation character, string indicating whether the data should be 
#' pasted normally or transposed before pasting
#' @details The limits of the destination range will influence whether or not 
#' the source data is repeated to fill or not. See note above about destination 
#' ranges being smaller than source. You can specify a single cell as the destination, 
#' similar to an anchor, and have the entire source copied over starting in that 
#' cell as the upper left.
#' @export
gs_copy_paste <- function(ss,
                          source = "A1",
                          destination = "A1",
                          paste_type = c('PASTE_NORMAL', 'PASTE_VALUES', 'PASTE_FORMAT', 
                                         'PASTE_NO_BORDERS', 'PASTE_FORMULA', 
                                         'PASTE_DATA_VALIDATION', 'PASTE_CONDITIONAL_FORMATTING'),
                          paste_orientation = c('NORMAL', 'TRANSPOSE'),
                          verbose = FALSE){
  
  # if destination is a single cell, then assume they want to copy/paste
  # with exactly the same dimensions as the source
  
  paste_type <- match.arg(paste_type)
  paste_orientation <- match.arg(paste_orientation)
  
  src_limits <- cellranger::as.cell_limits(source)
  prepped_src <- gsv4_limits_to_grid_range(src_limits, ss)
  
  dest_limits <- cellranger::as.cell_limits(destination)
  prepped_dest <- gsv4_limits_to_grid_range(dest_limits, ss)
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                     gsv4_Request(copyPaste=gsv4_CopyPasteRequest(
                       source = prepped_src, 
                       destination = prepped_dest, 
                       pasteType = paste_type,
                       pasteOrientation = paste_orientation)))))
                       
  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}
