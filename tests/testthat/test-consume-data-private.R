context("consume data with private visibility")

## consuming data owned by authorized user, namely gspreadr
ss <- register_ss(ws_feed = iris_pvt_ws_feed)

## tests here are very minimal; more detailed data consumption tests are done
## with public visiblity, i.e. on Sheets authorized user does not own, which
## strikes me as a higher bar

## see test-consume-data-public.R and test-consue-data-tricky.R

test_that("We can get all data from the list feed (pvt)", {

  expect_equal_to_reference(get_via_lf(ss), "iris_pvt_get_via_lf.rds")

})

test_that("We can get all data from the cell feed (pvt)", {

  expect_equal_to_reference(get_via_cf(ss), "iris_pvt_get_via_cf.rds")

})

test_that("We can get all data from the exportcsv link (pvt)", {

  dat1 <- get_via_csv(ss)
  names(dat1) <-  dat1 %>% names() %>% tolower()
  expect_equal_to_reference(dat1, "iris_pvt_get_via_lf.rds")

})
