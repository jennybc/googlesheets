context("consume data")

ss <- register_ss(ws_feed = pts_ws_feed)

test_that("We can get data from the list feed", {
  
  expect_equal_to_reference(get_via_lf(ss), "pts_sheet1_get_via_lf.rds")

})

test_that("We can get all data from the cell feed", {
  
  expect_equal_to_reference(get_via_cf(ss), "pts_sheet1_get_via_cf.rds")
  
})

test_that("Cell ranges can be converted to a cell limit list", {
  
  jfun <- function(x) x %>%
    as.list() %>%
    setNames(c("min-row", "max-row", "min-col", "max-col"))
  
  expect_equal(convert_range_to_limit_list("C1"), jfun(c(1,1,3,3)))
  expect_equal(convert_range_to_limit_list("R2C8"), jfun(c(2,2,8,8)))
  
  expect_equal(convert_range_to_limit_list("C1:D4"), jfun(c(1,4,3,4)))
  expect_equal(convert_range_to_limit_list("R3C1:R5C4"), jfun(c(3,5,1,4)))
  
  expect_equal(convert_range_to_limit_list("a3:b4"), jfun(c(3,4,1,2)))
  
})

test_that("Bad cell ranges throw error", {
  
  error_regex <- "Trying to set cell limits, but requested range is invalid"
  
  expect_error(convert_range_to_limit_list("eggplant1"), error_regex)
  expect_error(convert_range_to_limit_list(11L), error_regex)
  expect_error(convert_range_to_limit_list(factor(1:5)), error_regex)
  expect_error(convert_range_to_limit_list(16.3), error_regex)
  expect_error(convert_range_to_limit_list("AAA1"), error_regex)
  expect_error(convert_range_to_limit_list("A1:Q9:Z43"), error_regex)
  expect_error(convert_range_to_limit_list(10:1), error_regex)
  
})


test_that("We can get data from specific cells", {
  
  foo <- ss %>%
    get_via_cf(ws = "Africa", min_row = 2, min_col = 4, max_col = 4)
  expect_equal(foo$cell, paste0("D", 2:7))
  
  foo <- ss %>%
    get_via_cf(ws = 2, min_row = 3, max_row = 5, min_col = 1, max_col = 3)
  expect_equal(foo$cell, paste0(LETTERS[1:3], rep(3:5, each = 3)))

  foo2 <- ss %>%
    get_via_cf(ws = 2,
               limits = list(min_row = 3, max_row = 5, min_col = 1, max_col = 3))
  expect_equal(foo, foo2)

})

test_that("We can get data from rows and columns", {
  
  foo <- ss %>% get_row(ws = "Africa", row = 2:3)
  expect_true(all(foo$row %in% 2:3))
  
  foo <- ss %>% get_row(ws = "Africa", row = 1)
  expect_true(all(foo$row == 1))
  
  foo <- ss %>% get_col(ws = "Americas", col = 3:6)
  expect_true(all(foo$col %in% 3:6))
  
  foo <- ss %>% get_col(ws = "Europe", col = 4)
  expect_true(all(foo$col == 4))
  
})

test_that("We can get data from a cell range", {
  
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

test_that("We decline to reshape data if there is none", {
  
  foo <- ss %>% get_row(ws = "Africa", row = 1)
  expect_message(tmp <- foo %>% reshape_cf(), "No data to reshape!")
  expect_null(tmp)
  
})


test_that("We can simplify data from the cell feed", {
  
  foo <- ss %>% get_row(ws = "Africa", row = 2:3)
  expect_equal_to_reference(foo %>% simplify_cf(), "pts_africa_simplify_A1.rds")
  expect_equal_to_reference(foo %>% simplify_cf(notation = "R1C1"),
                                                "pts_africa_simplify_R1C1.rds")
  
  foo <- ss %>% get_col(ws = "Africa", col = 2)
  foo_simple <- foo %>% simplify_cf()
  expect_equivalent(foo_simple, seq(from = 1952, to = 1977, by = 5))
  expect_equal(names(foo_simple), paste0("B", 2:7))
  
  foo_simple2 <- foo %>% simplify_cf(header = FALSE)
  expect_is(foo_simple2, "character")
  
  foo_simple3 <- foo %>% simplify_cf(convert = FALSE)
  expect_equivalent(foo_simple3,
                    seq(from = 1952, to = 1977, by = 5) %>% as.character())
  
  yo <- ss %>% get_col(ws = "Africa", col = 1)
  yo_simple <- yo %>% simplify_cf(as.is = FALSE, convert = TRUE)
  expect_is(yo_simple, "factor")

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


test_that("Special Characters can be imported correctly", {
  
  expect_equal_to_reference(get_via_lf(ss, ws = "special_chars"), 
                            "pts_special_chars.rds")
})

