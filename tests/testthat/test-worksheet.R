context("worksheet operations")

ws <- open_at_once("basic-usage", "Sheet1")

test_that("Get column back",{
  
  expect_equal(letter_to_col("A"), 1)
  expect_equal(letter_to_col("AB"), 28)
})


test_that("Convert A1 to R1C1 notation", {
  
  expect_equal(label_to_coord("A1"), "R1C1")
  expect_equal(label_to_coord("AB10"), "R10C28")
})

test_that("Get value of cell", {
  
  expect_equal(get_cell(ws, "A1"), "country")
  expect_equal(get_cell(ws, "R1C1"), "country")
  expect_equal(get_cell(ws, "ZZ1"), "")
  expect_error(get_cell(ws, "A4R4T"))
})


test_that("Get all values in 1 row", {
  
  expect_equal(length(get_row(ws, 2)), 7)
  expect_error(get_row(ws, 10000))
})

test_that("Get a range of rows", {
  
  expect_equal(nrow(get_rows(ws, 2, 3)), 2)
  expect_equal(get_rows(ws, 7, 8), get_rows(ws, 8, 7))
})

test_that("Get all values of 1 col", {
  
  expect_equal(length(get_col(ws, 1)), 13)
})

test_that("Get more than 1 col", {
  
  expect_equal(ncol(get_cols(ws, 1, 3)), 3)
  expect_equal(nrow(get_cols(ws, 1, 2)), 12)
})

test_that("Get the entire worksheet", {
  
  my_data <- get_all(ws)
  
  expect_equal(class(my_data), "data.frame")
  expect_equal(nrow(my_data), 12)
  expect_equal(ncol(my_data), 7)
})

test_that("Get region of worksheet", {
  
  expect_equal(dim(read_region(ws, 1, 2, 3, 5, header = FALSE)), c(2, 3))
  expect_equal(dim(read_region(ws, 1, 2, 3, 5,)), c(1, 3))
})