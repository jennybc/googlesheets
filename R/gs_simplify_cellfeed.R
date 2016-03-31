#' Simplify data from the "cell feed"
#'
#' In some cases, you do not want to convert the data retrieved from the cell
#' feed into a data frame via \code{\link{gs_reshape_cellfeed}}. Instead, you
#' want the data as an atomic vector. That's what this function does. Note that,
#' unlike \code{\link{gs_reshape_cellfeed}}, embedded empty cells will NOT
#' necessarily appear in this result. By default, the API does not transmit data
#' for these cells; \code{googlesheets} inserts these cells in
#' \code{\link{gs_reshape_cellfeed}} because it is necessary to give the data
#' rectangular shape. In contrast, empty cells will only appear in the output of
#' \code{gs_simplify_cellfeed} if they were already present in the data from the
#' cell feed, i.e. if the original call to \code{\link{gs_read_cellfeed}} had
#' argument \code{return_empty} set to \code{TRUE}.
#'
#' @param x a data frame returned by \code{\link{gs_read_cellfeed}}
#' @param convert logical. Indicates whether to attempt to convert the result
#'   vector from character to something more appropriate, such as logical,
#'   integer, or numeric. If \code{TRUE}, result is passed through
#'   \code{\link[readr:type_convert]{readr::type_convert}}; if \code{FALSE},
#'   result will be character.
#' @template literal
#' @param locale,trim_ws,na Optionally, specify locale, the fate of leading or
#'   trailing whitespace, or a character vector of strings that should become
#'   missing values. Passed straight through to
#'   \code{\link[readr:type_convert]{readr::type_convert}}.
#' @param notation character. The result vector can have names that reflect
#'   which cell the data came from; this argument selects between the "A1" and
#'   "R1C1" positioning notations. Specify "none" to suppress names.
#' @param col_names if \code{TRUE}, the first row of the input will be
#'   interpreted as a column name and NOT included in the result; useful when
#'   reading a single column or variable.
#'
#' @return a vector
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' (gap_cf <- gs_read_cellfeed(gap_ss, range = cell_rows(1)))
#' gs_simplify_cellfeed(gap_cf)
#' gs_simplify_cellfeed(gap_cf, notation = "R1C1")
#'
#' (gap_cf <- gs_read_cellfeed(gap_ss, range = "A1:A10"))
#' gs_simplify_cellfeed(gap_cf)
#' gs_simplify_cellfeed(gap_cf, col_names = FALSE)
#'
#' ff_ss <- gs_ff() # register example sheet with formulas and formatted nums
#' ff_cf <- gs_read_cellfeed(ff_ss, range = cell_cols(3))
#' gs_simplify_cellfeed(ff_cf)                  # rounded to 2 digits
#' gs_simplify_cellfeed(ff_cf, literal = FALSE) # hello, more digits!
#' }
#'
#' @family data consumption functions
#'
#' @export
gs_simplify_cellfeed <- function(
  x, convert = TRUE, literal = TRUE,
  locale = NULL, trim_ws = NULL, na = NULL,
  notation = c("A1", "R1C1", "none"), col_names = NULL) {

  notation <- match.arg(notation)
  stopifnot(is_toggle(literal))

  if (is.null(col_names)) {
    if (min(x$row) == 1 &&
        max(x$row) > 1 &&
        dplyr::n_distinct(x$col) == 1) {
      col_names <-  TRUE
    } else {
      col_names <- FALSE
    }
  }
  stopifnot(isTRUE(col_names) || isFALSE(col_names))

  if (col_names) {
    x <- x %>%
      dplyr::filter_(~ row > min(row))
  }

  if (convert) {
    ddd <- list(locale = locale, trim_ws = trim_ws, na = na)

    if (isFALSE(literal)) {
      x <- reconcile_cell_contents(x)
    }

    type_convert_args <- c(list(df = x["value"]), dropnulls(ddd))
    df <- do.call(readr::type_convert, type_convert_args)
    x$value <- df$value
  }

  nms <- switch(notation,
                A1 = x$cell,
                R1C1 = x$cell_alt,
                NULL)
  x[["value"]] %>%
    stats::setNames(nms)
}
