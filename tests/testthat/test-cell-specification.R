context("cell range specification")

## 2015-04-24 Not giving this any love today because of two big changes coming:
## [1] very soon, will merge the branch where I shift to using cellranger
## [2] medium soon, will rework user-facing functions and deepen use of
##       cellranger
## basically, this package is going to do a lot LESS range stuff and just
## rely on cellranger for that

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
  error_strsplit <- 'non-character argument'

  expect_error(convert_range_to_limit_list("eggplant1"), error_regex)
  expect_error(convert_range_to_limit_list(11L), error_strsplit)
  expect_error(convert_range_to_limit_list(factor(1:5)), error_strsplit)
  expect_error(convert_range_to_limit_list(16.3), error_strsplit)
  expect_error(convert_range_to_limit_list("AAA1"), error_regex)
  expect_error(convert_range_to_limit_list(10:1), error_strsplit)

})
