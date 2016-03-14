context("inspect data frames")

test_that("Data frames are plotted as ggplot objects", {

  df_with_empty <- data.frame(A = 1:10, B = c(LETTERS[1:5], rep(NA, 5)))

  expect_is(gs_inspect(df_with_empty), "ggplot")

  expect_is(readRDS("for_reference/ff.rds") %>% gs_inspect(), "ggplot")
  expect_is(readRDS("for_reference/pts_special_chars.rds") %>% gs_inspect(),
            "ggplot")

  expect_error(gs_inspect(1:10), "is not TRUE")
})
