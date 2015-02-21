context("edit spreadsheets")

## TO DO: clean out stuff in Google Drive and Public Testing Sheet that could 
## have been left behind by previous unsuccessful tests? such as all sheets 
## titled testing[1-9], Copy of Public Testing Sheet, "eggplants are purple",
## etc.

test_that("Spreadsheet can be created and deleted", {
  
  check_oauth()
  
  x <- sample(9, 1)
  sheet_title <- stringr::str_c("testing", x) 
  
  expect_message(new_sheet(sheet_title), "created")
  ss_df <- list_sheets()
  expect_true(sheet_title %in% ss_df$sheet_title)
  expect_message(delete_sheet(sheet_title), "moved to trash")
  ss_df <- list_sheets()
  expect_false(sheet_title %in% ss_df$sheet_title)
  
})

test_that("Spreadsheet can be copied", {
  
  check_oauth()
  
  copy_sheet(pts_title)
  copy_sheet(pts_title, to = "eggplants are purple")
  
  ss_df <- list_sheets()
  
  expect_true(paste("Copy of", pts_title) %in% ss_df[["sheet_title"]]) 
  expect_true("eggplants are purple" %in% ss_df[["sheet_title"]])
  
  delete_sheet(paste("Copy of", pts_title))
  delete_sheet("eggplants are purple")
  
})

test_that("Nonexistent spreadsheet can NOT be deleted or copied", {
  
  check_oauth()
  
  expect_error(delete_sheet("flyingpig"), "doesn't match")
  expect_error(copy_sheet("flyingpig"),  "doesn't match")
  
})
  
test_that("Add a new worksheet", {

  ss_old <- register(pts_title)
  
  new_ws(ss_old, "Test Sheet")
  
  ss_new <- register(pts_title) # 'refresh'
  
  new_ws_index <- ss_old$n_ws + 1
  
  expect_equal(new_ws_index, ss_new$n_ws)
  expect_equal(ss_new$ws[new_ws_index, "row_extent"], 1000)
  expect_equal(ss_new$ws[new_ws_index, "col_extent"], 26)
  expect_equal(ss_new$ws[new_ws_index, "ws_title"], "Test Sheet")
})

test_that("Delete a worksheet", {
  
  ss_old <- register(pts_title)
  
  delete_ws(ss_old, "Test Sheet")
  
  ss_new <- register(pts_title) # 'refresh'
  
  expect_equal(ss_old$n_ws - 1, ss_new$n_ws)
  expect_false("Test Sheet" %in% ss_new$ws[["ws_title"]])
  
  expect_error(delete_ws(ss_old, "Hello World"))
})
