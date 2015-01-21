context("Worksheet operations")

sheet1 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", 
                      visibility = "public")

wks <- open_worksheet(sheet1, "Oceania")

test_that("Get value of cell", {
  expect_equal(get_cell(wks, "A1"), "country")
  expect_equal(get_cell(wks, "R1C1"), "country")
  expect_equal(get_cell(wks, "H1"), "")
  expect_error(get_cell(wks, "A4R4T"))
})


test_that("Get all values in 1 row", {
  expect_equal(length(get_row(wks, 1)), 7)
  expect_error(get_row(wks, 10000))
})

test_that("Get a range of rows", {
  expect_equal(nrow(get_rows(wks, 2, 3)), 2)
  expect_equal(ncol(get_rows(wks, 2, 3)), 7)
})

test_that("Get all values of 1 col", {
  expect_equal(length(get_col(wks, 1)), 7)
})

test_that("Get more than 1 col", {
  expect_equal(ncol(get_cols(wks, 1, 3)), 3)
  expect_equal(nrow(get_cols(wks, 1, 2)), 6)
  expect_equal(nrow(get_cols(wks, 1, 2, header = FALSE)), 7)
})

test_that("Get the entire worksheet", {
  
  my_data <- read_all(wks)
  my_data_nh <- read_all(wks, header = FALSE)
  
  expect_that(my_data, is_a("data.frame"))
  expect_equal(nrow(my_data), 6)
  expect_equal(ncol(my_data), 7)
  
  expect_equal(nrow(my_data_nh), 7)
})

test_that("Get region of worksheet", {
  
  expect_equal(dim(read_region(wks, 1, 2, 3, 5, header = FALSE)), c(2, 3))
  expect_equal(dim(read_region(wks, 1, 2, 3, 5,)), c(1, 3))
})

test_that("Get range of worksheet", {
  
  expect_equal(read_range(wks, "A1:B1"), read_region(wks, 1, 1, 1, 2))
})


test_that("Plotting spreadsheets", {
  
  expect_that(view_all(sheet1), is_a("ggplot"))
})

test_that("Plotting worksheets", {
  
  wks_empty <- open_worksheet(sheet1, "Blank")
  wks <- open_worksheet(sheet1, "Oceania")
  
  expect_that(view(wks), is_a("ggplot"))
  expect_error(view(wks_empty), "Worksheet does not contain any values.")
})

test_that("Cell is found", {
  expect_equal(find_cell(wks, "Australia"), "Cell R2C1, A2")
  expect_equal(find_cell(wks, "Canada"), message("Cell not found"))
})

test_that("Structure of worksheet is displayed", {
  
  expect_output(str(wks), wks$title)
  expect_output(str(wks), as.character(wks$nrow))
  expect_output(str(wks), as.character(wks$ncol))
})


test_that("Structure of spreadsheet is displayed", {
  
  expect_output(str(sheet1), sheet1$sheet_title)
  expect_output(str(sheet1), as.character(sheet1$nsheets))
  expect_output(str(sheet1), sheet1$ws_names[1])
})

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

# test_that("Worksheet is resized", {
#   new_vals <- head(iris)
#   
#   update_cells(wks, "A15:E21", new_vals)
#   
#   wks <- open_worksheet(sheet1, "Oceania")
#   
#   expect_equal(wks$row_extent, 21)
#   
#   resize_worksheet(wks, nrow = 7)
#   
#   wks_new <- open_worksheet(sheet1, "Oceania")
#   
#   expect_equal(wks_new$row_extent, 7)
# })
