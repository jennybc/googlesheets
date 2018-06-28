context("consume data with private visibility")

activate_test_token()

## consuming data owned by authorized user, namely gspreadr
ss <- gs_ws_feed(iris_pvt_ws_feed, verbose = FALSE)

## tests here are very minimal; more detailed data consumption tests are done
## with public visiblity, i.e. on Sheets authorized user does not own, which
## strikes me as a higher bar

test_that("Default result is not changing (pvt)", {
  expect_equal_to_reference(gs_read(ss, verbose = FALSE),
                            test_path("for_reference/iris_pvt.rds"))
})

test_that("Explicit read via csv matches default result (pvt)", {
  expect_equal_to_reference(gs_read_csv(ss, verbose = FALSE),
                            test_path("for_reference/iris_pvt.rds"))
})

test_that("Explicit read via list feed matches default result (pvt)", {
  expect_equal_to_reference(gs_read_listfeed(ss, verbose = FALSE),
                            test_path("for_reference/iris_pvt.rds"))
})

test_that("Forced read via cell feed matches default result (pvt)", {
  expect_equal_to_reference(gs_read(ss, range = "A1:E7", verbose = FALSE),
                            test_path("for_reference/iris_pvt.rds"))
})

gs_deauth(verbose = FALSE)
