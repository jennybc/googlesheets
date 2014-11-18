context("Sheets operations")

authorize()
ss1 <- open_spreadsheet("Gapminder")

test_that("List all my spreadsheets", {
  expect_equal(length(list_spreadsheets()), 2)
})

test_that("Open spreadsheet by title", {
  
  expect_equal(class(ss1), "spreadsheet")
  expect_equal(ss1$nsheets, 1)
  expect_equal(ss1$sheet_title, "Gapminder")
  expect_error(open_spreadsheet("Gap"), "Spreadsheet not found.")
})

test_that("List all my worksheets in spreadsheet", {
  expect_equal(list_worksheets(ss1), "Sheet1")
})

test_that("Get worksheet object", {
  
  expect_equal(class(open_worksheet(ss1, "Sheet1")), "worksheet")
  expect_equal(open_worksheet(ss1, "Sheet1"), open_worksheet(ss1, 1))
  expect_error(open_worksheet(ss1, "Sheet2"), "Worksheet not found.")  
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

test_that("Get all values of 1 row", {
  ws <- open_worksheet(ss1, "Sheet1")
  
  expect_equal(length(get_row(ws, 2)), 6)
  expect_error(get_row(ws, 10000), 
               "Specified row exceeds the number of rows contained in worksheet.")
})

test_that("Get more than 1 row", {
  ws <- open_worksheet(ss1, "Sheet1")
  
  expect_equal(nrow(get_rows(ws, 2, 3)), 2)
  expect_equal(get_rows(ws, 15, 12), get_rows(ws, 12, 15))
})

test_that("Get all values of 1 col", {
  ws <- open_worksheet(ss1, "Sheet1")
  
  expect_equal(length(get_col(ws, 1)), 1705)
})

test_that("Get more than 1 col", {
  ws <- open_worksheet(ss1, "Sheet1")
  
  expect_equal(ncol(get_cols(ws, 1, 3)), 3)
  expect_equal(nrow(get_cols(ws, 1, 2)), 1705)
})

test_that("Get correct dataframe", {
  ws <- open_worksheet(ss1, "Sheet1")
  my_data <- get_dataframe(ws)
  
  expect_equal(class(my_data), "data.frame")
  expect_equal(nrow(my_data), 1705)
  expect_equal(ncol(my_data), 6)
})

test_that("Get region of worksheet", {
  ws <- open_at_once("Gapminder by regions", "Sheet1")
  
  expect_equal(dim(get_region(ws, 1, 2, 3, 4)), c(2, 2))
})


test_that("Add worksheet", {
  add_worksheet(ss1, "bar", 10, 10)
  ss1 <- open_spreadsheet("Gapminder")
  name_match <- "bar" %in% ss1$ws_names
  
  expect_equal(ss1$nsheets, 2)
  expect_true(name_match)
  
})

test_that("Delete worksheet", {
  ss1 <- open_spreadsheet("Gapminder")
  ws <- open_worksheet(ss1, "bar")
  del_worksheet(ss1, ws)
  ss1 <- open_spreadsheet("Gapminder")
  name_match <- "bar" %in% ss1$ws_names
  
  expect_equal(ss1$nsheets, 1)
  expect_false(name_match)
  
})
