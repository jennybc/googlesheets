context("interactive things")

test_that("gs_browse is inert", {
  if (interactive()) skip("interactive() is TRUE")
  ss <- gs_ws_feed(mini_gap_ws_feed, lookup = FALSE)
  expect_silent(gs_browse(ss))
  expect_silent(gs_browse(ss, ws = 3))
  expect_silent(gs_browse(ss, ws = "Europe"))
})
