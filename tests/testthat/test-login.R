context("login")

test_that("Login with good/bad email and passwd", {
  email <- "gspreadr@gmail.com"
  passwd <- "gspreadrtester"
  client <- login(email, passwd)
  
  expect_equal(class(client), "client")
  expect_equal(class(client$auth), "character")
  expect_error(login(email, "mypasswd"), "Incorrect username or password.")
  expect_error(login("myemail", passwd), "Incorrect username or password.")
})


test_that("Authorize using Oauth2.0", {
  client <- authorize()
  
  expect_equal(class(client), "client")
  expect_equal(class(client$auth)[1], "Token2.0")
})


