context("suspend authorization")

## remove the google token, to make 100% sure the remaining tests run w/o auth

## now that we authorize explicitly and locally throughout our tests, this is
## arguably paranoid and overkill

## this filename is deliberate w/r/t alphabetical order, so don't change it
## lightly! it's no coincidence that "axe" starts with "A"
suppressMessages(gs_deauth(verbose = FALSE))

test_that("Token is NOT available, no .httr-oauth file in wd", {

  expect_false(token_available())
  expect_false(file.exists(".httr-oauth"))

})

test_that("We can NOT register a pvt sheet owned by rpackagetest", {

  if(interactive()) {
    mess <- paste("Skipping the attempt to access private third party",
                  "sheet w/o authorization, because session is interactive",
                  "and would launch browser-based authentication.")
    skip(mess)
  }
  expect_error(gs_ws_feed(cars_pvt_ws_feed, lookup = FALSE, verbose = FALSE))

})
