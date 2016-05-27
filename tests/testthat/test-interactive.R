context("interactive things")

test_that("gs_browse is inert", {
  if (interactive()) skip("interactive() is TRUE")
  ss <- gs_mini_gap()
  expect_silent(ret <- gs_browse(ss))
  expect_identical(ret, ss)
  expect_silent(ret <- gs_browse(ss, ws = 3))
  expect_identical(ret, ss)
  expect_silent(ret <- gs_browse(ss, ws = "Europe"))
  expect_identical(ret, ss)
})
