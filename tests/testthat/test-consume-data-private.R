context("consume data with private visibility")

activate_test_token()

## consuming data owned by authorized user, namely gspreadr
ss <- gs_ws_feed(iris_pvt_ws_feed, verbose = FALSE)

## tests here are very minimal; more detailed data consumption tests are done
## with public visiblity, i.e. on Sheets authorized user does not own, which
## strikes me as a higher bar

## see test-consume-data-public.R and test-consue-data-tricky.R

test_that("We can get all data from the list feed (pvt)", {

  expect_equal_to_reference(gs_read_listfeed(ss),
                            "for_reference/iris_pvt_gs_read_listfeed.rds")

})

test_that("We can get all data from the cell feed (pvt)", {

  expect_equal_to_reference(gs_read_cellfeed(ss),
                            "for_reference/iris_pvt_gs_read_cellfeed.rds")

})

test_that("We can get all data from the exportcsv link (pvt)", {

  dat1 <- gs_read_csv(ss)
  names(dat1) <-  dat1 %>% names() %>% tolower()
  expect_equal_to_reference(dat1, "for_reference/iris_pvt_gs_read_listfeed.rds")

})

gs_deauth(verbose = FALSE)
