context("Login only spreadsheet operations")

test_that("Open my private spreadsheet", {
  sheet1 <- open_spreadsheet("Private Sheet Example")
  sheet2 <- open_by_key("1bd5wjZQI8XjPrVNUFbTLI-zhpS8qLJ1scPq1v4v3mWs")
  sheet3 <- open_by_url("https://docs.google.com/spreadsheets/d/1bd5wjZQI8XjPrVNUFbTLI-zhpS8qLJ1scPq1v4v3mWs/edit#gid=0")
  
  expect_equal(sheet1, sheet2)
  expect_equal(sheet1, sheet3)
  expect_error(open_spreadsheet("Gap"), "Spreadsheet not found.")
})

test_that("Open my public spreadsheet", {
  sheet1 <- open_spreadsheet("Public Sheet Example")
  sheet2 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk")
  sheet3 <- open_by_url("https://docs.google.com/spreadsheets/d/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/pubhtml")
  
  expect_equal(sheet1, sheet2)
  expect_equal(sheet1, sheet3)
})

test_that("Open a spreadsheet shared with me", {
  sheet1 <- open_spreadsheet("Private Sheet Example Shared")
  sheet2 <- open_by_url("https://docs.google.com/spreadsheets/d/1WpFeaRU_9bBEuK8fI21e5TcbCjQZy90dQYgXF_0JvyQ/edit?usp=sharing")
  
  expect_equal(sheet1, sheet2)
})

test_that("Open a public spreadsheet not shared with me", {
  # must set visibilty to public to open a public spreadsheet that's not shared with me
  sheet1 <- open_by_url("https://docs.google.com/spreadsheets/d/1oBit5ZknDR9n4xtNk4esufFYk6pypz8Bg9XSswijqjs/pubhtml", visibility = "public")
  
  expect_that(sheet1, is_a("spreadsheet"))
})


authorize()
ss1 <- open_spreadsheet("Gapminder")

test_that("List all my spreadsheets", {
  
  list1 <- list_spreadsheets()
  list2 <- list_spreadsheets(show_key = TRUE)
  
  expect_equal(ncol(list1), 4)
  expect_equal(ncol(list2), 5)
})

test_that("Spreadsheet is added", {
  old <- nrow(list_spreadsheets())
  add_spreadsheet("One more spreadsheet")
  
  expect_equal(nrow(list_spreadsheets()), old + 1)
})

test_that("Spreadsheet is trashed", {
  old <- nrow(list_spreadsheets())
  del_spreadsheet("One more spreadsheet")
  
  expect_equal(nrow(list_spreadsheets()), old - 1)
})

test_that("Open worksheet in one shot", {
  
  wks1 <- open_at_once("Gapminder", "Sheet1")
  
  expect_that(wks1, is_a("worksheet"))
})

test_that("Info from spreadsheets feed put into data frame", {
  
  dat <- ssfeed_to_df()
  
  expect_equal(ncol(dat), 5)
})
