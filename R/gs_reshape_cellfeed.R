#' Reshape data from the "cell feed"
#'
#' Reshape data from the "cell feed" and convert to a \code{tbl_df}.
#'
#' @param x a data.frame returned by \code{\link{gs_read_cellfeed}}
#' @template read-ddd
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
gs_reshape_cellfeed <- function(x, ..., verbose = TRUE) {

  ## TEMPORARY PARKING of old docs re: col_names
  # @param col_names if \code{TRUE}, the first row of the input will be used as
  #   the column names; if \code{FALSE}, column names will be X1, X2, etc.; if a
  #  character vector, vector will be used as the column names

  ddd <- parse_read_ddd(..., feed = "cell", verbose = verbose)
  col_names <- ddd$col_names

  limits <- x %>%
    dplyr::summarise_each_(dplyr::funs(min, max), list(~ row, ~ col))
  all_possible_cells <-
    expand.grid(row = seq.int(limits$row_min, limits$row_max),
                col = seq.int(limits$col_min, limits$col_max)) %>%
    dplyr::as.tbl()
  suppressMessages(
    x_augmented <- all_possible_cells %>%
      dplyr::left_join(x) %>%
      dplyr::arrange_(~ row, ~ col)
  )
  n_cols <- dplyr::n_distinct(x_augmented$col)

  if (isTRUE(col_names)) {
    row_one <- x_augmented %>%
      dplyr::filter_(~ (row == limits$row_min))
    vnames <- row_one$cell_text
    x_augmented <- x_augmented %>%
      dplyr::filter_(~ row > limits$row_min)
  }

  if (isFALSE(col_names)) {
    vnames <- paste0("X", seq.int(limits$col_min, limits$col_max))
  }

  if (is.character(col_names)) {
    vnames <- col_names
  }

  vnames <- vet_names(vnames, vnames, ddd$check.names, n_cols, verbose)

  if (x_augmented$row %>% dplyr::n_distinct() < 1) {
    if (verbose) {
      message("No data to reshape!")
      if (isTRUE(col_names)) {
        message("Perhaps retry with `col_names = FALSE`?")
      }
    }
    return(dplyr::data_frame() %>% dplyr::as.tbl())
  }

  dat <- matrix(x_augmented$cell_text, ncol = n_cols, byrow = TRUE,
                dimnames = list(NULL, vnames))
  dat <- dat %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::as_data_frame()

  allowed_args <- c("col_types", "locale", "trim_ws", "na")
  type_convert_args <- c(list(df = dat, dropnulls(ddd[allowed_args])))
  df <- do.call(readr::type_convert, type_convert_args)

  ## our departures from readr data ingest:
  ## ~~no NA variable names~~ handled elsewhere in this function
  ## NA vars should be logical, not character
  df %>%
    purrr::dmap(force_na_type)

}
