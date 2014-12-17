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
  expect_equal(build_req_url("cells", key, ws_id),
               "https://spreadsheets.google.com/feeds/cells/key/ws_id/private/full")
})

test_that("Query is built correctly", {
  min_row <- 1
  max_row <- 10
  min_col <- 1
  max_col <- 10
  
  expect_equal(build_query(min_row, max_row, min_col, max_col), 
               paste0("?min-row=", min_row, "&max-row=", max_row, 
                      "&min-col=", min_col, "&max-col=", max_col))
  expect_equal(build_query(min_row = min_row, max_row = max_row, 
                           min_col = NULL, max_col = NULL),
               paste0("?&min-row=", min_row, "&max-row=", max_row))
  expect_equal(build_query(min_row = NULL, max_row = NULL, 
                           min_col = min_col, max_col = max_col),
               paste0("?&min-col=", min_col, "&max-col=", max_col))
})
