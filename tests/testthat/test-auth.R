context("authorization")

test_that("No token is in force",
          expect_false(token_available(verbose = FALSE)))

test_that("No .httr-oauth* file is here", {
  (fls <- list.files(pattern = "^\\.httr-oauth", all.files = TRUE))
  expect_true(length(fls) == 0)
})

## PUT THE MAIN TESTING TOKEN INTO FORCE via .rds file
activate_test_token()

test_that("Testing token is in force", expect_true(token_available()))

test_that("User info is available and as expected", {
  user_info <- gd_user()
  expect_is(user_info, "list")
  expect_identical(user_info$displayName, "google sheets")
  expect_identical(user_info$emailAddress, "gspreadr@gmail.com")
  expect_is(user_info$date, "POSIXct")
  expect_true(user_info$token_valid)
  ## don't be surprised when this regex breaks; I have no idea what's possible
  expect_match(user_info[c('peek_acc', 'peek_ref')], "[/\\.\\w-]+", all = TRUE)
})

test_that("Token peek works", {
  ui <- gd_user()
  ttt <- readRDS("googlesheets_token.rds")
  expect_identical(substr(ttt$credentials$access_token, 1, 5),
                   substr(ui$peek_acc, 1, 5))
  expect_identical(substr(ttt$credentials$refresh_token, 1, 5),
                   substr(ui$peek_ref, 1, 5))

})

## SUSPEND THE MAIN TESTING TOKEN
gs_deauth(verbose = FALSE)

## PUT THE MAIN TESTING TOKEN INTO FORCE via R object
ttt <- readRDS("googlesheets_token.rds")
uuu <- suppressMessages(gs_auth(token = ttt))

test_that("Testing token is in force, again", expect_true(token_available()))
test_that("Behavior is same when token from obj or rds",
          expect_identical(ttt, uuu))

## SUSPEND THE MAIN TESTING TOKEN again
gs_deauth(verbose = FALSE)

test_that("No token is in force, again",
          expect_false(token_available(verbose = FALSE)))

test_that("No .httr-oauth* file is here, again", {
  (fls <- list.files(pattern = "^\\.httr-oauth", all.files = TRUE))
  expect_true(length(fls) == 0)
})

test_that("Nonsense tokens generate error", {
  expect_error(gs_auth(token = iris))
  expect_error(gs_auth(token = "i-dont-exist.rds"))
})
