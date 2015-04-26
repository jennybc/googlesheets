context("consume data with public visibility, whole sheets")

## consuming data owned by someone else, namely rpackagetest
ss <- register_ss(ws_feed = gap_ws_feed)

test_that("We can get all data from the list feed (pub)", {

  expect_equal_to_reference(get_via_lf(ss, ws = 5), "gap_sheet5_get_via_lf.rds")

})

test_that("We can get all data from the cell feed (pub)", {

  expect_equal_to_reference(get_via_cf(ss, ws = 5), "gap_sheet5_get_via_cf.rds")

})

test_that("We can get all data from the exportcsv link (pub)", {

  dat1 <- get_via_csv(ss, ws = 5)
  names(dat1) <-  dat1 %>% names() %>% tolower()
  expect_equal_to_reference(dat1, "gap_sheet5_get_via_lf.rds")

})

test_that("We can reshape data from the cell feed", {

  oceania <- ss %>% get_via_cf(ws = "Oceania")
  expect_true(all(names(oceania) %in%
                    c("cell", "cell_alt", "row", "col", "cell_text")))

  y <- reshape_cf(oceania)
  expect_equal(dim(y), c(24L, 6L))
  expect_is(oceania$cell, "character")
  expect_is(oceania$row, "integer")
  expect_is(oceania$col, "integer")
  expect_is(oceania$cell_text, "character")
  expect_equal(names(y),
               c("country", "continent", "year", "lifeExp", "pop", "gdpPercap"))

  z <- reshape_cf(oceania, header = FALSE)
  expect_equal(dim(z), c(25L, 6L))
  expect_true(all(grepl("^X[0-9]+", names(z))))
  expect_equal(unique(sapply(z, class)), "character")

})

