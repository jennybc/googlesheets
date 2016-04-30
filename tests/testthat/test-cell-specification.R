context("cell range specification")

test_that("Ranges can be converted to a cell limit list", {

  jfun <- function(x) x %>%
    as.list() %>%
    stats::setNames(c("min-row", "max-row", "min-col", "max-col"))

  expect_equal("C1" %>% cellranger::as.cell_limits() %>% limit_list(),
               jfun(c(1 , 1, 3, 3)))
  expect_equal("R2C8" %>% cellranger::as.cell_limits() %>% limit_list(),
               jfun(c(2, 2, 8, 8)))

  expect_equal("C1:D4" %>% cellranger::as.cell_limits() %>% limit_list(),
               jfun(c(1, 4, 3, 4)))
  expect_equal("R3C1:R5C4" %>% cellranger::as.cell_limits() %>% limit_list(),
               jfun(c(3, 5, 1, 4)))
})

