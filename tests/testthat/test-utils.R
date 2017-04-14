context("utility functions")

gap <- gs_gap()

test_that("We can get list of worksheets in a spreadsheet", {

  ws_listing <- gap %>% gs_ws_ls()
  expect_true(all(c('Asia', 'Africa', 'Americas', 'Europe', 'Oceania') %in%
                    ws_listing))

})

test_that("We can obtain worksheet info from a registered spreadsheet", {

  ## retrieve by worksheet title
  africa <- gs_ws(gap, "Africa")
  expect_equal(africa$ws_title, "Africa")
  expect_equal(africa$row_extent, 625L)

  ## retrieve by positive integer
  europe <- gs_ws(gap, 4)
  expect_equal(europe$ws_title, "Europe")
  expect_equal(europe$col_extent, 6L)

  ## doubles get truncated, i.e. 1.3 --> 1
  asia <- gs_ws(gap, 3.3)
  expect_equal(asia$ws_title, "Asia")

})

test_that("We throw error for bad worksheet request", {

  expect_error(gs_ws(gap, -3))
  expect_error(gs_ws(gap, factor(1)))
  expect_error(gs_ws(gap, LETTERS))

  expect_error(gs_ws(gap, "Mars"), "not found")
  expect_error(gs_ws(gap, 100L), "only contains")

})

test_that("We can a extract a key from a URL", {

  # new style URL
  expect_equal(extract_key_from_url(pts_url), pts_key)

  # worksheets feed
  expect_equal(extract_key_from_url(pts_ws_feed), pts_key)

  # vectorized
  expect_equal(extract_key_from_url(c(pts_url, pts_ws_feed)),
               c(pts_key, pts_key))

  # Google Apps for Work, see issue #131
  expect_identical(extract_key_from_url("https://docs.google.com/a/example.com/spreadsheets/d/KEY/pubhtml"), "KEY")

})

test_that("We can a extract a key from an old URL", {

  # old style URL
  expect_equal(extract_key_from_url(old_url), old_alt_key)

})

test_that("We can form URLs", {

  expect_identical(construct_url_from_key(pts_key), pts_url)
  expect_identical(construct_ws_feed_from_key(pts_key, visibility = "public"),
                   pts_ws_feed)

  # vectorized
  expect_identical(construct_url_from_key(c(pts_key, gs_gap_key())),
                   c(pts_url, gs_gap_url()))
  expect_equal(construct_ws_feed_from_key(c(pts_key, gs_gap_key()),
                                          visibility = "public"),
               c(pts_ws_feed, gs_gap_ws_feed()))

})

test_that("We can form query string from list", {

  expect_equal(gsv4_form_query_string(standard_params=list(fields="sheets.properties"), other="o"), 
               "?fields=sheets.properties&other=o")
  expect_equal(gsv4_form_query_string(a=1, b=TRUE, x="x"), "?a=1&b=true&x=x") 
  expect_equal(gsv4_form_query_string(), "")

})

# requires a spreadsheet to work
# test_that("We can convert anchor to GridCoordinate", {
#   
#   just_range <- gsv4_anchor_to_grid_coordinate(gap, anchor="A1")
#   
#   expect_s3_class(just_range, 'GridCoordinate')
#   expect_named(just_range, c('sheetId', 
#                                 'rowIndex', 
#                                 'columnIndex'))
#   expect_true(all(lapply(just_range, is.integer)))
#   
#   range_and_ws <- gsv4_anchor_to_grid_coordinate(gap, ws=1, anchor="A1")
#   expect_s3_class(range_and_ws, 'GridCoordinate')
#   expect_named(range_and_ws, c('sheetId', 
#                                 'rowIndex', 
#                                 'columnIndex'))
#   expect_true(all(lapply(range_and_ws, is.integer)))
#   
#   range_and_ws_name <- gsv4_anchor_to_grid_coordinate(gap, ws="Americas", anchor="A1")
#   expect_s3_class(range_and_ws_name, 'GridCoordinate')
#   expect_named(range_and_ws_name, c('sheetId', 
#                                 'rowIndex', 
#                                 'columnIndex'))
#   expect_true(all(lapply(range_and_ws_name, is.integer)))
#   
#   range_and_name_together <- gsv4_anchor_to_grid_coordinate(gap, anchor="Americas!A1")
#   expect_s3_class(range_and_name_together, 'GridCoordinate')
#   expect_named(range_and_name_together, c('sheetId', 
#                                 'rowIndex', 
#                                 'columnIndex'))
#   expect_true(all(lapply(range_and_name_together, is.integer)))
# })

# requires a spreadsheet to work
# test_that("We can convert range to GridRange", {
#   
#   # requires a spreadsheet object to get the sheetId
#   rows_and_cols <- gsv4_limits_to_grid_range(lim = cell_limits(c(1, 3), 
#                                                                c(1, 5)))
#   expect_s3_class(rows_and_cols, 'GridRange')
#   expect_named(rows_and_cols, c('sheetId', 
#                                 'startRowIndex', 'endRowIndex', 
#                                 'startColumnIndex', 'endColumnIndex'))
#   expect_true(all(lapply(rows_and_cols, is.integer)))
#   
#   missing_row_or_col <- gsv4_limits_to_grid_range(lim = cell_limits(c(NA, 3), 
#                                                                     c(3, NA)))
#   expect_s3_class(missing_row_or_col, 'GridRange')
#   expect_named(missing_row_or_col, c('sheetId', 
#                                 'endRowIndex', 
#                                 'startColumnIndex'))
#   expect_true(all(lapply(missing_row_or_col, is.integer)))
#   
#   only_sheet <- gsv4_limits_to_grid_range(lim=cell_limits(sheet = 'Sheet1'))
#   expect_s3_class(only_sheet, 'GridRange')
#   expect_named(only_sheet, c('sheetId'))
#   expect_true(all(lapply(only_sheet, is.integer)))
# })

test_that("We can prep values for V4 API", {
  my_values <- gsv4_prep_values(iris[5,], col_names=FALSE)
  expect_is(my_values, 'matrix')
  expect_equal(dim(my_values), c(1, 5))
  
  my_values_w_header <- gsv4_prep_values(iris[5,], col_names=TRUE)
  expect_is(my_values_w_header, 'matrix')
  expect_equal(dim(my_values_w_header), c(2, 5))
  expect_true(all(apply(my_values_w_header, c(1,2), is.character)))
  
  my_values_matrix <- gsv4_prep_values(as.matrix(iris[5,]))
  expect_is(my_values_matrix, 'matrix')
  expect_equal(dim(my_values_matrix), c(2, 5))
  expect_true(all(apply(my_values_matrix, c(1,2), is.character)))
})

test_that("We can parse values from V4 API", {
  
  api_values <- structure(list(range = "Africa!A3:C5", 
                 majorDimension = "ROWS", 
                 values = list(list("Algeria", "Africa", "1957"), 
                               list("Algeria", "Africa", "1962"), 
                               list("Algeria", "Africa", "1967"))), 
    .Names = c("range", "majorDimension", "values"))
  
  my_dat <- gsv4_parse_values(reply$values, col_names=FALSE)
  expect_is(my_dat, 'data.frame')
  expect_equal(dim(my_dat), c(3,3))
  expect_named(my_dat, c('V1', 'V2', 'V3'))
})
