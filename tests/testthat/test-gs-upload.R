context("upload sheets")

activate_test_token()

test_that("Nonexistent or wrong-extension files throw error", {

  expect_error(gs_upload("I dont exist.csv"), "does not exist")
  ## note this expects working directory to be tests/testthat/ !!
  expect_error(gs_upload("test-gs-upload.R"),
               "Cannot convert file with this extension")

})

test_that("Different file formats can be uploaded", {

  files_to_upload <-
    paste("mini-gap", c("xlsx", "tsv", "csv", "txt", "ods"), sep = ".")
  upload_titles <- p_(files_to_upload)

  tmp <- mapply(gs_upload,
                file = system.file("mini-gap",
                                   files_to_upload, package = "googlesheets"),
                sheet_title = upload_titles, SIMPLIFY = FALSE)

  Sys.sleep(1)
  expect_true(all(vapply(tmp, class, character(2))[1, ] == "googlesheet"))
  expect_equivalent(vapply(tmp, function(x) x$n_ws,integer(1)),
                    c(5, 1, 1, 1, 5))

  Sys.sleep(1)
  ss_df <- gs_ls()
  expect_true(all(upload_titles %in% ss_df$sheet_title))

})

test_that("Overwrite actually overwrites an existing file", {
  
  # Reference data
  df1 <- data.frame(x=1)
  df2 <- data.frame(x=2)
  write.csv(df1, "df1.csv", row.names = F)
  write.csv(df2, "df2.csv", row.names = F)
  orig_file <- gs_upoad("df1.csv")
  Sys.sleep(1)
  # Generate 2 files: 1 using gs_edit, 1 using gs_upload(overwrite = T), which should be identical at the end
  # First using editing
  edited_file <- gs_copy(orig_file, to = "edited_file")
  Sys.sleep(1)
  gs_edit_cells(edited_file, input = df2)
  Sys.sleep(1)
  edited_file_content <- gs_read(edited_file)
  Sys.sleep(1)
  # Second using overwrite
  overwritten_file <- gs_copy(orig_file, to = "overwritten_file")
  Sys.sleep(1)
  gs_upload("df2.csv", sheet_title = "df1", overwrite = T)
  Sys.sleep(1)
  overwritten_file_content <- gs_read(overwritten_file)
  # Perform the test
  expect_that(edited_file_content, equals(overwritten_file_content))

  # Todo: test overwrite for identical name
  
})


gs_grepdel(TEST, verbose = FALSE)
gs_deauth(verbose = FALSE)
