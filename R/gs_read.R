#' Read data
#'
#' This function reads data from a worksheet and returns a data frame. It wraps
#' up the most common usage of other, lower-level functions for data consumption
#' and transformation, but you can call always call them directly for finer
#' control.
#'
#' If the \code{range} argument is not specified and \code{literal = TRUE}, all
#' data will be read via \code{\link{gs_read_csv}}. Don't worry -- no
#' intermediate \code{*.csv} files are written! We just request the data from
#' the Sheets API via the \code{exportcsv} link.
#'
#' If the \code{range} argument is specified or if \code{literal = FALSE}, data
#' will be read for the targetted cells via \code{\link{gs_read_cellfeed}}, then
#' reshaped and type converted with \code{\link{gs_reshape_cellfeed}}. See
#' \code{\link{gs_reshape_cellfeed}} for details.
#'
#' @template ss
#' @template ws
#' @template range
#' @template literal
#' @template read-ddd
#' @template verbose
#'
#' @template return-tbl-df
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
#' gs_read(gap_ss, ws = "Europe", n_max = 4, col_types = c("cccccc"))
#'
#' gs_read(gap_ss, ws = "Oceania", range = "A1:C4")
#' gs_read(gap_ss, ws = "Oceania", range = "R1C1:R4C3")
#' gs_read(gap_ss, ws = "Oceania", range = "R2C1:R4C3", col_names = FALSE)
#' gs_read(gap_ss, ws = "Oceania", range = "R2C5:R4C6",
#'         col_names = c("thing_one", "thing_two"))
#' gs_read(gap_ss, ws = "Oceania", range = cell_limits(c(1, 3), c(1, 4)),
#'         col_names = FALSE)
#' gs_read(gap_ss, ws = "Oceania", range = cell_rows(1:5))
#' gs_read(gap_ss, ws = "Oceania", range = cell_cols(4:6))
#' gs_read(gap_ss, ws = "Oceania", range = cell_cols("A:D"))
#'
#' ff_ss <- gs_ff() # register example sheet with formulas and formatted nums
#' gs_read(ff_ss)                  # almost all vars are character
#' gs_read(ff_ss, literal = FALSE) # more vars are properly numeric
#' }
#'
#' @export
gs_read <- function(
  ss, ws = 1,
  range = NULL, literal = TRUE,
  ..., verbose = TRUE) {

  if (is.null(range) && literal) {
    gs_read_csv(ss, ws = ws, ..., verbose = verbose)
  } else {
    gs_read_cellfeed(ss, ws = ws, range = range, ..., verbose = verbose) %>%
      gs_reshape_cellfeed(literal = literal, ..., verbose = verbose)
  }

}
