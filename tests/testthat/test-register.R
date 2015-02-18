context("register a spreadsheet")

test_that("Spreadsheets visible to authenticated user can be listed", {
  ss_list <- list_spreadsheets()
  expect_is(ss_list, "tbl_df")
  expect_more_than(nrow(ss_list), 0)
})

test_that("Spreadsheet ws_feed can be formed from url, key, title, or ws_feed", {
  expect_equal(get_ws_feed(pts_url, "public"), pts_ws_feed)
  expect_equal(get_ws_feed(pts_key, "public"), pts_ws_feed)
  expect_equal(get_ws_feed(pts_title, "public"), pts_ws_feed)
  expect_equal(get_ws_feed(pts_ws_feed), pts_ws_feed)
})

test_that("Spreadsheet can be registered via ws_feed", {
  expect_is(register(pts_ws_feed), "spreadsheet")
})

test_that("Bad spreadsheet specification throws informative error", {
  
  ## errors that prevent production of a ws_feed
  expect_error(get_ws_feed(4L), "must be character")
  expect_error(get_ws_feed(c("Gapminder", "Gapminder")),
               "must be of length 1")
  expect_error(get_ws_feed("spatula"), "doesn't match the title or key")
  
  ## errors caused by well-formed input that refers to a nonexistent spreadsheet
  nonexistent_ws_feed <- sub(pts_key, "flyingpig", pts_ws_feed)
  expect_error(register(nonexistent_ws_feed),
               "client error: \\(400\\) Bad Request")
  
  nonexistent_url <- sub(pts_key, "flyingpig", pts_url)
  expect_error(register(nonexistent_url),
               "client error: \\(400\\) Bad Request")
})

test_that("We get correct number and titles of worksheets", {
  
  ss <- register(pts_ws_feed)
  expect_more_than(ss$n_ws, 6L)
  expect_true(all(c("Asia", "Africa", "Americas", "Europe", "Oceania") %in%
                    ss$ws$ws_title))
  })

## TO DO: test re: visibility?
## TO DO: more tests about the stuff inside a registered spreadsheet?
