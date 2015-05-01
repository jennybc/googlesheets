#' Visual overview of populated cells
#'
#' This function plots a data frame and is much like a visual representation of 
#' \code{str} on a data frame. You can inspect your data for populated and empty 
#' cells. Empty cells (ie. \code{NA}'s) are represented by no colour fill. 
#'   
#' @param x data.frame or tbl_df
#' @return a ggplot object
#'
#' @examples
#' \dontrun{
#' gs_inspect(iris)
#' 
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' oceania_csv <- get_via_csv(gap_ss, ws = "Oceania")
#' gs_inspect(oceania_csv)
#' 
#' }
#' @export
gs_inspect <- function(x) {
  
  stopifnot(x %>% inherits(c("data.frame", "tbl_df")))
  
  col_type <- sapply(x, class) 
  coordinates <- expand.grid(row = 1:nrow(x), col = 1:ncol(x))
  
  x_table <- x %>%
    is.na() %>% 
    data.frame() %>%
    tidyr::gather() %>% 
    dplyr::bind_cols(coordinates) %>%
    dplyr::mutate_(data_type = ~ col_type[key]) %>%
    dplyr::filter_(~ value == FALSE) %>%
    dplyr::select_(~ -value)
  
  max_col <- ncol(x)
  max_row <- nrow(x)
  
  if(max_row > 200) {
    cell_outline <- NA
  } else {
    cell_outline <- "white"
  }
  
  p <- x_table %>% 
    ggplot2::ggplot(ggplot2::aes(x = col, y = row, fill = data_type)) +
    ggplot2::geom_tile(colour = cell_outline) +
    ggplot2::scale_x_continuous(breaks = seq(1, max_col, 1), 
                       labels = strtrim(levels(x_table$key), 20)) +
    ggplot2::scale_y_reverse(breaks = round(pretty(0:max_row), 0)) +
    ggplot2::scale_fill_brewer(name = "Type") +
    ggplot2::annotate("text", 
             x = seq(1, max_col, 1), 
             y = (-0.05) * max_row, 
             label = num_to_letter(1:max_col)) +
    ggplot2::labs(x = "Col", y = "Row") + 
    ggplot2::theme_bw()
  
  if(max_col > 10) {
    p <- p + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))
  }
  
  p
}
