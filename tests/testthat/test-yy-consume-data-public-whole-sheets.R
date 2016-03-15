context("consume data with public visibility, whole sheets")

test_that("gs_read() result not changing", {
  expect_equal_to_reference(gs_read(gs_ff(), verbose = FALSE),
                            "for_reference/ff.rds")
})

test_that("gs_read(), forcing cell feed, result not changing, matches gs_read()", {
  expect_equal_to_reference(gs_read(gs_ff(), range = "A1:F6", verbose = FALSE),
                            "for_reference/ff.rds")
})

test_that("gs_read_csv() result not changing, matches gs_read()", {
  expect_equal_to_reference(gs_read_csv(gs_ff(), verbose = FALSE),
                            "for_reference/ff.rds")
})

test_that("gs_read_listfeed() result not changing, matches gs_read()", {
  expect_equal_to_reference(gs_read_listfeed(gs_ff(), verbose = FALSE),
                            "for_reference/ff.rds")
})

test_that("gs_read_cellfeed() result not changing", {
  expect_equal_to_reference(gs_read_cellfeed(gs_ff(), verbose = FALSE),
                            "for_reference/ff_cellfeed.rds")
})

test_that("gs_read* matches readr::read_csv()", {
  tfile <- tempfile(pattern = "gs-test-formula-formatting", fileext = ".csv")
  tfile <- gs_download(gs_ff(), to = tfile, overwrite = TRUE)
  expect_equal_to_reference(readr::read_csv(tfile), "for_reference/ff.rds")
})

test_that("We can reshape data from the cell feed", {
  oceania <- gs_gap() %>%
    gs_read_cellfeed(ws = "Oceania", verbose = FALSE)
  expect_true(all(names(oceania) %in%
                    c("cell", "cell_alt", "row", "col",
                      "value", "input_value", "numeric_value")))

  y <- gs_reshape_cellfeed(oceania)
  expect_equal(dim(y), c(24L, 6L))
  expect_is(oceania$cell, "character")
  expect_is(oceania$row, "integer")
  expect_is(oceania$col, "integer")
  expect_is(oceania$value, "character")
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
  expect_identical(dim(tmp), c(0L, 7L))
})

test_that("We can't access sheet that is 'public on the web' (pub)", {
  expect_error(gotcha_key %>% gs_key(lookup = FALSE), "content-type")
})
