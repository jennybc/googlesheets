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
