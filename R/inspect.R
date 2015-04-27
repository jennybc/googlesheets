#' Visual overview of populated cells
#'
#' This function plots a data frame. You can inspect your data for 
#' populated/empty cells and data types after consuming the data. Empty cells 
#' (ie. \code{NA}'s) are represented by no colour fill. 
#'   
#' @param x data.frame or tbl_df
#' @return a ggplot object
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' oceania_csv <- get_via_csv(gap_ss, ws = "Oceania")
#' gs_inspect(oceania_csv)
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
  
  p <- x_table %>% 
    ggplot(aes(x = col, y = row, fill = data_type)) +
    geom_tile() +
    scale_x_continuous(breaks = seq(1, max_col, 1), 
                     expand = c(0, 0), 
                     labels = levels(x_table$key)) +
    scale_y_reverse() +
    scale_fill_brewer(name = "Type") +
    annotate("text", 
             x = seq(1, max_col, 1), 
             y = (-0.05) * max_row, 
             label = num_to_letter(1:max_col)) +
    labs(x = "Col", y = "Row")
  
  if(max_col > 10) {
    p <- p + theme(axis.text.x = element_text(angle = 90))
  }
  p
}
