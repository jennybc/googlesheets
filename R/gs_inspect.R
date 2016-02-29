#' Visual overview of populated cells
#'
#' \emph{This function is still experimental. Expect it to change! Or
#' disappear?} This function plots a data.frame and gives a sense of what sort
#' of data is where (e.g. character vs. numeric vs factor). Empty cells (ie.
#' \code{NA}'s) are also indicated. The purpose is to get oriented to sheets
#' that contain more than one data rectangle. Right now, due to the tabular,
#' data-frame nature of the input, we aren't really conveying when disparate
#' data types appear in a column. That might be something to work on in a future
#' version, if this proves useful. That would require working with cell-by-cell
#' data, i.e. from the cell feed.
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
#' ulti_dat <- ulti_ss %>% gs_read()
#' gs_inspect(ulti_dat)
#'
#' # totally synthetic example
#' x <- suppressWarnings(matrix(0:1, 21, 21))
#' x[sample(21^2, 10)] <- NA
#' x <- as.data.frame(x)
#' some_columns <- seq(from = 1, to = 21, by = 3)
#' x[some_columns] <- lapply(x[some_columns], as.numeric)
#' gs_inspect(x)
#' }
#' @export
gs_inspect <- function(x) {

  if(!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("gs_inspect() requires the suggested package `ggplot2`.\n",
         "Use install.packages(\"ggplot2\") to install and then retry.")
  }

  stopifnot(x %>% inherits(c("data.frame", "tbl_df")))

  base_flavors <- c("character", "numeric", "integer", "logical",
                    "factor", "complex", "empty_cell")

  # RColorBrewer::brewer.pal(8, "Dark2")[c(1, 2, 3, 6, 7)]
  cell_colours <- stats::setNames(c("#1B9E77", "#D95F02", "#7570B3", "#E6AB02",
                                    "#A6761D", "#666666", "white"), base_flavors)

  nr <- nrow(x)
  nc <- ncol(x)
  var_flavors <-
    dplyr::data_frame(var_name = factor(names(x), names(x)),
                      flavor = purrr::map_chr(x, class))

  y <-
    suppressMessages(
      dplyr::data_frame(var_name = factor(rep(names(x), each = nr), names(x)),
                        is_NA = x %>% is.na() %>% as.vector(),
                        row = rep(seq_len(nr), nc),
                        col = rep(seq_len(nc), each = nr),
                        col_letter = cellranger::num_to_letter(col)) %>%
        dplyr::left_join(var_flavors) %>%
        dplyr::mutate_(flavor = ~ factor(flavor, levels = base_flavors),
                       col_letter = ~ factor(col_letter,
                                             levels =
                                       cellranger::num_to_letter(seq_len(nc))))
    )

  y$flavor[y$is_NA] <- "empty_cell"

  cell_outline <- if(nr > 150) NA else "white"

  p <- y %>% ggplot2::ggplot(
    ggplot2::aes_string(x = "var_name", y = "row", fill = "flavor")) +
    ggplot2::geom_tile(colour = cell_outline) +
    ggplot2::facet_wrap(~ col_letter, nrow = 1, scales = 'free_x') +
    ggplot2::scale_y_reverse(breaks = round(pretty(0:nr), 0),
                             expand = c(0, 0)) +
    ggplot2::scale_fill_manual(values = cell_colours, drop = FALSE) +
    ggplot2::labs(y = "Row") +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.margin = grid::unit(0, "lines"),
                   axis.ticks = ggplot2::element_blank(),
                   axis.title.x = ggplot2::element_blank(),
                   legend.title = ggplot2::element_blank())

  if(nc > 10) {
    p <- p + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
  }

  p
}
