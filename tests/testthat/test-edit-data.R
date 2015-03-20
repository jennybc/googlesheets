context("updating cell values")

ss <- register_ss(pts_title, verbose = FALSE)
ws <- "for_updating"

test_that("Input converts to character vector (or not)", {
  
  expect_ok_as_input <- function(x) {
    expect_is(x %>% as_character_vector(), "character")
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
  tmp2 <- tmp %>% as_character_vector()
  expect_equivalent(tmp2[seq_len(ncol(iris))], iris[1, ] %>% t() %>% drop())
  tmp3 <- tmp %>% as_character_vector(header = TRUE)
  expect_identical(tmp3[seq_len(ncol(iris))], names(iris))
  
  expect_error(rnorm %>% as_character_vector(), "not suitable as input")
  expect_error(ss %>% as_character_vector(), "not suitable as input")
  expect_error(array(1:9, dim = rep(3,3)) %>% as_character_vector(),
               "Input has more than 2 dimensions")
})

test_that("Single cells can be updated", {

  expect_message(ss <- edit_cells(ss, ws, "eggplant", "A1"), 
                 "successfully updated")
  tmp <- ss %>% get_cells(ws, "A1") %>% simplify_cf(header = FALSE)
  expect_identical(tmp, c(A1 = "eggplant"))
  
  # force worksheet extent to be increased
  expect_message(ss <- edit_cells(ss, ws, "Way out there!", "R1C30"), 
                 "dimensions changed")
  expect_equal(ss %>% get_ws(ws) %>% `[[`("col_extent"), 30)
  
  # clean up
  ss <- ss %>% resize_ws(ws, 1000, 26)
})

iris_ish <- iris %>% head(3)
## because our data consumption m.o. is stringsAsFactors = FALSE
iris_ish$Species <- iris_ish$Species %>% as.character()

test_that("2-dimensional things can be uploaded", {

  # update with empty strings to "clear" cells
  tmp <- ss %>% get_via_cf(ws)
  input <- matrix("", nrow = max(tmp$row), ncol = max(tmp$col))
  ss <- ss %>% edit_cells(ws, input)
  tmp <- ss %>% get_via_cf(ws)
  expect_equal(dim(tmp), c(0, 5))
  
  # update w/ a data.frame, header = FALSE
  ss <- ss %>% edit_cells(ws, iris_ish)
  tmp <- ss %>% get_via_cf(ws) %>% reshape_cf(header = FALSE)
  expect_equivalent(tmp, iris_ish)
  
  # update w/ a data.frame, header = TRUE
  ss <- ss %>% edit_cells(ws, iris_ish, header = TRUE)
  tmp <- ss %>% get_via_cf(ws) %>% reshape_cf()
  expect_identical(tmp, iris_ish)
  
})

test_that("Vectors can be uploaded", {
  
  # by_row = FALSE
  ss <- ss %>% edit_cells(ws, LETTERS[1:5], "A8")
  tmp <- ss %>% get_via_cf(ws, min_row = 7) %>% simplify_cf()
  expect_equivalent(tmp, LETTERS[1:5])
  
  # by_row = TRUE
  ss <- ss %>% edit_cells(ws, LETTERS[5:1], "A15", by_row = TRUE)
  tmp <- ss %>% get_via_cf(ws, min_row = 15) %>% simplify_cf()
  expect_equivalent(tmp, LETTERS[5:1])
  
})
