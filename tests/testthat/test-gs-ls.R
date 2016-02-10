context("list sheets")

activate_test_token()

test_that("Spreadsheets visible to authenticated user can be listed", {

  ss_list <- gs_ls()
  expect_is(ss_list, "googlesheet_ls")
  expect_more_than(nrow(ss_list), 0)

})

test_that("Regexes work for limiting sheet listing", {

  sheet_title <- c("cat", "catherine", "tomCAT", "abdicate", "FLYCATCHER")
  ss <- lapply(p_(sheet_title), gs_new)
  names(ss) <- sheet_title

  # this should NOT pick up 'cat', 'tomCAT', or 'FLYCATCHER'
  ss_df <- gs_ls(regex = p_("[a-zA-Z]*cat[a-zA-Z]+$"))
  expect_identical(sort(ss_df$sheet_title),
                   sort(p_(c("catherine", "abdicate"))))

  # this should NOT pick up 'cat' or 'tomCAT'
  ss_df <- gs_ls(regex = p_("[a-zA-Z]*cat[a-zA-Z]+$"), ignore.case = TRUE)
  expect_identical(sort(ss_df$sheet_title),
                   sort(p_(c("catherine", "abdicate", "FLYCATCHER"))))

  # this should pick up all
  ss_df <- gs_ls(regex = p_("[a-zA-Z]*cat[a-zA-Z]*$"), ignore.case = TRUE)
  expect_identical(sort(ss_df$sheet_title), sort(p_(sheet_title)))

  ## delete them all
  ret <- lapply(ss_df$sheet_key, function(x) gs_delete(gs_key(x)))
  expect_true(all(unlist(ret)))

})

gs_deauth(verbose = FALSE)
