context("create, delete, copy sheets")

## TO DO: gs_vecdel()

test_that("Spreadsheet can be created and deleted", {

  sheet_title <- p_("hello-bye")

  expect_message(new_ss <- gs_new(sheet_title), "created")
  expect_is(new_ss, "googlesheet")
  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_true(sheet_title %in% ss_df$sheet_title)
  expect_message(tmp <- gs_delete(new_ss), "moved to trash")
  expect_true(tmp)
  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_false(sheet_title %in% ss_df$sheet_title)

})

test_that("Spreadsheet can be copied and deleted", {

  copy_of <- p_(paste("Copy of", iris_pvt_title))
  copy_ss <- gs_copy(gs_key(iris_pvt_key), to = copy_of)
  expect_is(copy_ss, "googlesheet")

  eggplants <- p_("eggplants are purple")
  copy_ss_2 <- gs_copy(gs_key(iris_pvt_key), to = eggplants)
  expect_is(copy_ss_2, "googlesheet")

  ss_df <- gs_ls()
  expect_true(all(c(copy_of, eggplants) %in% ss_df$sheet_title))

  gs_delete(copy_ss)
  gs_delete(copy_ss_2)

})

test_that("Old Sheets can be copied and deleted", {

  ## don't even bother if we can't see this sheet in the spreadsheets feed or if
  ## it's been "helpfully" converted to a new sheet by google AGAIN :(
  check_old_sheet()

  ss <- gs_title(old_title)

  my_copy <- p_("test-old-sheet-copy")
  expect_message(ss_copy <- ss %>% gs_copy(to = my_copy), "Successful copy!")
  Sys.sleep(1)
  expect_message(gs_delete(ss_copy), "moved to trash")

})

gs_grepdel(TEST, verbose = FALSE)
