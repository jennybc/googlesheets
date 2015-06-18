#' ---
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

#+ collapse = TRUE, comment = "#>"

library(googlesheets)
library(magrittr)

gs_auth("jenny_token.rds") ## Sheet is NOT published to the web

vn_ss <- gs_title("2015-05-23_seaRM-at-vanNH")
game_play <- vn_ss %>%
  gs_read(ws = 10, range = cell_limits(c(2, NA), c(1, 2)))
game_play %>% head
point_info <- vn_ss %>%
  gs_read_cellfeed(ws = 10, range = "D1:D4") %>%
  gs_simplify_cellfeed(col_names = FALSE)
point_info
