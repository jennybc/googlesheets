context("consume data with public visibility, selectively")

## consuming data owned by someone else, namely rpackagetest
ss <- gs_ws_feed(gap_ws_feed, lookup = FALSE, verbose = FALSE)

test_that("We can get data from specific cells using limits", {

  ## fully specify individual limits
  foo <- ss %>%
    get_via_cf(ws = 5, min_row = 3, max_row = 5, min_col = 1, max_col = 3)
  expect_equal(foo$cell, paste0(LETTERS[1:3], rep(3:5, each = 3)))

  ## same limits, but provided as list
  foo2 <- ss %>%
    get_via_cf(ws = 5,
               limits = list(min_row = 3, max_row = 5, min_col = 1, max_col = 3))
  expect_equal(foo, foo2)

  ## partially specified limits
  foo <- ss %>%
    get_via_cf(ws = "Oceania", min_row = 2 , min_col = 4, max_col = 4)
  expect_true(all(grepl("^D", foo$cell)))

  ## partially specified limits
  foo <- ss %>%
    get_via_cf(ws = "Oceania", max_col = 3)
  expect_true(all(grepl("^[ABC][0-9]+$", foo$cell)))

})

test_that("We can get data from specific cells using rows and columns", {

  foo <- ss %>% get_row(ws = "Africa", row = 2:3)
  expect_true(all(foo$row %in% 2:3))

  foo <- ss %>% get_row(ws = "Africa", row = 1)
  expect_true(all(foo$row == 1))

  foo <- ss %>% get_col(ws = "Oceania", col = 3:6)
  expect_true(all(foo$col %in% 3:6))

  foo <- ss %>% get_col(ws = "Oceania", col = 4)
  expect_true(all(foo$col == 4))

})

test_that("We can get data from specific cells using a range", {

  foo <- ss %>% get_cells(ws = "Europe", range = "B3:C7")
  expect_is(foo, "tbl_df")
  expect_true(all(foo$col %in% 2:3))
  expect_true(all(foo$row %in% 3:7))

  foo <- ss %>% get_cells(ws = "Europe", range = "R3C2:R7C3")
  expect_is(foo, "tbl_df")
  expect_true(all(foo$col %in% 2:3))
  expect_true(all(foo$row %in% 3:7))

  foo <- ss %>% get_cells(ws = "Europe", range = "C4")
  expect_is(foo, "tbl_df")
  expect_equal(foo$col, 3)
  expect_equal(foo$row, 4)

  foo <- ss %>% get_cells(ws = "Europe", range = "R4C3")
  expect_is(foo, "tbl_df")
  expect_equal(foo$col, 3)
  expect_equal(foo$row, 4)

})

test_that("We decline to reshape data if there is none", {

  foo <- ss %>% get_row(ws = "Oceania", row = 1)
  expect_message(tmp <- foo %>% reshape_cf(), "No data to reshape!")
  expect_null(tmp)

})

test_that("We can simplify data from the cell feed", {

  foo <- ss %>% get_row(ws = "Africa", row = 2:3)
  expect_equal_to_reference(foo %>% simplify_cf(), "gap_africa_simplify_A1.rds")
  expect_equal_to_reference(foo %>% simplify_cf(notation = "R1C1"),
                                                "gap_africa_simplify_R1C1.rds")

  foo <- ss %>% get_col(ws = "Oceania", col = 3)
  foo_simple <- foo %>% simplify_cf()
  expect_equivalent(foo_simple, rep(seq(from = 1952, to = 2007, by = 5), 2))
  expect_equal(names(foo_simple), paste0("C", 1:24 + 1))

  foo_simple2 <- foo %>% simplify_cf(header = FALSE)
  expect_is(foo_simple2, "character")

  foo_simple3 <- foo %>% simplify_cf(convert = FALSE)
  expect_equivalent(foo_simple3,
                    rep(seq(from = 1952, to = 2007, by = 5), 2) %>%
                      as.character())

  yo <- ss %>% get_col(ws = "Oceania", col = 1)
  yo_simple <- yo %>% simplify_cf(as.is = FALSE, convert = TRUE)
  expect_is(yo_simple, "factor")

})

test_that("Validation is in force for row / columns limits in the cell feed", {

  expect_error(get_via_cf(ss, min_row = "eggplant"), "Invalid input")
  expect_error(get_via_cf(ss, max_col = factor(1)), "Invalid input")
  expect_error(get_via_cf(ss, max_row = 1:3), "Invalid input")
  expect_error(get_via_cf(ss, min_col = -100), "Invalid input")

  ## internal consistency
  ## get rid of these once we fully embrace cellranger, which checks this and is
  ## under testing itself?
  expect_error(get_via_cf(ss, min_row = 5, max_row = 3),
               "less than or equal to")
  expect_error(get_via_cf(ss, min_col = 5, max_col = 3),
               "less than or equal to")

  ## external validity
  ## Africa is first worksheet: 625 rows by 6 columns
  expect_error(get_via_cf(ss, min_row = 1001), "less than or equal to")
  expect_error(get_via_cf(ss, max_row = 1001), "less than or equal to")
  expect_error(get_via_cf(ss, min_col = 27), "less than or equal to")
  expect_error(get_via_cf(ss, max_col = 27), "less than or equal to")

})

