context("register sheets")

test_that("Spreadsheets visible to authenticated user can be listed", {
  ss_list <- gs_ls()
  expect_is(ss_list, "googlesheet_ls")
  expect_more_than(nrow(ss_list), 0)
})

test_that("Spreadsheet can be ID'd via URL, key, title, ws_feed or ss", {

  ## NOTE: we've got to look for stuff we (gspreadr) own here, because this is
  ## all about the spreadsheets feed

  expect_equal_to_iris_identify <- function(x, method = NULL) {
    expect_equal_to_reference(identify_ss(x), "iris_identify_ss.rds")
  }

  ## let identify_ss() determine the method
  expect_equal_to_iris_identify(iris_pvt_url)
  expect_equal_to_iris_identify(iris_pvt_key)
  expect_equal_to_iris_identify(iris_pvt_title)
  expect_equal_to_iris_identify(iris_pvt_ws_feed)
  iris_gs <- identify_ss(iris_pvt_key)
  expect_equal_to_iris_identify(iris_gs)

  ## explicitly provide the correct method
  expect_equal_to_iris_identify(iris_pvt_url, method = "url")
  expect_equal_to_iris_identify(iris_pvt_key, method = "key")
  expect_equal_to_iris_identify(iris_pvt_title, method = "title")
  expect_equal_to_iris_identify(iris_pvt_ws_feed, method = "ws_feed")
  expect_equal_to_iris_identify(iris_gs, method = "ss")

  ## request NO verification
  expect_iris_key <- function(x) {
    expect_equal(identify_ss(x, verify = FALSE)$sheet_key, iris_pvt_key)
  }

  expect_iris_key(iris_pvt_url)
  expect_iris_key(iris_pvt_ws_feed)
  expect_iris_key(iris_pvt_key)
  expect_iris_key(iris_gs)
  ## note this "works" but proclaims the title as the key
  expect_equal(identify_ss(
    iris_pvt_title, verify = FALSE)$sheet_key, iris_pvt_title)

})

test_that("Bad spreadsheet ID throws informative error", {

  ## errors that prevent attempt to identify spreadsheet
  expect_error(identify_ss(4L), "must be character")
  expect_error(identify_ss(c("Gapminder", "Gapminder")), "must be of length 1")

  ## explicit declaration of an invalid method
  expect_error(identify_ss(pts_key, method = "eggplant"), "Error in match.arg")

  ## incompatible choices for method and verify
  expect_error(identify_ss("eggplant", method = "title", verify = FALSE),
               "must look up the title")

  ## errors caused by well-formed input that refers to a nonexistent spreadsheet
  expect_error(identify_ss("spatula"), "doesn't match")

  nonexistent_ws_feed <- sub(iris_pvt_key, "flyingpig", iris_pvt_ws_feed)
  expect_error(register_ss(ws_feed = nonexistent_ws_feed),
               "client error: \\(400\\) Bad Request")
  expect_error(register_ss(nonexistent_ws_feed), "doesn't match")

  nonexistent_url <- sub(iris_pvt_key, "flyingpig", iris_pvt_url)
  expect_error(register_ss(nonexistent_url), "doesn't match")

  nonexistent_key <- "flyingpig"
  expect_error(register_ss(key = nonexistent_key),
               "client error: \\(400\\) Bad Request")

  # error because the title of one worksheet matches the key of another
  expect_error(register_ss(wtf1_key),
               "conflicting matches in multiple identifiers: sheet_title, sheet_key")

  # but everything's ok if we explicitly declare input is a key
  expect_is(register_ss(key = wtf1_key), "googlesheet")

})

test_that("Spreadsheet can be registered via URL, key, title, ws_feed or ss", {

  expect_googlesheet <- function(x) expect_is(x, "googlesheet")

  ## let identify_ss() determine the method
  expect_googlesheet(register_ss(iris_pvt_ws_feed))
  expect_googlesheet(register_ss(iris_pvt_title))
  expect_googlesheet(register_ss(iris_pvt_key))
  expect_googlesheet(register_ss(iris_pvt_url))
  iris_gs <- identify_ss(iris_pvt_key)
  expect_googlesheet(register_ss(iris_gs))

  ## explicitly declare identifier to be key or ws_feed
  expect_googlesheet(register_ss(key = iris_pvt_key))
  expect_googlesheet(register_ss(ws_feed = iris_pvt_ws_feed))

})

test_that("We get correct number and titles of worksheets", {

  ss <- register_ss(ws_feed = gap_ws_feed)
  expect_equal(ss$n_ws, 5L)
  expect_true(all(c("Asia", "Africa", "Americas", "Europe", "Oceania") %in%
                    ss$ws$ws_title))

  })
