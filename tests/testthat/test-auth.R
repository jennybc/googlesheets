context("authorization")

test_that("Cached credentials are in force", {

  expect_true(token_exists())

})

test_that("User info is accessible and printed", {

  expect_message(user_info <- gs_user(), "Access token is valid.")
  expect_is(user_info, "list")
  expect_identical(user_info$displayName, "google sheets")
  expect_identical(user_info$emailAddress, "gspreadr@gmail.com")
  expect_is(user_info$auth_date, "POSIXct")
  expect_is(user_info$exp_date, "POSIXct")

})
