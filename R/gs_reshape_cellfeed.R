#' Reshape data from the "cell feed"
#'
#' Reshape data from the "cell feed" and convert to a \code{tbl_df}
#'
#' @param x a data.frame returned by \code{\link{gs_read_cellfeed}}
#' @param col_names if \code{TRUE}, the first row of the input will be used as
#'   the column names; if \code{FALSE}, column names will be X1, X2, etc.; if a
#'  character vector, vector will be used as the column names
#' @template verbose
#'
#' @family data consumption functions
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' gs_read_cellfeed(gap_ss, "Asia", range = cell_rows(1:4))
#' gs_reshape_cellfeed(gs_read_cellfeed(gap_ss, "Asia", range = cell_rows(1:4)))
#' gs_reshape_cellfeed(gs_read_cellfeed(gap_ss, "Asia",
#'                                      range = cell_rows(2:4)),
#'                     col_names = FALSE)
#' gs_reshape_cellfeed(gs_read_cellfeed(gap_ss, "Asia",
#'                                      range = cell_rows(2:4)),
#'                     col_names = paste0("yo", 1:6))
#' }
#' @export
gs_reshape_cellfeed <- function(x, col_names = TRUE, verbose = TRUE) {

  limits <- x %>%
    dplyr::summarise_each_(dplyr::funs(min, max), list(~ row, ~ col))
  all_possible_cells <-
    with(limits,
         expand.grid(row = row_min:row_max, col = col_min:col_max)) %>%
    dplyr::as.tbl()
  suppressMessages(
    x_augmented <- all_possible_cells %>% dplyr::left_join(x)
  )
  ## tidyr::spread(), used below, could do something similar as this join, but
  ## it would handle completely missing rows and columns differently; still
  ## thinking about this

  if(is.character(col_names)) {
    n_cols <- dplyr::n_distinct(x_augmented$col)
    stopifnot(length(col_names) == n_cols)
    var_names <- col_names
  } else {
    stopifnot(identical(col_names, TRUE) || identical(col_names, FALSE))
    if(col_names) {
      row_one <- x_augmented %>%
        dplyr::filter_(~ (row == min(row))) %>%
        dplyr::mutate_(cell_text = ~ ifelse(cell_text == "", NA, cell_text))
      var_names <- ifelse(is.na(row_one$cell_text),
                          stringr::str_c("X", row_one$col),
                          row_one$cell_text) %>% make.names()
      x_augmented <- x_augmented %>%
        dplyr::filter_(~ row > min(row))
    } else {
      var_names <- limits$col_min:limits$col_max %>% make.names()
    }
  }

  if(x_augmented$row %>% dplyr::n_distinct() < 1) {
    if(verbose) {
      message("No data to reshape!")
      if(isTRUE(col_names)) {
        message("Perhaps retry with `col_names = FALSE`?")
      }
    }
    return(dplyr::data_frame() %>% dplyr::as.tbl())
  }

  x_augmented %>%
    dplyr::select_(~ row, ~ col, ~ cell_text) %>%
    ## do not set 'convert = TRUE' here!
    ## leave as character so readr::type_convert below handles it all
    tidyr::spread_("col", "cell_text") %>%
    dplyr::select_(~ -row) %>%
    stats::setNames(var_names) %>%
    readr::type_convert() %>%
    dplyr::mutate_each_(dplyr::funs(force_na_type), var_names)

}
