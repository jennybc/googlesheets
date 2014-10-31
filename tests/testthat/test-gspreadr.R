context("Sheets operations")

client <- authorize()

test_that("List all my spreadsheets", {
  sheets <- list_spreadsheets(client)
  
  expect_equal(length(sheets), 2)
  expect_equal(sheets, c("Gapminder", "Gapminder by Continent"))
})

test_that("Open spreadsheet by title", {
  ss1 <- open_spreadsheet(client, "Gapminder")
  
  expect_equal(class(ss1), "spreadsheet")
  expect_equal(ss1$nsheets, 1)
  expect_equal(ss1$sheet_title, "Gapminder")
  
  expect_error(class(open_spreadsheet(client, "Gap")), "Spreadsheet not found.")
})


test_that("List all my worksheets in spreadsheet", {
  expect_equal(list_worksheets(ss1), "Sheet1")
})

test_that("Get worksheet object", {
  ws <- get_worksheet(ss1, "Sheet1")
  
  expect_equal(class(ws), "worksheet")
  expect_error(get_worksheet(ss1, "Sheet2"), "Worksheet not found.")  
})

test_that("Get correct dataframe", {
  my_data <- get_dataframe(ws, client)
  
  expect_equal(class(my_data), "data.frame")
  expect_equal(nrow(my_data), 1704)
  expect_equal(ncol(my_data), 6)
})

test_that("Open spreadsheet by key", {
  good_key <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-cmEaZU"
  bad_key <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-XXXXXX"
  
  expect_equal(class(open_by_key(good_key)), "spreadsheet")
  throws_error(open_by_key(bad_key))
})

test_that("Open spreadsheet by url", {
  good_url <- "https://docs.google.com/spreadsheets/d/1nKnfjLX7L76eWlLJjthq_qf0FF1lprDv7rYs6Sm1iCw/pubhtml"
  bad_url <- "https://docs.google.com/spreadsheets/d/1nKnfjLX7L76eWlLJjthq_XXXXXX/pubhtml"
  
  expect_equal(class(open_by_url(good_url)), "spreadsheet")
  throws_error(open_by_key(bad_url))
})

