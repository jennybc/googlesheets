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
# 

# ---- Require  authorization

# test_that("A cell is updated", {
#   
#   update_cell(wks, "A14", "new")
#   expect_equal(get_cell(wks, "A14"), "new")
#   
#   update_cell(wks, "A14", "")
#   expect_equal(get_cell(wks, "R14C1"), "")
# })

# test_that("Lots of cells are updated", {
#   
#   new_vals <- head(iris)
#   update_cells(wks, "A15:E21", new_vals)
#   
#   dat1 <- read_range(wks, "A15:E21", header = TRUE)
#   
#   update_cells(wks, "A15", new_vals)
#   
#   dat2 <- read_range(wks, "A15:E21", header = TRUE)
#   
#   expect_equal(dat1, dat2) 
#   expect_equal(dat1, dat2) 
#   
#   update_cells(wks, "A15:E21", rep("", 35))
#   
# })

