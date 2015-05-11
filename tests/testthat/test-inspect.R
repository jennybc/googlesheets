context("inspect data frames")

test_that("Data frames are plotted as ggplot objects", {
  
  df_with_empty <- data.frame(A = c(1:10), B = c(LETTERS[1:5], rep(NA, 5)))
  
  expect_is(gs_inspect(df_with_empty), "ggplot")
  
  expect_is(readRDS("gap_sheet5_get_via_cf.rds") %>% gs_inspect(), "ggplot")
  expect_is(readRDS("gap_sheet5_get_via_lf.rds") %>% gs_inspect(), "ggplot")
  expect_is(readRDS("pts_special_chars.rds") %>% gs_inspect(), "ggplot")
  
  expect_error(gs_inspect(c(1:10)), "is not TRUE")
})