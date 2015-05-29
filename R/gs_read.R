#' Read data
#'
#' This function reads data from a worksheet and returns it as a \code{tbl_df}
#' or \code{data.frame}. It wraps up the most common usage of other, lower-level
#' functions for data consumption and transformation, but you can call always
#' call them directly for finer control.
#'
#' If the \code{range} argument is not specified, all data will be read via
#' \code{\link{gs_read_csv}}. In this case, you can pass additional arguments to
#' the csv parser via \code{...}; see \code{\link{gs_read_cellfeed}} for more
#' details. Don't worry -- no intermediate \code{*.csv} files were written in
#' the reading of your data! We just request the data from the Sheets API via
#' the \code{exportcsv} link.
#'
#' If the \code{range} argument is specified, data will be read for the
#' targetted cells via \code{\link{gs_read_cellfeed}}, then reshaped with
#' \code{\link{gs_reshape_cellfeed}}. In this case, you can pass additional
#' arguments to \code{\link{gs_reshape_cellfeed}} via \code{...}.
#'
#' @template ss
#' @template ws
#' @param range blah blah
#' @param ... optional arguments passed on to functions that control reading and
#'   transforming the data
#' @template verbose
#'
#' @return a tbl_df
#'
#' @family data consumption functions
#'
#' @seealso The \code{\link{cell-specification}} topic for more about targetting
#'   specific cells.
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap()
#' oceania_csv <- gs_read(gap_ss, ws = "Oceania")
#' str(oceania_csv)
#' oceania_csv
#'
#' gs_read(gap_ss, ws = "Oceania", range = "A1:C4")
#' gs_read(gap_ss, ws = "Oceania", range = "R1C1:R4C3")
#' gs_read(gap_ss, ws = "Oceania", range = "R2C1:R4C3", col_names = FALSE)
#' gs_read(gap_ss, ws = "Oceania", range = "R2C5:R4C6",
#'         col_names = c("thing_one", "thing_two"))
#' gs_read(gap_ss, ws = "Oceania", range = cell_limits(c(1, 4), c(1, 3)))
#' gs_read(gap_ss, ws = "Oceania", range = cell_rows(1:5))
#' gs_read(gap_ss, ws = "Oceania", range = cell_cols(4:6))
#' gs_read(gap_ss, ws = "Oceania", range = cell_cols("A:D"))
#' gs_read(gap_ss, ws = "Oceania", range = cell_rows(1), col_names = FALSE)
#' }
#'
#' @export
gs_read <- function(
  ss, ws = 1,
  range = NULL,
  ..., verbose = TRUE) {

  if(is.null(range)) {
    gs_read_csv(ss, ws = ws, ..., verbose = verbose)
  } else {
    gs_read_cellfeed(ss, ws = ws, range = range, verbose = verbose) %>%
      gs_reshape_cellfeed(..., verbose = verbose)
  }

}
