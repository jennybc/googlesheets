context("login")

test_that("Login with good/bad email and passwd", {
  email <- "gspreadr@gmail.com"
  passwd <- "gspreadrtester"
  
  ## these tests break our approach to testing as authenticated user!
  ## commenting out for now
  ## not sure these are good tests of the login functionality anyway
  #expect_error(login(email, "mypasswd"), "Incorrect username or password.")
  #expect_error(login("myemail", passwd), "Incorrect username or password.")
})
