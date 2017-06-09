context("dimension operations")

# load spreadsheet

# requires a spreadsheet to work
# test_that("Insert Rows", {
#   gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", dim = 2)
#   gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", dim = 2, side = 'above')
#   gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = head(iris))
#   gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3,4,5,6))
#   gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3,4,5,6), byrow=TRUE)
# })
# 
# test_that("Insert Columns", {
#   gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", dim = 2)
#   gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", dim = 2, side = 'left')
#   gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = head(iris))
#   gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3))
#   gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3), byrow=TRUE)
# })
# 
# test_that("Insert Cells", {
#   gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", dim = c(2,2))
#   gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", dim = c(2,2), shift_direction = 'down')
#   gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = iris[1:2,1:2])
#   gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3))
#   gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3",
#                   input = c(1,2,3), byrow=TRUE, shift_direction = 'down')
# })
# 
# 
# test_that("Delete Rows", {
#   gs_delete_rows(gap_ss, ws = "Africa", range = "A2:F4")
#   gs_delete_rows(gap_ss, ws = "Africa", range = cell_rows(1:3))
# })
# 
# test_that("Delete Columns", {
#   gs_delete_columns(gap_ss, ws = "Africa", range = "A2:C4")
#   gs_delete_columns(gap_ss, ws = "Africa", range = cell_cols(1:2))
# })
# 
# test_that("Delete Cells", {
#   gs_delete_cells(gap_ss, ws = "Africa", range = "C3:E5")
#   gs_delete_cells(gap_ss, ws = "Africa", range = "B3:B5", shift_direction = 'up')
# })