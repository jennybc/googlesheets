context("download sheets")

test_that("Spreadsheet can be exported", {

  ss <- register_ss(ws_feed = gap_ws_feed)

  temp_dir <- tempdir()

  # bad format
  expect_error(gs_download(ss, to = "pts.txt"),
               "Cannot download Google spreadsheet as this format")

  # good formats
  fmts <- c("xlsx", "pdf", "csv")
  to_files <- file.path(temp_dir, paste0("oceania.", fmts))
  for(to in to_files) {
    expect_message(ss %>%
                     gs_download(ws = "Oceania", to = to, overwrite = TRUE),
                   "successfully downloaded")
  }

  expect_true(all(file.exists(to_files)))
  expect_true(all(file.remove(to_files)))

})

test_that("Old Sheets can be exported", {

  ## don't even bother if we can't see this sheet in the spreadsheets feed or if
  ## it's been "helpfully" converted to a new sheet by google AGAIN :(
  check_old_sheet()

  temp_dir <- tempdir()
  ## we must register by title, in order to get info from the spreadsheets feed,
  ## which, in turn, is the only way to populate the alt_key
  ## this means we must have visited the sheet in the browser at least once!
  ss <- gs_title(old_title)

  # csv should not work
  expect_error(ss %>% gs_download(to = file.path(temp_dir, "old.csv")),
               "not supported")

  # good formats and different specifications
  expect_message(ss %>% gs_download(to = file.path(temp_dir, "old.xlsx"),
                                    overwrite = TRUE),
                 "successfully downloaded")
  expect_message(ss %>% gs_download(to = file.path(temp_dir, "old.xlsx"),
                                    overwrite = TRUE),
                 "successfully downloaded")
  expect_message(ss %>% gs_download(to = file.path(temp_dir, "old.pdf"),
                             overwrite = TRUE),
                 "successfully downloaded")

  expect_true(all(file.exists(file.path(temp_dir, c("old.xlsx", "old.pdf")))))

  expect_true(all(file.remove(file.path(temp_dir, c("old.xlsx", "old.pdf")))))

})
