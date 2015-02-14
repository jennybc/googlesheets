ss <- register(pts_ws_feed)

test_that("We can get data from the list feed", {
  
  expect_equal_to_reference(get_via_lf(ss), "pts_sheet1_get_via_lf.rds")

})

test_that("We can get data from the cell feed", {
  
  expect_equal_to_reference(get_via_cf(ss), "pts_sheet1_get_via_cf.rds")
  
})

test_that("Validation is in force for row / columns limits in the cell feed", {
  
  expect_error(get_via_cf(ss, min_row = "eggplant"), "Invalid input")
  expect_error(get_via_cf(ss, max_col = factor(1)), "Invalid input")
  expect_error(get_via_cf(ss, max_row = 1:3), "Invalid input")
  expect_error(get_via_cf(ss, min_col = -100), "Invalid input")
  
  expect_error(get_via_cf(ss, min_row = 5, max_row = 3),
               "less than or equal to")
  expect_error(get_via_cf(ss, min_col = 5, max_col = 3),
               "less than or equal to")
  ## next tests assume default worksheet extent of 1000 rows x 26 columns
  expect_error(get_via_cf(ss, min_row = 1001), "less than or equal to")
  expect_error(get_via_cf(ss, max_row = 1001), "less than or equal to")
  expect_error(get_via_cf(ss, min_col = 27), "less than or equal to")
  expect_error(get_via_cf(ss, max_col = 27), "less than or equal to")
  
})