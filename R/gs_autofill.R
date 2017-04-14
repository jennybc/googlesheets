
#' Autofill Cells
#' 
#' A function to fill in more data based on the source of existing data.
#'
#' @name gs_autofill
#' @template ss
#' @template ws
#' @template range
#' @param alternate_series a logical indicating whether to fill the data using 
#' the format of an alternate series (i.e. alternate shading)
#' @template verbose
#' @examples
#' \dontrun{
#' 
#' # if rows 1 thru 4 are blank, then autofill up based on row 5
#' # if rows 2 thru 5 are blank, then autofill down based on row 1
#' gs_autofill(gap_ss, ws = 1, range = cell_rows(1:5))
#' 
#' # autofill columns 6 & 7 based on column 5
#' gs_autofill(gap_ss, ws = 1, range = cell_cols(5:7))
#' 
#' }
#' @export
gs_autofill <- function(ss,
                        ws = 1,
                        range = "A1",
                        alternate_series = FALSE,
                        verbose = FALSE){
  
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)
  range_limits <- cellranger::as.cell_limits(range)
  range_limits$sheet <- this_ws_id
  prepped_range <- gsv4_limits_to_grid_range(range_limits, ss)
  
  # dimension <- match.arg(dimension)
  # if(is.null(fill_length)){
  #   prepped_fill <- if(dimension == 'ROWS') this_ws$row_extent - range_limits$lr[1] else this_ws$col_extent - range_limits$lr[2]
  # } else {
  #   prepped_fill <- fill_length
  # }

  # source and destination specification would be preferred
  # but there currently seems to be a bug
  # http://stackoverflow.com/questions/43395032/google-sheets-api-v4-autofill-error-no-grid-with-id-0
  # gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
  #                  input=gsv4_BatchUpdateSpreadsheetRequest(requests =
  #                          list(gsv4_Request(autoFill=gsv4_AutoFillRequest(useAlternateSeries = alternate_series,
  #                                                                          sourceAndDestination =
  #                                                                            gsv4_SourceAndDestination(source = prepped_range,
  #                                                                                                      dimension = dimension,
  #                                                                                                      fillLength = prepped_fill)
  #                                                                          )))))
  
  gsv4_batchUpdate(spreadsheetId = ss$sheet_key,
                   input=gsv4_BatchUpdateSpreadsheetRequest(requests =
                           list(gsv4_Request(autoFill=gsv4_AutoFillRequest(range = prepped_range,
                                                                           useAlternateSeries = alternate_series)))))

  ss %>% gs_gs(verbose = FALSE) %>% invisible()
}
