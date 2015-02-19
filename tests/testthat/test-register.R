context("register a spreadsheet")

test_that("Spreadsheets visible to authenticated user can be listed", {
  ss_list <- list_sheets()
  expect_is(ss_list, "tbl_df")
  expect_more_than(nrow(ss_list), 0)
})

test_that("Spreadsheet info can be summoned with url, key, title, or ws_feed", {
  
  expect_equal_to_reference(identify_sheet(pts_url), "pts_identify_sheet.rds")
  expect_equal_to_reference(identify_sheet(pts_key), "pts_identify_sheet.rds")
  expect_equal_to_reference(identify_sheet(pts_title), "pts_identify_sheet.rds")
  expect_equal_to_reference(identify_sheet(pts_ws_feed), "pts_identify_sheet.rds")
})

test_that("Spreadsheet can be registered via ws_feed", {
  expect_is(register(pts_ws_feed), "spreadsheet")
})

test_that("Bad spreadsheet specification throws informative error", {
  
  ## errors that prevent attempt to identify spreadsheet
  expect_error(identify_sheet(4L), "must be character")
  expect_error(identify_sheet(c("Gapminder", "Gapminder")), "must be of length 1")
  
  ## errors caused by well-formed input that refers to a nonexistent spreadsheet
  expect_error(identify_sheet("spatula"), "doesn't match")
  
  nonexistent_ws_feed <- sub(pts_key, "flyingpig", pts_ws_feed)
  expect_error(register(ws_feed = nonexistent_ws_feed),
               "client error: \\(400\\) Bad Request")
  expect_error(register(nonexistent_ws_feed), "doesn't match")

  nonexistent_url <- sub(pts_key, "flyingpig", pts_url)
  expect_error(register(nonexistent_url), "doesn't match")
  
  nonexistent_key <- "flyingpig"
  expect_error(register(key = nonexistent_key),
               "client error: \\(400\\) Bad Request")
  
  # error because the title of one worksheet matches the key of another
  expect_error(register(wtf1_key),
               "conflicting matches in multiple identifiers: sheet_title, sheet_key")
  # but everything's ok if we declare input is a key
  expect_is(register(key = wtf1_key), "spreadsheet")
  
})

test_that("We get correct number and titles of worksheets", {
  
  ss <- register(ws_feed = pts_ws_feed)
  expect_more_than(ss$n_ws, 6L)
  expect_true(all(c("Asia", "Africa", "Americas", "Europe", "Oceania") %in%
                    ss$ws$ws_title))
  })

## TO DO: test re: visibility?
## TO DO: more tests about the stuff inside a registered spreadsheet?
