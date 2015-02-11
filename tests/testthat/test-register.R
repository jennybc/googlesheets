context("register a spreadsheet")

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

test_that("Spreadsheet can be registered by any means necessary", {
  
  expect_equal(get_ws_feed(pts_url, "public"), pts_ws_feed)
  expect_equal(get_ws_feed(pts_key, "public"), pts_ws_feed)
  expect_equal(get_ws_feed(pts_title, "public"), pts_ws_feed)
  expect_equal(get_ws_feed(pts_ws_feed), pts_ws_feed)
  
  expect_is(register(pts_ws_feed), "spreadsheet")
})

## TO DO: test re: visibility?

test_that("Number and titles of worksheets are obtained", {
  ss <- register(pts_ws_feed)
  expect_equal(ss$n_ws, 6L)
  expect_true(all(ss$ws$ws_title %in%
                    c("Asia", "Africa", "Americas", "Europe",
                      "Oceania", "Blank")))      
})

## TO DO: more tests about the stuff inside a spreadsheet?

