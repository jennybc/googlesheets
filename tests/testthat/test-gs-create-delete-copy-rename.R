context("create, delete, copy sheets")

activate_test_token()

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

test_that("Spreadsheet can be created with custom ws name and size", {

  sheet_title <- p_("hello-bye")

  expect_message(new_ss <- gs_new(sheet_title, "yo!", 3, 3), "created")
  expect_is(new_ss, "googlesheet")
  expect_identical(new_ss %>% gs_ws_ls(), "yo!")
  expect_identical(new_ss$ws$row_extent, 3L)
  expect_identical(new_ss$ws$col_extent, 3L)
  Sys.sleep(1)
  gs_delete(new_ss)

})

test_that("Spreadsheet can be created and populated at once", {

  sheet_title <- p_("hello-bye")

  expect_message(
    new_ss <-
      gs_new(sheet_title, "yo!", input = head(iris), trim = TRUE), "created")
  expect_is(new_ss, "googlesheet")
  expect_identical(new_ss %>% gs_ws_ls(), "yo!")
  expect_identical(new_ss$ws$row_extent, 7L)
  expect_identical(new_ss$ws$col_extent, 5L)
  Sys.sleep(1)
  gs_delete(new_ss)

})

test_that("Spreadsheet can be created w/ only row or column specified", {

  sheet_title <- p_("hello-bye")

  expect_message(
    new_ss <-
      gs_new(sheet_title, "yo!", row_extent = 3), "created")
  expect_is(new_ss, "googlesheet")
  expect_identical(new_ss %>% gs_ws_ls(), "yo!")
  expect_identical(new_ss$ws$row_extent, 3L)
  expect_identical(new_ss$ws$col_extent, 26L)
  Sys.sleep(1)
  gs_delete(new_ss)

})

test_that("Spreadsheet can be copied and multiple sheets can be deleted", {

  copy_of <- p_(paste("Copy of", iris_pvt_title))
  copy_ss <- gs_copy(gs_key(iris_pvt_key), to = copy_of)
  expect_is(copy_ss, "googlesheet")

  eggplants <- p_("eggplants are purple")
  copy_ss_2 <- gs_copy(gs_key(iris_pvt_key), to = eggplants)
  expect_is(copy_ss_2, "googlesheet")

  ss_df <- gs_ls()
  expect_true(all(c(copy_of, eggplants) %in% ss_df$sheet_title))

  tmp <- gs_vecdel(c(copy_of, eggplants))
  expect_true(all(tmp))

})

test_that("gs_delete() throws error on non-googlesheet input", {
  expect_error(gs_delete("yo"))
})

test_that("Sheet can be renamed", {
  name1 <- p_("name1")
  name2 <- p_("name2")
  ss <- gs_mini_gap() %>% gs_copy(name1)
  ss <- ss %>% gs_rename(to = name2)
  ss_df <- gs_ls()
  expect_false(name1 %in% ss_df$sheet_title)
  expect_true(name2 %in% ss_df$sheet_title)
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
gs_deauth(verbose = FALSE)
