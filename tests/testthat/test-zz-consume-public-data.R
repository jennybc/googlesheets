context("consume data WITHOUT authenticating")
## this is a separate file, with a name that is alphabetically last, because I
## want to change working directory, w/o wrecking other tests

temp_dir <- tempdir()
old_wd <- setwd(temp_dir)

iris_public <- register_ss(key = ptw_key, visibility = "public")

iris_ish <- iris %>% head(6)
## because our data consumption m.o. is stringsAsFactors = FALSE
iris_ish$Species <- iris_ish$Species %>% as.character()

test_that("We can get data 'published to the web' sheet w/o authenticating, via csv", {
  
  tmp <- iris_public %>% get_via_csv()
  expect_equivalent(tmp, iris_ish)
  
})

test_that("We can get data 'published to the web'  w/o authenticating, via list feed", {
  
  iris_ish2 <- iris_ish
  ## because the list feed will lowercase the names
  names(iris_ish2) <- names(iris_ish2) %>% tolower()
  
  tmp <- iris_public %>% get_via_lf()
  expect_equivalent(tmp, iris_ish)
  
  
})

setwd(old_wd)
