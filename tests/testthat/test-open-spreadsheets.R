context("opening spreadsheets")

test_that("Open my private spreadsheet", {
  sheet1 <- open_spreadsheet("Private Sheet Example")
  sheet2 <- open_by_key("1bd5wjZQI8XjPrVNUFbTLI-zhpS8qLJ1scPq1v4v3mWs")
  sheet3 <- open_by_url("https://docs.google.com/spreadsheets/d/1bd5wjZQI8XjPrVNUFbTLI-zhpS8qLJ1scPq1v4v3mWs/edit#gid=0")
  
  expect_equal(sheet1, sheet2)
  expect_equal(sheet1, sheet3)

})

test_that("Open my public spreadsheet", {
  sheet1 <- open_spreadsheet("Public Sheet Example")
  sheet2 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk")
  sheet3 <- open_by_url("https://docs.google.com/spreadsheets/d/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/pubhtml")
  
  expect_equal(sheet1, sheet2)
  expect_equal(sheet1, sheet3)
})

# test_that("Open a spreadsheet shared with me", {
#   sheet1 <- open_spreadsheet("Private Sheet Example Shared")
#   sheet2 <- open_by_url("https://docs.google.com/spreadsheets/d/1WpFeaRU_9bBEuK8fI21e5TcbCjQZy90dQYgXF_0JvyQ/edit?usp=sharing")
#   
#   expect_equal(sheet1, sheet2)
# })
# 
# test_that("Open a public spreadsheet not shared with me", {
#   # must set visibilty to public to open a public spreadsheet that's not shared with me
#   sheet1 <- open_by_url("https://docs.google.com/spreadsheets/d/11j3LvNgiwzw4CdYeKoRULfyqpOlPJb-OzyUur3qX63I/pubhtml", visibility = "public")
#   
#   expect_equal(class(sheet1), "spreadsheet")
# })
# 
