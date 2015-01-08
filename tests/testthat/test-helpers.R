context("helper functions")

test_that("Column letter converts to correct number", {
  
  expect_equal(letter_to_num("A"), 1)
  expect_equal(letter_to_num("AB"), 28)
  expect_equal(letter_to_num("Z"), 26)
})

test_that("Column number converts to correct letter", {
  
  expect_equal(num_to_letter(1), "A")
  expect_equal(num_to_letter(28), "AB")
  expect_equal(num_to_letter(26), "Z")
})


test_that("A1 notation converts to R1C1 notation", {
  
  expect_equal(label_to_coord("A1"), "R1C1")
  expect_equal(label_to_coord("AB10"), "R10C28")
})


test_that("R1C1 notation converts to A1 notation", {
  
  expect_equal(coord_to_label("R1C1"), "A1")
  expect_equal(coord_to_label("R10C28"), "AB10")
})


test_that("Header is set", {
  x <- data.frame(1:5, 1:5)
  
  expect_equal(nrow(set_header(x)), nrow(x) - 1)
})


test_that("Count the correct number of cells in the range", {
  
  expect_equal(ncells("A1:A1"), 1)
  expect_equal(ncells("B2:I22"), 168)
  expect_equal(ncells("C1:A1"), 3)
})


test_that("Info from spreadsheets feed put into data frame", {
  
  dat <- ssfeed_to_df()
  expect_equal(ncol(dat), 4)
})

test_that("Worksheet dimensions are correct", {
  
  ss1 <- open_spreadsheet("Testing")
  ws <- ss1$worksheets[[1]]
  ws$visibility <- "private"
  ws <- worksheet_dim(ws)
  
  expect_equal(ws$nrow, 13)
  expect_equal(ws$ncol, 7)
})