context("consume data")

ss <- register_ss(ws_feed = pts_ws_feed)

test_that("We can get data from the list feed", {
  
  expect_equal_to_reference(get_via_lf(ss), "pts_sheet1_get_via_lf.rds")

})

test_that("We can get data from the cell feed", {
  
  expect_equal_to_reference(get_via_cf(ss), "pts_sheet1_get_via_cf.rds")
  
})

test_that("We can reshape data from the cell feed", {
  
  diabolical <- get_via_cf(ss, "diabolical_column_names")
  expect_true(all(names(diabolical) %in%
                    c("cell", "cell_alt", "row", "col", "cell_text")))
  
  y <- reshape_cf(diabolical)
  expect_equal(nrow(y), 6L)
  expect_equal(ncol(y), 6L)
  expect_is(diabolical$cell, "character")
  expect_is(diabolical$row, "integer")
  expect_is(diabolical$col, "integer")
  expect_is(diabolical$cell_text, "character")
  expect_equal(names(y), c("id", "year", "X4.3", "continent", "lifeExp", "C6"))
  
  z <- reshape_cf(diabolical, header = FALSE)
  expect_equal(nrow(z), 7L)
  expect_equal(ncol(z), 6L)
  expect_true(all(grepl("^X[0-9]+", names(z))))
  expect_equal(unique(sapply(z[c(1, 2, 4, 5)], class)), "character")
  expect_equal(unique(sapply(z[c(3, 6)], class)), "numeric")
  expect_equal(sum(is.na(z)), 5L)
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