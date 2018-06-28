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
  before <- dplyr::data_frame(x = "before")
  after <- dplyr::data_frame(x = "after")
  on.exit(file.remove(c("before.csv", "after.csv")))
  readr::write_csv(before, "before.csv")
  readr::write_csv(after, "after.csv")

  target_sheet <-  p_("overwrite_test_sheet")
  ss <- gs_upload("before.csv", target_sheet)
  Sys.sleep(1)

  res <- gs_read(ss)
  expect_identical(res$x[1], "before")

  ss <- gs_upload("after.csv", target_sheet, overwrite = TRUE)
  Sys.sleep(1)

  res <- gs_read(ss)
  expect_identical(res$x[1], "after")

})


gs_grepdel(TEST, verbose = FALSE)
gs_deauth(verbose = FALSE)
