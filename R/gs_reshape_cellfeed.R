#' Reshape data from the "cell feed"
#'
#' Reshape data from the "cell feed", put it in a \code{tbl_df}, and do type
#' conversion. By default, assuming we're working with the same cells,
#' \code{gs_reshape_cellfeed} should return the same result as other read
#' functions. But when \code{literal = FALSE}, something different happens: we
#' attempt to deliver cell contents free of any numeric formatting. Try this if
#' numeric formatting of literal values is causing numeric data to come in as
#' character, to be undesirably rounded, or to be otherwise mangled. Remember
#' you can also control type conversion by using \code{...} to provide arguments
#' to \code{\link[readr:type_convert]{readr::type_convert}}. See the
#' \code{vignette("formulas-and-formatting")} for more details.
#'
#' @param x a data frame returned by \code{\link{gs_read_cellfeed}}
#' @template literal
#' @template read-ddd
#' @template verbose
#'
#' @template return-tbl-df
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
#'
#' ff_ss <- gs_ff() # register example sheet with formulas and formatted nums
#' ff_cf <- gs_read_cellfeed(ff_ss)
#' gs_reshape_cellfeed(ff_cf) # almost all vars are character
#' gs_reshape_cellfeed(ff_cf, literal = FALSE) # more vars are numeric
#' }
#' @export
gs_reshape_cellfeed <- function(x, literal = TRUE, ..., verbose = TRUE) {

  ddd <- parse_read_ddd(..., verbose = verbose)
  stopifnot(is_toggle(literal))
  if (isFALSE(literal)) {
    x <- reconcile_cell_contents(x)
  }
  gs_reshape_feed(x, ddd, verbose)

}

gs_reshape_feed <- function(x, ddd, verbose = TRUE) {

  skip <- ddd$skip %||% 0L
  if (skip > 0) {
    row_min <- min(x$row)
    x <- x %>%
      dplyr::filter_(~row > row_min + skip - 1)
  }

  x <- x %>%
#    tidyr::complete_(cols = c("row", "col")) %>%
    tidyr::complete(row = tidyr::full_seq(row, 1),
                    col = tidyr::full_seq(col, 1)) %>%
    dplyr::arrange_(~row, ~col)
  n_cols <- dplyr::n_distinct(x$col)

  if (isTRUE(ddd$col_names)) {
    row_min <- min(x$row)
    row_one <- x %>%
      dplyr::filter_(~(row == row_min))
    x <- x %>%
      dplyr::filter_(~row > row_min)
    vnames <- size_names(row_one$value, n_cols)
  } else if (isFALSE(ddd$col_names)) {
    vnames <- paste0("X", seq_len(n_cols))
  } else if (is.character(ddd$col_names)) {
    vnames <- size_names(ddd$col_names, n_cols)
  } else {
    stop("`col_names` must be TRUE, FALSE or a character vector", call. = FALSE)
  }
  vnames <- fix_names(vnames, ddd$check.names)

  if (dplyr::n_distinct(x$row) < 1) {
    if (verbose) {
      message("No data to reshape!")
      if (isTRUE(ddd$col_names)) {
        message("Perhaps retry with `col_names = FALSE`?")
      }
    }
    return(dplyr::data_frame())
  }

  dat <- matrix(x$value, ncol = n_cols, byrow = TRUE,
                dimnames = list(NULL, vnames))
  dat <- dat %>%
    ## https://github.com/hadley/dplyr/issues/876
    ## https://github.com/hadley/dplyr/commit/9a23e869a027861ec6276abe60fe7bb29a536369
    ## I can drop as.data.frame() once dplyr version >= 0.4.4
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::as_data_frame()

  if (!is.null(ddd$comment)) {
    keep_row <- !grepl(paste0("^", ddd$comment), dat[[1]])
    dat <- dat[keep_row, , drop = FALSE]
    dat <- dat %>%
      purrr::dmap(~stringr::str_replace(.x, paste0(ddd$comment, ".*"), ""))
  }

  if (!is.null(ddd$n_max)) {
    dat <- dat[seq_len(ddd$n_max), , drop = FALSE]
  }

  allowed_args <- c("col_types", "locale", "trim_ws", "na")
  type_convert_args <- c(list(df = dat), dropnulls(ddd[allowed_args]))
  df <- do.call(readr::type_convert, type_convert_args)

  ## our departures from readr data ingest:
  ## ~~no NA variable names~~ handled elsewhere (above) in this function
  ## NA vars should be logical, not character
  df %>%
    purrr::dmap(force_na_type)

}
