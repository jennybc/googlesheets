context("consume data with public visibility, whole sheets")

## consuming data owned by someone else, namely rpackagetest
ss <- gs_ws_feed(GAP_WS_FEED, lookup = FALSE, verbose = FALSE)

test_that("Default result is not changing (pub)", {
  expect_equal_to_reference(gs_read(ss, ws = 5, verbose = FALSE),
                            "for_reference/gap_sheet5.rds")
})

test_that("Read via csv matches default result link (pub)", {
  expect_equal_to_reference(gs_read_csv(ss, ws = 5, verbose = FALSE),
                            "for_reference/gap_sheet5.rds")
})

test_that("Read via list feed matches default results (pub)", {
  expect_equal_to_reference(gs_read_listfeed(ss, ws = 5, verbose = FALSE),
                            "for_reference/gap_sheet5.rds")
})

test_that("Read via cellfeed is not changing (pub)", {
  expect_equal_to_reference(gs_read_cellfeed(ss, ws = 5, verbose = FALSE),
                            "for_reference/gap_sheet5_cellfeed.rds")
})

test_that("We can reshape data from the cell feed", {
  oceania <- ss %>% gs_read_cellfeed(ws = "Oceania", verbose = FALSE)
  expect_true(all(names(oceania) %in%
                    c("cell", "cell_alt", "row", "col", "cell_text")))

  y <- gs_reshape_cellfeed(oceania)
  expect_equal(dim(y), c(24L, 6L))
  expect_is(oceania$cell, "character")
  expect_is(oceania$row, "integer")
  expect_is(oceania$col, "integer")
  expect_is(oceania$cell_text, "character")
  expect_equal(names(y),
               c("country", "continent", "year", "lifeExp", "pop", "gdpPercap"))

  z <- gs_reshape_cellfeed(oceania, col_names = FALSE)
  expect_equal(dim(z), c(25L, 6L))
  expect_true(all(grepl("^X[0-9]+", names(z))))
  expect_equal(unique(sapply(z, class)), "character")

})

test_that("We get no error from gs_read on an empty sheet (pub)", {
  pts_ss <- pts_key %>% gs_key(lookup = FALSE)
  expect_is(tmp <- pts_ss %>% gs_read(ws = "empty"), "data.frame")
  expect_identical(dim(tmp), c(0L, 0L))
})

test_that("We get no error from gs_read_csv on an empty sheet (pub)", {
  pts_ss <- pts_key %>% gs_key(lookup = FALSE)
  expect_is(tmp <- pts_ss %>% gs_read_csv(ws = "empty"), "data.frame")
  expect_identical(dim(tmp), c(0L, 0L))
})

test_that("We get no error from gs_read_listfeed on an empty sheet (pub)", {
  pts_ss <- pts_key %>% gs_key(lookup = FALSE)
  expect_is(tmp <- pts_ss %>% gs_read_listfeed(ws = "empty"), "data.frame")
  expect_identical(dim(tmp), c(0L, 0L))
})

test_that("We get no error from gs_read_cellfeed on an empty sheet (pub)", {
  pts_ss <- pts_key %>% gs_key(lookup = FALSE)
  expect_is(tmp <- pts_ss %>% gs_read_cellfeed(ws = "empty"), "data.frame")
  expect_identical(dim(tmp), c(0L, 5L))
})

test_that("We can't access sheet that is 'public on the web' (pub)", {
  expect_error(gotcha_key %>% gs_key(lookup = FALSE), "content-type")
})
