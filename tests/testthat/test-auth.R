context("authorization")

test_that("No token is in force",
          expect_false(token_available(verbose = FALSE)))

test_that("No .httr-oauth* file is here", {
  fls <- list.files(
    path = test_path(),
    pattern = "^\\.httr-oauth",
    all.files = TRUE
  )
  expect_length(fls, 0)
})

## PUT THE MAIN TESTING TOKEN INTO FORCE via .rds file
activate_test_token()

test_that("Testing token is in force", expect_true(token_available()))

test_that("User info is available and as expected", {
  user_info <- gd_user()
  expect_is(user_info, "drive_user")
  expect_is(user_info, "list")
  expect_identical(user_info$user$displayName, "google sheets")
  expect_identical(user_info$user$emailAddress, "gspreadr@gmail.com")
  expect_is(user_info$date, "POSIXct")
})

test_that("Token printing works", {
  out <- capture_output(gd_token()) %>% strsplit("\n")
  out <- out[[1]]
  ttt <- readRDS(test_path("googlesheets_token.rds"))
  ## don't have an expectation about the access token! it changes!
  #at <- ttt$credentials$access_token
  rt <- ttt$credentials$refresh_token
  last_five <- function(x) substr(x, start = nchar(x) - 4, stop = nchar(x))
  expect_identical(last_five(rt),
                   last_five(grep("peek at refresh", out, value = TRUE)))
})

## SUSPEND THE MAIN TESTING TOKEN
gs_deauth(verbose = FALSE)

## PUT THE MAIN TESTING TOKEN INTO FORCE via R object
ttt <- readRDS(test_path("googlesheets_token.rds"))
uuu <- suppressMessages(gs_auth(token = ttt))

test_that("Testing token is in force, again", expect_true(token_available()))
test_that("Behavior is same when token from obj or rds",
          expect_identical(ttt, uuu))

## SUSPEND THE MAIN TESTING TOKEN again
gs_deauth(verbose = FALSE)

test_that("No token is in force, again",
          expect_false(token_available(verbose = FALSE)))

test_that("No .httr-oauth* file is here", {
  fls <- list.files(
    path = test_path(),
    pattern = "^\\.httr-oauth",
    all.files = TRUE
  )
  expect_length(fls, 0)
})

test_that("Nonsense tokens generate error", {
  expect_error(gs_auth(token = iris))
  expect_error(gs_auth(token = "i-dont-exist.rds"))
})
