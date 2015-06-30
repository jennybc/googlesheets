#' Simplify data from the cell feed
#'
#' In some cases, you do not want to convert the data retrieved from the cell
#' feed into a data.frame via \code{\link{gs_reshape_cellfeed}}. Instead, you
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
#' @param x a data.frame returned by \code{\link{gs_read_cellfeed}}
#' @param convert logical, indicating whether to attempt to convert the result
#'   vector from character to something more appropriate, such as logical,
#'   integer, or numeric; if TRUE, result is passed through \code{type.convert};
#'   if FALSE, result will be character
#' @param as.is logical, passed through to the \code{as.is} argument of
#'   \code{type.convert}
#' @param na.strings a character vector of strings which are to be interpreted
#'   as \code{NA} values
#' @param notation character; the result vector can have names that reflect
#'   which cell the data came from; this argument selects between the "A1" and
#'   "R1C1" positioning notations; specify "none" to suppress names
#' @param col_names if \code{TRUE}, the first row of the input will be
#'   interpreted as a column name and NOT included in the result; useful when
#'   reading a single column or variable
#'
#' @return a vector
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' gs_read_cellfeed(gap_ss, range = cell_rows(1))
#' gs_simplify_cellfeed(gs_read_cellfeed(gap_ss, range = cell_rows(1)))
#' gs_simplify_cellfeed(
#'   gs_read_cellfeed(gap_ss, range = cell_rows(1)), notation = "R1C1")
#'
#' gs_read_cellfeed(gap_ss, range = "A1:A10")
#' gs_simplify_cellfeed(gs_read_cellfeed(gap_ss, range = "A1:A10"))
#' gs_simplify_cellfeed(gs_read_cellfeed(gap_ss, range = "A1:A10"),
#'                      col_names = FALSE)
#' }
#'
#' @family data consumption functions
#'
#' @export
gs_simplify_cellfeed <- function(
  x, convert = TRUE, as.is = TRUE, na.strings = "NA",
  notation = c("A1", "R1C1", "none"), col_names = NULL) {

  notation <- match.arg(notation)

  if(is.null(col_names) &&
     min(x$row) == 1 &&
     max(x$row) > 1 &&
     dplyr::n_distinct(x$col) == 1) {
    col_names <-  TRUE
  } else {
    col_names <- FALSE
  }
  stopifnot(identical(col_names, TRUE) || identical(col_names, FALSE))

  if(col_names) {
    x <- x %>%
      dplyr::filter_(~ row > min(row))
  }

  y <- x$cell_text
  y[match(na.strings, y)] <- NA_character_
  if(notation != "none") {
    names(y) <- switch(notation,
                       A1 = x$cell,
                       R1C1 = x$cell_alt)
  }
  if(convert) {
    y %>% utils::type.convert(as.is = as.is)
  } else {
    y
  }
}
