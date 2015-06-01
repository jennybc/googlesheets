#' Visual overview of populated cells
#'
#' \emph{This function is still experimental. Expect it to change!} This
#' function plots a data frame and is much like a visual representation of
#' \code{str} a data frame. You can inspect your data for populated and empty
#' cells. Empty cells (ie. \code{NA}'s) are represented by no colour fill. The
#' purpose is to get oriented to sheets that contain more than one data
#' rectangle.
#'
#'
#' @param x data.frame or tbl_df
#' @return a ggplot object
#'
#' @examples
#' \dontrun{
#' gs_inspect(iris)
#'
#' # data recorded from a game of ultimate frisbee
#' ulti_key <- "1223dpf3vnjZUYUnCM8rBSig3JlGrAu1Qu6VmPvdEn4M"
#' ulti_ss <- ulti_key %>% gs_key()
#' ulti_csv <- ulti_ss %>% get_col(ws = 2, col = 1:6)  %>% gs_reshape_cellfeed()
#' gs_inspect(ulti_csv)
#'
#' }
#' @export
gs_inspect <- function(x) {

  stopifnot(x %>% inherits(c("data.frame", "tbl_df")))

  # Set up colours
  base_data_types <- c("character", "numeric", "integer", "logical",
                       "factor", "complex", "empty_cell")

  # RColorBrewer::brewer.pal(6, "Accent")
  dat_colours <- c("#7FC97F", "#BEAED4", "#FDC086", "#FFFF99",
                   "#386CB0", "#F0027F", "white")

  names(dat_colours) <- base_data_types

  col_type <- sapply(x, class)
  max_col <- ncol(x)
  max_row <- nrow(x)
  coordinates <- expand.grid(row = 1:max_row, col = 1:max_col)

  x_table <- x %>%
    is.na() %>%
    data.frame() %>%
    tidyr::gather() %>%
    dplyr::bind_cols(coordinates) %>%
    dplyr::rename_(is_empty = ~ value) %>%
    dplyr::mutate_(data_type = ~ col_type[key] %>%
                     factor(levels = base_data_types),
                   col_letter = ~ cellranger::num_to_letter(col)) %>%
    dplyr::mutate_(col_letter = ~ col_letter %>%
                     factor(levels = col_letter %>% unique()))

  x_table[which(x_table$is_empty), "data_type"] <- "empty_cell"

  if(max_row > 150) {
    cell_outline <- NA
  } else {
    cell_outline <- "white"
  }

  p <- x_table %>% ggplot2::ggplot(
    ggplot2::aes_string(x = "key", y = "row", fill = "data_type")) +
    ggplot2::geom_tile(colour = cell_outline) +
    ggplot2::facet_wrap(~ col_letter, nrow = 1, scales = 'free_x') +
    ggplot2::scale_y_reverse(breaks = round(pretty(0:max_row), 0),
                             expand = c(0, 0)) +
    ggplot2::scale_fill_manual(values = dat_colours, name = "Data Type") +
    ggplot2::labs(x = "", y = "Row") +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.margin = grid::unit(0, "lines"),
                   axis.ticks = ggplot2::element_blank())

  if(max_col > 10) {
    p <- p + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
  }

  p
}
