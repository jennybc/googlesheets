library(gspreadr)
context("Open spreadsheet by key or url")

test_that("Open spreadsheet by key returns spreadsheet object", {
  good_key <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-cmEaZU"
  bad_key <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-XXXXXX"
  
  expect_equal(class(open_by_key(good_key)), "spreadsheet")
  expect_error(open_by_key(bad_key), "The spreadsheet at this URL could not be found. Make sure that you have the right key.")
  
})

