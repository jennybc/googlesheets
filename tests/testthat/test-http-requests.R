context("http-requests functions")


test_that("URL is built correctly", {
  
  key <- "key"
  ws_id <- "ws_id"
  
  expect_equal(build_req_url("spreadsheets"),
               "https://spreadsheets.google.com/feeds/spreadsheets/private/full")
  expect_equal(build_req_url("worksheets", key),
               "https://spreadsheets.google.com/feeds/worksheets/key/private/full")
  expect_equal(build_req_url("list", key, ws_id),
               "https://spreadsheets.google.com/feeds/list/key/ws_id/private/full")
})

