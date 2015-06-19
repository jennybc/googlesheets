context("edit cells")

suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))

pts_copy <- p_("pts-copy")
ss <- gs_copy(gs_key(pts_key, lookup = FALSE, verbose = FALSE),
              to = pts_copy, verbose = FALSE)
ws <- "for_updating"

test_that("Input converts to character vector (or not)", {

  expect_ok_as_input <- function(x) {
    expect_is(x %>% as_character_vector(col_names = FALSE), "character")
  }

  expect_ok_as_input(-3:3)
  expect_ok_as_input(rnorm(5))
  expect_ok_as_input(LETTERS[1:5])
  expect_ok_as_input(LETTERS[1:5] %>% factor())
  expect_ok_as_input(c(TRUE, FALSE, TRUE))
  expect_ok_as_input(Sys.Date())
  expect_ok_as_input(Sys.time())

  expect_ok_as_input(matrix(1:6, nrow = 2))

  tmp <- iris %>% head()
  expect_ok_as_input(tmp)
  tmp2 <- tmp %>% as_character_vector(col_names = FALSE)
  expect_equivalent(tmp2[seq_len(ncol(iris))], iris[1, ] %>% t() %>% drop())
  tmp3 <- tmp %>% as_character_vector(col_names = TRUE)
  expect_identical(tmp3[seq_len(ncol(iris))], names(iris))

  expect_error(rnorm %>% as_character_vector(col_names = FALSE),
               "not suitable as input")
  expect_error(ss %>% as_character_vector(col_names = FALSE),
               "not suitable as input")
  expect_error(array(1:9, dim = rep(3,3)) %>%
                 as_character_vector(col_names = FALSE),
               "Input has more than 2 dimensions")
})

test_that("Single cell can be updated", {

  expect_message(ss <- gs_edit_cells(ss, ws, "eggplant", "A1"),
                 "successfully updated")
  Sys.sleep(1)
  tmp <- ss %>%
    gs_read_cellfeed(ws, range = "A1") %>%
    gs_simplify_cellfeed(col_names = FALSE)
  expect_identical(tmp, c(A1 = "eggplant"))

})

test_that("Cell update can force resize of worksheet", {

  ss <- gs_key(ss$sheet_key)
  ss <- ss %>% gs_ws_resize(ws, 20, 26)
  Sys.sleep(1)

  # force worksheet extent to be increased
  expect_message(ss <- gs_edit_cells(ss, ws, "Way out there!", "R1C30"),
                 "dimensions changed")
  Sys.sleep(1)
  expect_equal(ss %>% gs_ws(ws) %>% `[[`("col_extent"), 30)

  # clean up
  ss <- ss %>% gs_ws_resize(ws, 22, 26)
})

iris_ish <- iris %>% head(3) %>% dplyr::as.tbl()
## because our data consumption m.o. is stringsAsFactors = FALSE
iris_ish$Species <- iris_ish$Species %>% as.character()

test_that("2-dimensional things can be uploaded", {

  # update with empty strings to "clear" cells
  tmp <- ss %>% gs_read_cellfeed(ws)
  if(nrow(tmp) > 0) {
    input <- matrix("", nrow = max(tmp$row), ncol = max(tmp$col))
    ss <- ss %>% gs_edit_cells(ws, input)
    Sys.sleep(1)
    tmp <- ss %>% gs_read_cellfeed(ws)
  }
  expect_equal(dim(tmp), c(0, 5))

  # update w/ a data.frame, col_names = FALSE
  ss <- ss %>% gs_edit_cells(ws, iris_ish, col_names = FALSE)
  Sys.sleep(1)
  tmp <- ss %>% gs_read(ws, header = FALSE) # header goes to read.csv()
  names(tmp) <- names(iris_ish) # I know these disagree, so just equate them
  expect_equivalent(tmp, iris_ish)

  # update w/ a data.frame, col_names = TRUE
  ss <- ss %>% gs_edit_cells(ws, iris_ish)
  Sys.sleep(1)
  tmp <- ss %>% gs_read(ws)
  expect_identical(tmp, iris_ish)

})

test_that("Vectors can be uploaded", {

  ss <- gs_key(ss$sheet_key)

  # byrow = FALSE
  ss <- ss %>% gs_edit_cells(ws, LETTERS[1:5], "A8")
  Sys.sleep(2)
  tmp <- ss %>% gs_read_cellfeed(ws, range = "A8:A12") %>%
    gs_simplify_cellfeed()
  expect_equivalent(tmp, LETTERS[1:5])

  # byrow = TRUE
  ss <- ss %>% gs_edit_cells(ws, LETTERS[5:1], "A15", byrow = TRUE)
  Sys.sleep(2)
  tmp <- ss %>% gs_read_cellfeed(ws, range = "A15:E15") %>%
                                   gs_simplify_cellfeed()
  expect_equivalent(tmp, LETTERS[5:1])

})

test_that("We can trim worksheet extent to fit uploaded data", {

  ws <- "for_resizing"
  ss <- ss %>% gs_edit_cells(ws, iris_ish, trim = TRUE)
  expect_equal(nrow(iris_ish) + 1, ss$ws$row_extent[ss$ws$ws_title == ws])
  expect_equal(ncol(iris_ish), ss$ws$col_extent[ss$ws$ws_title == ws])

})

gs_grepdel(TEST, verbose = FALSE)
gs_auth_suspend(verbose = FALSE)
