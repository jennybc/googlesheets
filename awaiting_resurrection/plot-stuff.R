#' Plot worksheet
#'
#' @param tbl data frame returned by \code{\link{get_lookup_tbl}}
# make_plot <- function(tbl)
# {
#   ggplot(data = tbl, aes(x = col, y = row)) +
#     geom_tile(width = 1, height = 1, fill = "steelblue2", alpha = 0.4) +
#     facet_wrap(~ Sheet) +
#     scale_x_continuous(breaks = seq(1, max(tbl$col), 1), expand = c(0, 0),
#                        limits = c(1 - 0.5, max(tbl$col) + 0.5)) +
#     annotate("text", x = seq(1, max(tbl$col), 1), y = (-0.05) * max(tbl$row), 
#              label = LETTERS[1:max(tbl$col)], colour = "blue",
#              fontface = "bold") +
#     scale_y_reverse() +
#     ylab("Row") +
#     theme(panel.grid.major.x = element_blank(),
#           plot.title = element_text(face = "bold"),
#           axis.text.x = element_blank(),
#           axis.title.x = element_blank(),
#           axis.ticks.x = element_blank())
# }

# context("Worksheet operations")
# 
# public_testing_sheet <- open_by_key(key = pts_key, visibility = "public")
# 
# wks <- open_worksheet(public_testing_sheet, "Oceania")
# 
# test_that("Plotting spreadsheets", {
#   
#   expect_that(view_all(sheet1), is_a("ggplot"))
# })
# 
# test_that("Plotting worksheets", {
#   
#   wks_empty <- open_worksheet(sheet1, "Blank")
#   wks <- open_worksheet(sheet1, "Oceania")
#   
#   expect_that(view(wks), is_a("ggplot"))
#   expect_error(view(wks_empty), "Worksheet does not contain any values.")
# })
