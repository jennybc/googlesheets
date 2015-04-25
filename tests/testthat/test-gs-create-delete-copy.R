context("create, delete, copy sheets")

test_that("Spreadsheet can be created and deleted", {

  sheet_title <- p_("hello-bye")

  expect_message(new_ss <- new_ss(sheet_title), "created")
  expect_is(new_ss, "googlesheet")
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_true(sheet_title %in% ss_df$sheet_title)
  expect_message(tmp <- delete_ss(sheet_title), "moved to trash")
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_false(sheet_title %in% ss_df$sheet_title)

})

test_that("Regexes work for deleting multiple sheets", {

  sheet_title <- p_(c("cat", "catherine", "tomCAT", "abdicate", "FLYCATCHER"))
  sapply(sheet_title, new_ss)

  Sys.sleep(1)
  delete_ss(p_("cat"))
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_false(p_("cat") %in% ss_df$sheet_title)
  expect_true(all(sheet_title[-1] %in% ss_df$sheet_title))

  delete_ss(regex = p_("[a-zA-Z]*cat[a-zA-Z]*$"))
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_false(any(grepl("catherine|abdicate", ss_df$sheet_title) &
                     grepl(TEST, ss_df$sheet_title)))
  expect_true(all(p_(c("tomCAT", "FLYCATCHER")) %in% ss_df$sheet_title))

  delete_ss(regex = "[a-zA-Z]*cat[a-zA-Z]*$", ignore.case = TRUE)
  Sys.sleep(1)
  ss_df <- list_sheets()
  expect_false(any(sheet_title %in% ss_df$sheet_title))

})

test_that("Spreadsheet can be copied", {

  copy_of <- p_(paste("Copy of", iris_pvt_title))
  copy_ss <- copy_ss(iris_pvt_key, to = copy_of)
  expect_is(copy_ss, "googlesheet")

  eggplants <- p_("eggplants are purple")
  copy_ss_2 <- copy_ss(iris_pvt_key, to = eggplants)
  expect_is(copy_ss_2, "googlesheet")

  ss_df <- list_sheets()
  expect_true(all(c(copy_of, eggplants) %in% ss_df$sheet_title))

  delete_ss(copy_of)
  delete_ss(eggplants)

})

test_that("Nonexistent spreadsheet can NOT be deleted or copied", {

  expect_error(delete_ss("flyingpig"), "doesn't match")
  expect_error(copy_ss("flyingpig"),  "doesn't match")

})

test_that("Old Sheets can be copied and deleted", {

  ## we must register by title, in order to get info from the spreadsheets feed,
  ## which, in turn, is the only way to populate the alt_key
  ## this means we must have visited the sheet in the browser at least once!
  ss <- register_ss(old_title)

  ## pre-register
  my_copy <- p_("test-old-sheet-copy")
  expect_message(ss_copy <- ss %>% copy_ss(to = my_copy), "Successful copy!")
  Sys.sleep(1)
  expect_message(delete_ss(ss_copy), "moved to trash")
  Sys.sleep(1)

  ## delete by title
  expect_message(ss_copy <-
                   copy_ss(from = old_title, to = my_copy), "Successful copy!")
  Sys.sleep(1)
  expect_message(delete_ss(my_copy), "moved to trash")
  Sys.sleep(1)

  # delete by URL
  expect_message(ss_copy <-
                   copy_ss(from = old_url, to = my_copy), "Successful copy!")
  Sys.sleep(1)
  expect_message(delete_ss(my_copy), "moved to trash")

})

delete_ss(regex = TEST, verbose = FALSE)
