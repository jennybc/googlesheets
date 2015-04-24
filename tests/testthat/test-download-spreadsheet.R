context("download sheets")

test_that("Spreadsheet can be exported", {

  ss <- register_ss(ws_feed = gap_ws_feed)

  temp_dir <- tempdir()

  # bad format
  expect_error(download_ss(ss, to = "pts.txt"),
               "Cannot download Google spreadsheet as this format")

  # good formats
  fmts <- c("xlsx", "pdf", "csv")
  to_files <- file.path(temp_dir, paste0("oceania.", fmts))
  for(to in to_files) {
    expect_message(ss %>%
                     download_ss(ws = "Oceania", to = to, overwrite = TRUE),
                   "successfully downloaded")
  }

  expect_true(all(file.exists(to_files)))
  expect_true(all(file.remove(to_files)))

})

test_that("Old Sheets can be exported", {

  temp_dir <- tempdir()
  ## we must register by title, in order to get info from the spreadsheets feed,
  ## which, in turn, is the only way to populate the alt_key
  ## this means we must have visited the sheet in the browser at least once!
  ss <- register_ss(old_title)

  # csv should not work
  # 2015-04-24 periodically google will forcibly convert an old sheet to new
  # until they eradicate all of them, this means we have to go grab a fresh
  # old sheet to test against
  # https://github.com/jennybc/googlesheets/issues/107
  expect_error(ss %>% download_ss(to = file.path(temp_dir, "old.csv")),
               "not supported")

  # good formats and different specifications
  expect_message(ss %>% download_ss(to = file.path(temp_dir, "old.xlsx"),
                                    overwrite = TRUE),
                 "successfully downloaded")
  expect_message(ss %>% download_ss(to = file.path(temp_dir, "old.xlsx"),
                                    overwrite = TRUE),
                 "successfully downloaded")
  expect_message(ss %>% download_ss(to = file.path(temp_dir, "old.pdf"),
                             overwrite = TRUE),
                 "successfully downloaded")

  expect_true(all(file.exists(file.path(temp_dir, c("old.xlsx", "old.pdf")))))

  expect_true(all(file.remove(file.path(temp_dir, c("old.xlsx", "old.pdf")))))

})
