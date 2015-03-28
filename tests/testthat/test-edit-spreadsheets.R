context("edit spreadsheets")

test_that("Spreadsheet can be created and deleted", {
  
  x <- sample(9, 1)
  sheet_title <- stringr::str_c("testing", x) 
  
  expect_message(new_ss <- new_ss(sheet_title), "created")
  expect_is(new_ss, "gspreadsheet")
  ss_df <- list_sheets()
  expect_true(sheet_title %in% ss_df$sheet_title)
  expect_message(tmp <- delete_ss(sheet_title), "moved to trash")
  ss_df <- list_sheets()
  expect_false(sheet_title %in% ss_df$sheet_title)
  
})

test_that("Regexes work for deleting multiple sheets", {
  
  sheet_title <- c("cat", "catherine", "tomCAT", "abdicate", "FLYCATCHER")
  sapply(sheet_title, new_ss)
  
  Sys.sleep(1)
  delete_ss("cat")
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_false("cat" %in% ss_df$sheet_title)
  expect_true(all(sheet_title[-1] %in% ss_df$sheet_title))
  
  delete_ss(regex = "cat")
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_false(any(c("catherine", "abdicate") %in% ss_df$sheet_title))
  expect_true(all(c("tomCAT", "FLYCATCHER") %in% ss_df$sheet_title))
  
  delete_ss(regex = "cat", ignore.case = TRUE)
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_false(any(sheet_title %in% ss_df$sheet_title))
  
})

test_that("Spreadsheet can be copied", {
  
  copy_ss <- copy_ss(pts_title)
  expect_is(copy_ss, "gspreadsheet")
  
  copy_ss_2 <- copy_ss(pts_title, to = "eggplants are purple")
  expect_is(copy_ss_2, "gspreadsheet")
  
  ss_df <- list_sheets()
  
  expect_true(paste("Copy of", pts_title) %in% ss_df[["sheet_title"]]) 
  expect_true("eggplants are purple" %in% ss_df[["sheet_title"]])
  
  delete_ss(paste("Copy of", pts_title))
  delete_ss("eggplants are purple")
  
})

test_that("Nonexistent spreadsheet can NOT be deleted or copied", {
  
  expect_error(delete_ss("flyingpig"), "doesn't match")
  expect_error(copy_ss("flyingpig"),  "doesn't match")
  
})
  
test_that("Add a new worksheet", {

  ss_old <- register_ss(pts_title)
  
  ss_new <- add_ws(ss_old, "Test Sheet")
  
  expect_is(ss_new, "gspreadsheet")

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
  
  expect_is(ss_new, "gspreadsheet")

  expect_equal(ss_old$n_ws - 1, ss_new$n_ws)
  expect_false("Test Sheet" %in% ss_new$ws[["ws_title"]])
  
  ## can't delete a non-existent worksheet
  expect_error(delete_ws(ss_old, "Hello World"))
})

test_that("Worksheet is renamed", {
  
  ss <- register_ss(pts_title)
  ss_new <- rename_ws(ss, "Asia", "Somewhere in Asia")
  
  expect_is(ss_new, "gspreadsheet")
  expect_true("Somewhere in Asia" %in% ss_new$ws$ws_title)
  expect_false("Asia" %in% ss_new$ws$ws_title)

  ss_final <- rename_ws(ss_new, "Somewhere in Asia", "Asia")
  expect_is(ss_final, "gspreadsheet")
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


test_that("Different file formats can be uploaded", {
  
  expect_error(upload_ss("I dont exist.csv"), "does not exist")
  expect_error(upload_ss("test-register.R"),
               "Cannot convert file with this extension")
  
  expect_message(upload_ss("gap-data.xlsx"), "uploaded")
  ss <- register_ss("gap-data")
  expect_equal(ss$n_ws, 5)
  
  expect_message(upload_ss("gap-data.tsv"), "uploaded")
  expect_message(upload_ss("gap-data.csv"), "uploaded")
  expect_message(upload_ss("gap-data.txt"), "uploaded")
  expect_message(upload_ss("gap-data.ods"), "uploaded")
  
  ss_df <- list_sheets()
  gap_matches <- grepl("gap-data", ss_df$sheet_title)
  expect_equal(gap_matches %>% sum(), 5)
  
})

## delete any remaining sheets created here
## useful to tidy after failed tests
my_patterns <- c("testing[0-9]{1}", "gap-data",
                 paste("Copy of", pts_title),
                 "eggplants are purple")
my_patterns <- my_patterns %>% stringr::str_c(collapse = "|")
delete_ss(regex = my_patterns, verbose = FALSE)
