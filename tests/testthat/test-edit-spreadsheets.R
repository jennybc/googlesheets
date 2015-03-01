context("edit spreadsheets")

test_that("Spreadsheet can be created and deleted", {
  
  check_oauth()
  
  x <- sample(9, 1)
  sheet_title <- stringr::str_c("testing", x) 
  
  expect_message(new_ss <- new_ss(sheet_title), "created")
  expect_is(new_ss, "spreadsheet")
  ss_df <- list_sheets()
  expect_true(sheet_title %in% ss_df$sheet_title)
  expect_message(tmp <- delete_ss(sheet_title), "moved to trash")
  expect_true(tmp)
  ss_df <- list_sheets()
  expect_false(sheet_title %in% ss_df$sheet_title)
  
})

test_that("Spreadsheet can be copied", {
  
  check_oauth()
  
  copy_ss <- copy_ss(pts_title)
  expect_is(copy_ss, "spreadsheet")
  
  copy_ss_2 <- copy_ss(pts_title, to = "eggplants are purple")
  expect_is(copy_ss_2, "spreadsheet")
  
  ss_df <- list_sheets()
  
  expect_true(paste("Copy of", pts_title) %in% ss_df[["sheet_title"]]) 
  expect_true("eggplants are purple" %in% ss_df[["sheet_title"]])
  
  delete_ss(paste("Copy of", pts_title))
  delete_ss("eggplants are purple")
  
})

test_that("Nonexistent spreadsheet can NOT be deleted or copied", {
  
  check_oauth()
  
  expect_error(delete_ss("flyingpig"), "doesn't match")
  expect_error(copy_ss("flyingpig"),  "doesn't match")
  
})
  
test_that("Add a new worksheet", {

  ss_old <- register_ss(pts_title)
  
  ss_new <- add_ws(ss_old, "Test Sheet")
  
  expect_is(ss_new, "spreadsheet")
  
  new_ws_index <- ss_old$n_ws + 1
  
  expect_equal(new_ws_index, ss_new$n_ws)
  expect_equal(ss_new$ws[new_ws_index, "row_extent"], 1000)
  expect_equal(ss_new$ws[new_ws_index, "col_extent"], 26)
  expect_equal(ss_new$ws[new_ws_index, "ws_title"], "Test Sheet")
  
  ## this worksheet gets deleted below
  
})


test_that("Delete a worksheet", {
  
  ss_old <- register_ss(pts_title)
  
  ss_new <- delete_ws(ss_old, "Test Sheet")
  
  expect_is(ss_new, "spreadsheet")
  
  expect_equal(ss_old$n_ws - 1, ss_new$n_ws)
  expect_false("Test Sheet" %in% ss_new$ws[["ws_title"]])
  
  ## can't delete a non-existent worksheet
  expect_error(delete_ws(ss_old, "Hello World"))
})

test_that("Worksheet is renamed", {
  
  ss <- register_ss(pts_title)
  ss_new <- rename_ws(ss, "Asia", "Somewhere in Asia")
  
  expect_is(ss_new, "spreadsheet")
  expect_true("Somewhere in Asia" %in% ss_new$ws$ws_title)
  expect_false("Asia" %in% ss_new$ws$ws_title)
  
  ss_final <- rename_ws(ss_new, "Somewhere in Asia", "Asia")
  expect_is(ss_final, "spreadsheet")
  expect_false("Somewhere in Asia" %in% ss_final$ws$ws_title)
  expect_true("Asia" %in% ss_final$ws$ws_title)
  
  ## renaming not allowed to cause duplication of a worksheet name
  expect_error(rename_ws(ss, "Africa", "Americas"), "already exists")

})

test_that("Worksheet is resized", {

  ss <- register_ss(pts_title)
  
  ws_title_pos <- match("for_resizing", ss$ws$ws_title)
  
  row <- sample(1:2000, 1)
  col <- sample(1:35, 1)
  
  ss_new <- resize_ws(ss, "for_resizing", row_extent = row, col_extent = col)
  
  expect_equal(ss_new$ws$row_extent[ws_title_pos], row)
  expect_equal(ss_new$ws$col_extent[ws_title_pos], col)
  
})

## delete any remaining sheets created here
## useful to tidy after failed tests
my_patterns <- c("testing[0-9]{1}",
                 paste("Copy of", pts_title),
                 "eggplants are purple")
my_patterns <- my_patterns %>% stringr::str_c(collapse = "|")
sheets_to_delete <- list_sheets() %>%
  dplyr::filter(stringr::str_detect(sheet_title, my_patterns))
plyr::a_ply(sheets_to_delete$sheet_key, 1, delete_ss)
