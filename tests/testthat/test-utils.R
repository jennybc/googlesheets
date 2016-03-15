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
