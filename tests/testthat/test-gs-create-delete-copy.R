context("create, delete, copy sheets")

test_that("Spreadsheet can be created and deleted", {

  sheet_title <- p_("hello-bye")

  expect_message(new_ss <- gs_new(sheet_title), "created")
  expect_is(new_ss, "googlesheet")
  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_true(sheet_title %in% ss_df$sheet_title)
  expect_message(tmp <- delete_ss(sheet_title), "moved to trash")
  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_false(sheet_title %in% ss_df$sheet_title)

})

test_that("Regexes work for deleting multiple sheets", {

  sheet_title <- p_(c("cat", "catherine", "tomCAT", "abdicate", "FLYCATCHER"))
  sapply(sheet_title, gs_new)

  Sys.sleep(1)
  delete_ss(p_("cat"))
  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_false(p_("cat") %in% ss_df$sheet_title)
  expect_true(all(sheet_title[-1] %in% ss_df$sheet_title))

  delete_ss(regex = p_("[a-zA-Z]*cat[a-zA-Z]*$"))
  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_false(any(grepl("catherine|abdicate", ss_df$sheet_title) &
                     grepl(TEST, ss_df$sheet_title)))
  expect_true(all(p_(c("tomCAT", "FLYCATCHER")) %in% ss_df$sheet_title))

  delete_ss(regex = "[a-zA-Z]*cat[a-zA-Z]*$", ignore.case = TRUE)
  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_false(any(sheet_title %in% ss_df$sheet_title))

})

test_that("Spreadsheet can be copied", {

  copy_of <- p_(paste("Copy of", iris_pvt_title))
  copy_ss <- gs_copy(gs_key(iris_pvt_key), to = copy_of)
  expect_is(copy_ss, "googlesheet")

  eggplants <- p_("eggplants are purple")
  copy_ss_2 <- gs_copy(gs_key(iris_pvt_key), to = eggplants)
  expect_is(copy_ss_2, "googlesheet")

  ss_df <- gs_ls()
  expect_true(all(c(copy_of, eggplants) %in% ss_df$sheet_title))

  delete_ss(copy_of)
  delete_ss(eggplants)

})

test_that("Nonexistent spreadsheet can NOT be deleted or copied", {

  expect_error(delete_ss("flyingpig"), "doesn't match")
  expect_error(gs_copy(gs_title("flyingpig")),  "doesn't match")

})

test_that("Old Sheets can be copied and deleted", {

  ## don't even bother if we can't see this sheet in the spreadsheets feed or if
  ## it's been "helpfully" converted to a new sheet by google AGAIN :(
  check_old_sheet()

  ss <- register_ss(old_title)

  ## pre-register
  my_copy <- p_("test-old-sheet-copy")
  expect_message(ss_copy <- ss %>% gs_copy(to = my_copy), "Successful copy!")
  Sys.sleep(1)
  expect_message(delete_ss(ss_copy), "moved to trash")
  Sys.sleep(1)

  ## delete by title
  expect_message(ss_copy <-
                   gs_copy(gs_title(old_title), to = my_copy),
                 "Successful copy!")
  Sys.sleep(1)
  expect_message(delete_ss(my_copy), "moved to trash")
  Sys.sleep(1)

  # delete by URL
  expect_message(ss_copy <-
                   gs_copy(gs_url(old_url), to = my_copy), "Successful copy!")
  Sys.sleep(1)
  expect_message(delete_ss(my_copy), "moved to trash")
})

delete_ss(regex = TEST, verbose = FALSE)
