context("authorization")

activate_test_token()

test_that("Cached credentials are in force", {

  expect_true(token_exists())

})

test_that("User info is accessible and printed", {

  expect_message(user_info <- gs_user(), "access token: valid")
  expect_is(user_info, "list")
  expect_identical(user_info$displayName, "google sheets")
  expect_identical(user_info$emailAddress, "gspreadr@gmail.com")
  expect_is(user_info$date, "POSIXct")

})

gs_auth_suspend(verbose = FALSE)

test_that("Authorization is NOT in force", {

  expect_false(token_exists())

})
