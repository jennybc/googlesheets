context("Different permissions are set")

my_sheet <- new_ss("Permissions Testing")

test_that("Permissions for a spreadsheet are listed", {

  expect_is(list_perm(my_sheet), "tbl_df")
  expect_equal(list_perm(my_sheet) %>% nrow(),  1)
  expect_equal(list_perm(my_sheet)$role, "owner")
  
})

test_that("Permissions can be added", {

  # cant just use a random email/group because returns HTTP 400 bad request
  old_perm <- list_perm(my_sheet)

  add_perm(my_sheet, value = NULL, type = "anyone", role = "reader")
  
  new_perm <- list_perm(my_sheet)
  expect_equal(nrow(new_perm), nrow(old_perm) + 1) # added entry to perm table
  expect_true("anyone" %in% new_perm$type)
  
})

test_that("Permsssions can be updated", {
  
  old_perm <- list_perm(my_sheet)
  edit_perm(my_sheet, perm_id = "anyoneWithLink", role = "writer")
  
  new_perm <- list_perm(my_sheet)
  
  expect_equal(nrow(new_perm), 2)
  expect_true("writer" %in% new_perm$role)

})

test_that("Permissions can be deleted", {
  
  old_perm <- list_perm(my_sheet)
  
  delete_perm(my_sheet, perm_id = "anyoneWithLink")
  
  new_perm <- list_perm(my_sheet)
  
  expect_equal(nrow(new_perm), 1)
  expect_false("anyone" %in% new_perm$type)
  
})

delete_ss("Permissions Testing")
