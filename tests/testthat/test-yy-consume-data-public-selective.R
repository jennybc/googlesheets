context("consume data with public visibility, selectively")

## consuming data owned by someone else, namely rpackagetest
ss <- gs_ws_feed(GAP_WS_FEED, lookup = FALSE, verbose = FALSE)

test_that("We can get data from specific cells using limits", {

  ## fully specify limits
  foo <- ss %>%
    gs_read_cellfeed(ws = 5, range = cell_limits(c(3, 1), c(5, 3)))
  expect_equal(foo$cell, paste0(LETTERS[1:3], rep(3:5, each = 3)))

  ## partially specified limits
  foo <- ss %>%
    gs_read_cellfeed(ws = "Oceania", range = cell_limits(c(2, 4), c(NA, 4)))
  expect_true(all(grepl("^D", foo$cell)))

  ## partially specified limits
  foo <- ss %>%
    gs_read_cellfeed(ws = "Oceania", range = cell_limits(lr = c(NA, 3)))
  expect_true(all(grepl("^[ABC][0-9]+$", foo$cell)))

})

test_that("We can get data from specific cells using rows and columns", {

  foo <- ss %>% gs_read_cellfeed(ws = "Africa", range = cell_rows(2:3))
  expect_true(all(foo$row %in% 2:3))

  foo <- ss %>% gs_read_cellfeed(ws = "Africa", range = cell_rows(1))
  expect_true(all(foo$row == 1))

  foo <- ss %>% gs_read_cellfeed(ws = "Oceania", range = cell_cols(3:6))
  expect_true(all(foo$col %in% 3:6))

  foo <- ss %>% gs_read_cellfeed(ws = "Oceania", range = cell_cols(4))
  expect_true(all(foo$col == 4))

})

test_that("We can get data from specific cells using a range", {

  foo <- ss %>% gs_read_cellfeed(ws = "Europe", range = "B3:C7")
  expect_is(foo, "tbl_df")
  expect_true(all(foo$col %in% 2:3))
  expect_true(all(foo$row %in% 3:7))

  foo <- ss %>% gs_read_cellfeed(ws = "Europe", range = "R3C2:R7C3")
  expect_is(foo, "tbl_df")
  expect_true(all(foo$col %in% 2:3))
  expect_true(all(foo$row %in% 3:7))

  foo <- ss %>% gs_read_cellfeed(ws = "Europe", range = "C4")
  expect_is(foo, "tbl_df")
  expect_equal(foo$col, 3)
  expect_equal(foo$row, 4)

  foo <- ss %>% gs_read_cellfeed(ws = "Europe", range = "R4C3")
  expect_is(foo, "tbl_df")
  expect_equal(foo$col, 3)
  expect_equal(foo$row, 4)

})

test_that("We decline to reshape data if there is none", {

  foo <- ss %>% gs_read_cellfeed(ws = "Oceania", range = cell_rows(1))
  expect_message(tmp <- foo %>% gs_reshape_cellfeed(), "No data to reshape!")
  expect_identical(dim(tmp), rep(0L, 2))

})

test_that("We can simplify data from the cell feed", {

  foo <- ss %>% gs_read_cellfeed(ws = "Africa", range = cell_rows(2:3))
  expect_equal_to_reference(foo %>% gs_simplify_cellfeed(),
                            "for_reference/gap_africa_simplify_A1.rds")
  expect_equal_to_reference(
    foo %>% gs_simplify_cellfeed(notation = "R1C1"),
    "for_reference/gap_africa_simplify_R1C1.rds")

  foo <- ss %>% gs_read_cellfeed(ws = "Oceania", range = cell_cols(3))
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

  yo <- ss %>% gs_read_cellfeed(ws = "Oceania", range = cell_cols(1))
  yo_simple <- yo %>% gs_simplify_cellfeed(as.is = FALSE, convert = TRUE)
  expect_is(yo_simple, "factor")

})

test_that("Validation is in force for row / columns limits in the cell feed", {

  ## external validity
  ## Africa is first worksheet: 625 rows by 6 columns
  mess <- "less than or equal to"
  expect_error(gs_read_cellfeed(ss, range = cell_rows(1001:1003)), mess)
  expect_error(gs_read_cellfeed(ss, range = cell_rows(999:1003)), mess)
  expect_error(gs_read_cellfeed(ss, range = cell_cols(27)), mess)
  expect_error(gs_read_cellfeed(ss, range = cell_cols(24:30)), mess)

})

test_that("query params work on the list feed", {
  oceania_fancy <- ss %>%
    gs_read_listfeed(ws = "Oceania",
                     reverse = TRUE, orderby = "gdppercap",
                     sq = "lifeexp > 79 or year < 1960")
  expect_equal_to_reference(oceania_fancy,
                            "for_reference/gap_oceania_listfeed_query.rds")
})
