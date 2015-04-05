context("register sheets")

test_that("Spreadsheets visible to authenticated user can be listed", {
  ss_list <- list_sheets()
  expect_is(ss_list, "tbl_df")
  expect_more_than(nrow(ss_list), 0)
})

test_that("Spreadsheet can be ID'd via URL, key, title, ws_feed or ss", {
  
  ## let identify_ss() determine the method
  expect_equal_to_reference(identify_ss(pts_url), "pts_identify_ss.rds")
  expect_equal_to_reference(identify_ss(pts_key), "pts_identify_ss.rds")
  expect_equal_to_reference(identify_ss(pts_title), "pts_identify_ss.rds")
  expect_equal_to_reference(identify_ss(pts_ws_feed), "pts_identify_ss.rds")
  pts_ss <- identify_ss(pts_key)
  expect_equal_to_reference(identify_ss(pts_ss), "pts_identify_ss.rds")
  
  ## explicitly provide the correct method
  expect_equal_to_reference(identify_ss(pts_url, method = "url"),
                            "pts_identify_ss.rds")
  expect_equal_to_reference(identify_ss(pts_key, method = "key"),
                            "pts_identify_ss.rds")
  expect_equal_to_reference(identify_ss(pts_title, method = "title"),
                            "pts_identify_ss.rds")
  expect_equal_to_reference(identify_ss(pts_ws_feed, method = "ws_feed"),
                            "pts_identify_ss.rds")
  expect_equal_to_reference(identify_ss(pts_ss, method = "ss"),
                            "pts_identify_ss.rds")
  
  ## request NO verification
  expect_equal(identify_ss(pts_url, verify = FALSE)$sheet_key, pts_key)
  expect_equal(identify_ss(pts_ws_feed, verify = FALSE)$sheet_key, pts_key)
  expect_equal(identify_ss(pts_key, verify = FALSE)$sheet_key, pts_key)
  expect_equal(identify_ss(pts_ss, verify = FALSE)$sheet_key, pts_key)
  ## note this "works" but produces an incorrect key
  expect_equal(identify_ss(pts_title, verify = FALSE)$sheet_key, pts_title)
  
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
  
  nonexistent_ws_feed <- sub(pts_key, "flyingpig", pts_ws_feed)
  expect_error(register_ss(ws_feed = nonexistent_ws_feed),
               "client error: \\(400\\) Bad Request")
  expect_error(register_ss(nonexistent_ws_feed), "doesn't match")

  nonexistent_url <- sub(pts_key, "flyingpig", pts_url)
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

  ## let identify_ss() determine the method
  expect_is(register_ss(pts_ws_feed), "googlesheet")
  expect_is(register_ss(pts_title), "googlesheet")
  expect_is(register_ss(pts_key), "googlesheet")
  expect_is(register_ss(pts_url), "googlesheet")
  pts_ss <- identify_ss(pts_key)
  expect_is(register_ss(pts_ss), "googlesheet")

  ## explicitly declare identifier to be key or ws_feed
  expect_is(register_ss(key = pts_key), "googlesheet")
  expect_is(register_ss(ws_feed = pts_ws_feed), "googlesheet")

})

test_that("We get correct number and titles of worksheets", {

  ss <- register_ss(ws_feed = pts_ws_feed)
  expect_more_than(ss$n_ws, 6L)
  expect_true(all(c("Asia", "Africa", "Americas", "Europe", "Oceania") %in%
                    ss$ws$ws_title))

  })

## TO DO: test re: visibility?
## TO DO: more tests about the stuff inside a registered spreadsheet?
