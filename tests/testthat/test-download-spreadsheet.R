context("download sheets")

test_that("Spreadsheet can be exported", {

  temp_dir <- tempdir()

  # bad format
  expect_error(download_ss(pts_title, to = "pts.txt"),
               "Cannot download Google spreadsheet as this format")

  # good formats
  expect_message(download_ss(pts_title, to = file.path(temp_dir, "pts.xlsx")),
                 "successfully downloaded")
  expect_message(download_ss(pts_title, to = file.path(temp_dir, "pts.pdf")),
                 "successfully downloaded")
  expect_message(download_ss(pts_title, to = file.path(temp_dir, "pts.csv")),
                 "successfully downloaded")

  expect_true(all(file.exists(file.path(temp_dir,
                                        c("pts.xlsx", "pts.pdf", "pts.csv")))))

  expect_true(all(file.remove(file.path(temp_dir,
                                        c("pts.xlsx", "pts.pdf", "pts.csv")))))

})

test_that("Old Sheets can be exported", {

  temp_dir <- tempdir()
  ss <- register_ss(old_title)

  # csv should not work
  # 2015-04-22 AND YET NOW IT DOES? LOOK INTO THIS
  # 2015-02-24 Oh, it's because Google forcibly converted old --> new again :(
  #expect_error(download_ss(old_title, to = file.path(temp_dir, "old.csv")),
  #             "not supported")

  # good formats and different specifications
  expect_message(ss %>% download_ss(to = file.path(temp_dir, "old.xlsx"),
                                    overwrite = TRUE),
                 "successfully downloaded")
  expect_message(download_ss(old_title, to = file.path(temp_dir, "old.xlsx"),
                                                       overwrite = TRUE),
                 "successfully downloaded")
  # this used to use old_url, but that is not working ... figure that out
  # see above re: why things changed
  expect_message(download_ss(old_title, to = file.path(temp_dir, "old.pdf"),
                             overwrite = TRUE),
                 "successfully downloaded")

  expect_true(all(file.exists(file.path(temp_dir, c("old.xlsx", "old.pdf")))))

  expect_true(all(file.remove(file.path(temp_dir, c("old.xlsx", "old.pdf")))))

})
