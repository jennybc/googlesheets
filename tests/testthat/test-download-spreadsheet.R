context("download sheets")

test_that("Spreadsheet can be exported", {
  
  # bad format
  expect_error(download_ss(pts_title, to = "pts.txt"), "Cannot download Google Spreadsheet as this format")
  
  expect_message(download_ss(pts_title, to = "pts.xlsx"), "successfully downloaded")
  expect_message(download_ss(pts_title, to = "pts.pdf"), "successfully downloaded")
  expect_message(download_ss(pts_title, to = "pts.csv"), "successfully downloaded")
  
  expect_true(file.exists("pts.xlsx"))
  expect_true(file.exists("pts.pdf"))
  expect_true(file.exists("pts.csv"))
  
  expect_true(all(file.remove(c("pts.xlsx", "pts.pdf", "pts.csv"))))
})
