context("login")

test_that("Login with good/bad email and passwd", {
  email <- "gspreadr@gmail.com"
  passwd <- "gspreadrtester"
  
  expect_error(login(email, "mypasswd"), "Incorrect username or password.")
  expect_error(login("myemail", passwd), "Incorrect username or password.")
})
