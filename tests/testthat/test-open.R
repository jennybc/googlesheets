context("Opening spreadsheets and worksheets")

test_that("Open spreadsheet by key", {
  good_key <- "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk"
  bad_key <- "1WNUDoBbGsPccRkXlLqeUK9JUQNnqq2yvc9r7-XXXXXX"
  
  expect_that(open_by_key(good_key, visibility = "public"), is_a("spreadsheet"))
  throws_error(open_by_key(bad_key))
})

test_that("Open spreadsheet by url", {
  good_url <- "https://docs.google.com/spreadsheets/d/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/pubhtml"
  bad_url <- "https://docs.google.com/spreadsheets/d/1nKnfjLX7L76eWlLJjthq_XXXXXX/pubhtml"
  
  expect_that(open_by_url(good_url, visibility = "public"), is_a("spreadsheet"))
  throws_error(open_by_key(bad_url))
})


test_that("Open a public spreadsheet", {
  sheet1 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", 
                        visibility = "public")
  sheet2 <- open_by_url("https://docs.google.com/spreadsheets/d/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/pubhtml", 
                        visibility = "public")
  
  expect_equal(sheet1, sheet2)
  
})

ssheet <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", 
                      visibility = "public")

test_that("Worksheets are listed", {
  expect_true(all(list_worksheets(ssheet) %in% 
                    c("Asia", "Africa", "Americas", "Europe", "Oceania", "Blank")))          
})

test_that("Get worksheet object", {
  
  wks1 <- open_worksheet(ssheet, "Asia")
  wks2 <- open_worksheet(ssheet, 1)

  expect_that(wks1, is_a("worksheet"))
  expect_equal(wks1, wks2)
  expect_error(open_worksheet(ssheet1, "Sheet1"))
})


