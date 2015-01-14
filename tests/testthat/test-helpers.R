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

test_that("Worksheet dimensions are correct", {
  
  sheet1 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", 
                        visibility = "public")
  
  ws <- sheet1$worksheets[[5]]
  ws$visibility <- "private"
  ws <- worksheet_dim(ws)
  
  expect_equal(ws$nrow, 7)
  expect_equal(ws$ncol, 7)
})


test_that("Range occupied by dataframe is correct", {
  
  dat <- data.frame(a = 1:3, b = 1:3, c = 1:3)
  
  expect_equal(build_range(dat, "A1", header = TRUE), "A1:C4")
  expect_equal(build_range(dat, "A1", header = FALSE), "A1:C3")
  
})

test_that("Worksheet is empty", {
  sheet1 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk",
                        visibility = "public")
  wks <- open_worksheet(sheet1, "Blank")
  
  expect_error(check_empty(wks), "Worksheet does not contain any values.")
})

