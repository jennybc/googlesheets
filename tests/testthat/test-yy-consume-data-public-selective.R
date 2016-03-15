context("consume data with public visibility, selectively")

## consuming data owned by someone else, namely rpackagetest
gap <- gs_gap()

test_that("We can get data from specific cells using limits", {

  ## fully specify limits
  foo <- gap %>%
    gs_read_cellfeed(ws = 5, range = cell_limits(c(3, 1), c(5, 3)),
                     verbose = FALSE)
  expect_equal(foo$cell, paste0(LETTERS[1:3], rep(3:5, each = 3)))

  ## partially specified limits
  foo <- gap %>%
    gs_read_cellfeed(ws = "Oceania", range = cell_limits(c(2, 4), c(NA, 4)),
                     verbose = FALSE)
  expect_true(all(grepl("^D", foo$cell)))

  ## partially specified limits
  foo <- gap %>%
    gs_read_cellfeed(ws = "Oceania", range = cell_limits(lr = c(NA, 3)),
                     verbose = FALSE)
  expect_true(all(grepl("^[ABC][0-9]+$", foo$cell)))

})

test_that("We can get data from specific cells using rows and columns", {

  foo <- gap %>% gs_read_cellfeed(ws = "Africa", range = cell_rows(2:3),
                                 verbose = FALSE)
  expect_true(all(foo$row %in% 2:3))

  foo <- gap %>% gs_read_cellfeed(ws = "Africa", range = cell_rows(1),
                                 verbose = FALSE)
  expect_true(all(foo$row == 1))

  foo <- gap %>% gs_read_cellfeed(ws = "Oceania", range = cell_cols(3:6),
                                 verbose = FALSE)
  expect_true(all(foo$col %in% 3:6))

  foo <- gap %>% gs_read_cellfeed(ws = "Oceania", range = cell_cols(4),
                                 verbose = FALSE)
  expect_true(all(foo$col == 4))

})

test_that("We can get data from specific cells using a range", {

  foo <- gap %>%
    gs_read_cellfeed(ws = "Europe", range = "B3:C7", verbose = FALSE)
  expect_is(foo, "tbl_df")
  expect_true(all(foo$col %in% 2:3))
  expect_true(all(foo$row %in% 3:7))

  foo <- gap %>%
    gs_read_cellfeed(ws = "Europe", range = "R3C2:R7C3", verbose = FALSE)
  expect_is(foo, "tbl_df")
  expect_true(all(foo$col %in% 2:3))
  expect_true(all(foo$row %in% 3:7))

  foo <- gap %>% gs_read_cellfeed(ws = "Europe", range = "C4", verbose = FALSE)
  expect_is(foo, "tbl_df")
  expect_equal(foo$col, 3)
  expect_equal(foo$row, 4)

  foo <- gap %>% gs_read_cellfeed(ws = "Europe", range = "R4C3", verbose = FALSE)
  expect_is(foo, "tbl_df")
  expect_equal(foo$col, 3)
  expect_equal(foo$row, 4)

})

test_that("We decline to reshape data if there is none", {

  foo <- gap %>%
    gs_read_cellfeed(ws = "Oceania", range = cell_rows(1), verbose = FALSE)
  expect_message(tmp <- foo %>% gs_reshape_cellfeed(), "No data to reshape!")
  expect_identical(dim(tmp), rep(0L, 2))

})

test_that("We can simplify data from the cell feed", {

  foo <- gap %>%
    gs_read_cellfeed(ws = "Africa", range = cell_rows(2:3), verbose = FALSE)
  expect_equal_to_reference(foo %>% gs_simplify_cellfeed(),
                            "for_reference/gap_africa_simplify_A1.rds")
  expect_equal_to_reference(
    foo %>% gs_simplify_cellfeed(notation = "R1C1"),
    "for_reference/gap_africa_simplify_R1C1.rds"
    )

  foo <- gap %>%
    gs_read_cellfeed(ws = "Oceania", range = cell_cols(3), verbose = FALSE)
  foo_simple <- foo %>% gs_simplify_cellfeed()
  expect_equivalent(foo_simple, rep(seq(from = 1952, to = 2007, by = 5), 2))
  expect_equal(names(foo_simple), paste0("C", 1:24 + 1))

  foo_simple2 <- foo %>% gs_simplify_cellfeed(col_names = FALSE)
  expect_is(foo_simple2, "character")

  foo_simple3 <- foo %>% gs_simplify_cellfeed(col_names = TRUE)
  expect_is(foo_simple3, "integer")

  foo_simple4 <- foo %>% gs_simplify_cellfeed(convert = FALSE)
  expect_equivalent(foo_simple4,
                    rep(seq(from = 1952, to = 2007, by = 5), 2) %>%
                      as.character())

  yo <- gap %>%
    gs_read_cellfeed(ws = "Oceania", range = cell_cols(3), verbose = FALSE)
  yo_simple <- yo %>% gs_simplify_cellfeed(convert = TRUE)
  expect_is(yo_simple, "integer")

})

test_that("Validation is in force for row / columns limits in the cell feed", {

  ## external validity
  ## Africa is first worksheet: 625 rows by 6 columns
  mess <- "less than or equal to"
  expect_error(gs_read_cellfeed(gap, range = cell_rows(1001:1003),
                                verbose = FALSE), mess)
  expect_error(gs_read_cellfeed(gap, range = cell_rows(999:1003),
                                verbose = FALSE), mess)
  expect_error(gs_read_cellfeed(gap, range = cell_cols(27),
                                verbose = FALSE), mess)
  expect_error(gs_read_cellfeed(gap, range = cell_cols(24:30),
                                verbose = FALSE), mess)

})

test_that("query params work on the list feed", {
  oceania_fancy <- gap %>%
    gs_read_listfeed(ws = "Oceania",
                     reverse = TRUE, orderby = "gdppercap",
                     sq = "lifeexp > 79 or year < 1960",
                     verbose = FALSE)
  expect_equal_to_reference(oceania_fancy,
                            "for_reference/gap_oceania_listfeed_query.rds")
})

test_that("readr parsing params are handled on the list feed", {

  oceania_tweaked <- gap %>%
    gs_read_listfeed(ws = "Oceania",
                     col_names = paste0("VAR", 1:6),
                     col_types = "cccnnn",
                     n_max = 5, skip = 1)
  expect_identical(names(oceania_tweaked), paste0("VAR", 1:6))
  expect_equivalent(vapply(oceania_tweaked, class, character(1)),
                    rep(c("character", "numeric"), each = 3))

})
