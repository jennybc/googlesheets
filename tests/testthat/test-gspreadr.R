library(gspreadr)
context("Open spreadsheet by key or url")

test_that("Open spreadsheet by key returns spreadsheet object", {
  good_key <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-cmEaZU"
  bad_key <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-XXXXXX"
  
  expect_equal(class(open_by_key(good_key)), "spreadsheet")
  expect_error(open_by_key(bad_key), "The spreadsheet at this URL could not be found. Make sure that you have the right key.")
  
})

test_that("Login with correct credentials", {
  email <- "gspreadr@gmail.com"
  passwd <- "gspreadrtester"
  
  expect_equal(class(login(email, passwd)), "client")
  expect_error(login(email, "wrongpasswd"), "Incorrect username or password.")
  expect_error(login("wrongemail", passwd), "Incorrect username or password.")
  
})


