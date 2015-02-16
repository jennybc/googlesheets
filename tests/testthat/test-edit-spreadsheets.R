context("edit spreadsheets")

test_that("Make a new spreadsheet", {
  skip("Can not use login() to talk to Drive API")
  
  new_ss("New spreadsheet from test")
  
  ss_df <- list_spreadsheets()
  
  index <- match("New spreadsheet from test", ss_df[["sheet_title"]])
  
  expect_equal(index, 1) 
})


test_that("Copy a spreadsheet", {
  
  skip("Can not use login() to talk to Drive API")
  
  # copy ss that exists already in Google drive  
  copy_ss(pts_title)
  copy_ss(pts_title, "PTS_COPY")
  
  ss_df <- list_spreadsheets()
  
  expect_true(paste("Copy of", pts_title) %in% ss_df[["sheet_title"]]) 
  expect_true("PTS_COPY" %in% ss_df[["sheet_title"]]) 
  
  # copy ss that doesnt exist
  expect_error(copy_ss(paste(pts_title, "phony")))
  
})


test_that("Delete a spreadsheet", {
  
  skip("Can not use login() to talk to Drive API")
  
  del_ss("This is a new spreadsheet")
  del_ss(pts_title)
  del_ss("PTS_COPY")
  
  ss_df <- list_spreadsheets()
  
  expect_false("This is a new spreadsheet" %in% ss_df[["sheet_title"]]) 
  expect_false(pts_title %in% ss_df[["sheet_title"]]) 
  expect_false("PTS_COPY" %in% ss_df[["sheet_title"]]) 
  
  # copy ss that doesnt exist
  expect_error(del_ss("PTS_COPY_COPY"))
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
