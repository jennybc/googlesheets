context("permissions")

activate_test_token()

new_ss <- gs_new(p_("test-gs-permissions"), verbose = FALSE)
gap_ss <- gs_gap()

test_that("Permissions for a spreadsheet are listed", {

  expect_is(gs_perm_ls(new_ss), "tbl_df")
  expect_equal(gs_perm_ls(new_ss) %>% nrow(), 1L)
  expect_equal(gs_perm_ls(new_ss)$role, "owner")

  expect_is(gs_perm_ls(gap_ss), "tbl_df")
  expect_gt(gs_perm_ls(gap_ss) %>% nrow(), 1L)
  expect_equal(gs_perm_ls(gap_ss, "anyone")$role, "reader")

})

test_that("Permissions can be added", {

  # cant just use a random email/group because returns HTTP 400 bad request
  old_perm <- gs_perm_ls(new_ss)
  expect_message(gs_perm_add(new_ss, type = "anyone", role = "reader"),
                 "Success")
  new_perm <- gs_perm_ls(new_ss)

  expect_equal(nrow(new_perm), nrow(old_perm) + 1)
  expect_true("anyone" %in% new_perm$type)

})

test_that("Permsssions can be updated/edited", {

  old_perm <- gs_perm_ls(new_ss)
  expect_true(gs_perm_edit(new_ss, perm_id = "anyoneWithLink", role = "writer"))
  new_perm <- gs_perm_ls(new_ss)

  expect_equal(nrow(new_perm), nrow(old_perm))
  expect_true("writer" %in% new_perm$role)

})

test_that("Permissions can be deleted", {

  old_perm <- gs_perm_ls(new_ss)
  expect_true(gs_perm_delete(new_ss, perm_id = "anyoneWithLink"))
  new_perm <- gs_perm_ls(new_ss)

  expect_equal(nrow(new_perm), 1)
  expect_false("anyone" %in% new_perm$type)

})

gs_grepdel(TEST, verbose = FALSE)
gs_deauth(verbose = FALSE)
