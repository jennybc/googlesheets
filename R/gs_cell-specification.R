## the real work is done by the cellranger package
## https://github.com/jennybc/cellranger
## http://cran.r-project.org/web/packages/cellranger/index.html

## here we
##   [1] import + export specific cellranger functions to expose them for
##       googlesheets users
##   [2] further below, define unexported utility functions for translating
##       between a cell_limits object and data structures we need in this pkg

#' Specify cells for reading or writing
#'
#' If you aren't targetting all the cells in a worksheet, you can request that
#' \code{googlesheets} limit a read or write operation to a specific rectangle
#' of cells. Any function that offers this flexibility will have a \code{range}
#' argument. The simplest usage is to specify an Excel-like cell range, such as
#' \code{range = "D12:F15"} or \code{range = "R1C12:R6C15"}. The cell rectangle
#' can be specified in various other ways, using helper functions. In all cases,
#' cell range processing is handled by the \code{\link[=cellranger]{cellranger}}
#' package, where you can find full documentation for the functions used in the
#' examples below.
#'
#' @examples
#' \dontrun{
#' gs_gap() %>% gs_read(ws = 2, range = "A1:D8")
#' gs_gap() %>% gs_read(ws = "Europe", range = cell_rows(1:4))
#' gs_gap() %>% gs_read(ws = "Europe", range = cell_rows(100:103),
#'                      col_names = FALSE)
#' gs_gap() %>% gs_read(ws = "Africa", range = cell_cols(1:4))
#' gs_gap() %>% gs_read(ws = "Asia", range = cell_limits(c(1, 5), c(4, NA)))
#' }
#'
#' @template cellranger
#' @name cell-specification
NULL

#' @importFrom cellranger cell_limits
#' @name cell_limits
#' @export
#' @rdname cell-specification
NULL

#' @importFrom cellranger cell_rows
#' @name cell_rows
#' @export
#' @rdname cell-specification
NULL

#' @importFrom cellranger cell_cols
#' @name cell_cols
#' @export
#' @rdname cell-specification
NULL

#' @importFrom cellranger anchored
#' @name anchored
#' @export
#' @rdname cell-specification
NULL

## cell specification functions that are specific to googlesheets, i.e. stuff
## not handled in cellranger

## basically boils down to:
## cell_limits object <--> limits in the list form I need for Sheets API query

limit_list <- function(x) {

  stopifnot(inherits(x, "cell_limits") || is.null(x))

  if(inherits(x, "cell_limits")) {
    retval <- list(`min-row` = x$ul[1], `max-row` = x$lr[1],
                   `min-col` = x$ul[2], `max-col` = x$lr[2])
    retval[is.na(retval)] <- NULL
  }

  if(length(retval)) {
    retval
  } else {
    NULL
  }

}

un_limit_list <- function(x) {

  cellranger::cell_limits(ul = c(x[['min-row']], x[['min-col']]),
                          lr = c(x[['max-row']], x[['max-col']]))

}
