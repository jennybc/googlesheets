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

gs_grepdel(TEST, verbose = FALSE)
gs_deauth(verbose = FALSE)
