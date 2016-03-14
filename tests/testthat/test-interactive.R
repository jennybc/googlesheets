context("interactive things")

test_that("gs_browse is inert", {
  if (interactive()) skip("interactive() is TRUE")
  expect_silent(gs_browse(gs_mini_gap()))
  expect_silent(gs_browse(gs_mini_gap(), ws = 3))
  expect_silent(gs_browse(gs_mini_gap(), ws = "Europe"))
})
