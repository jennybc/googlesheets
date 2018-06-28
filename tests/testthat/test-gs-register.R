context("register sheets")

activate_test_token()

if (!file.exists("for_reference/iris_pvt_googlesheet.rds")) {
  iris_pvt_url %>%
    gs_url(verbose = FALSE) %>%
    saveRDS("for_reference/iris_pvt_googlesheet.rds")
}

if (!file.exists("for_reference/gap_googlesheet.rds")) {
  gs_gap_key() %>%
    gs_key(verbose = FALSE) %>%
    saveRDS("for_reference/gap_googlesheet.rds")
}

pseudo_expect_equal_to_reference <- function(x, ref) {
  ref_rds <- test_path("for_reference", paste0(ref, "_googlesheet.rds"))
  ref <- readRDS(ref_rds)
  stable_bits <- c("sheet_key", "sheet_title", "n_ws",
                   "author", "email", "version")
  inherits(x, "googlesheet") &&
    identical(x[stable_bits], ref[stable_bits])
}

test_that("Spreadsheet can be registered via title", {

  pseudo_expect_equal_to_reference(iris_pvt_title %>% gs_title(), "iris_pvt")

})

test_that("Spreadsheet can be registered via key", {

  ## sheet owned by gspreadr = authenticated user but not "published to web"
  pseudo_expect_equal_to_reference(iris_pvt_key %>% gs_key(), "iris_pvt")
  pseudo_expect_equal_to_reference(
    iris_pvt_key %>% gs_key(lookup = FALSE, visibility = "private"), "iris_pvt")

  ## sheet owned by rpackagetest and "published to web"
  pseudo_expect_equal_to_reference(gs_gap_key() %>% gs_key(), "gap")
  pseudo_expect_equal_to_reference(gs_gap_key() %>%
                                     gs_key(lookup = FALSE), "gap")
  pseudo_expect_equal_to_reference(gs_gap_key() %>%
                                     gs_key(visibility = "public"), "gap")
  pseudo_expect_equal_to_reference(gs_gap_key() %>%
                                     gs_key(visibility = "private"), "gap")
  pseudo_expect_equal_to_reference(
    gs_gap_key() %>% gs_key(lookup = FALSE, visibility = "private"), "gap")
  pseudo_expect_equal_to_reference(
    gs_gap_key() %>% gs_key(lookup = FALSE, visibility = "public"), "gap")

})

test_that("Spreadsheet can be registered via URL", {

  ## sheet owned by gspreadr = authenticated user but not "published to web"
  pseudo_expect_equal_to_reference(iris_pvt_url %>% gs_url(), "iris_pvt")
  pseudo_expect_equal_to_reference(iris_pvt_url %>% gs_url(lookup = TRUE),
                                   "iris_pvt")
  pseudo_expect_equal_to_reference(
    iris_pvt_url %>% gs_url(lookup = FALSE, visibility = "private"), "iris_pvt")

  ## sheet owned by rpackagetest and "published to web"
  pseudo_expect_equal_to_reference(gs_gap_url() %>% gs_url(), "gap")
  pseudo_expect_equal_to_reference(gs_gap_url() %>%
                                     gs_url(lookup = FALSE), "gap")
  pseudo_expect_equal_to_reference(
    gs_gap_url() %>% gs_url(lookup = FALSE, visibility = "private"), "gap")

})

test_that("Spreadsheet can be registered via ws_feed", {

  ## sheet owned by gspreadr = authenticated user but not "published to web"
  pseudo_expect_equal_to_reference(iris_pvt_ws_feed %>% gs_ws_feed(),
                                   "iris_pvt")
  pseudo_expect_equal_to_reference(
    iris_pvt_ws_feed %>% gs_ws_feed(lookup = FALSE), "iris_pvt")

  ## sheet owned by rpackagetest and "published to web"
  pseudo_expect_equal_to_reference(gs_gap_ws_feed() %>% gs_ws_feed(), "gap")
  pseudo_expect_equal_to_reference(
    gs_gap_ws_feed() %>% gs_ws_feed(lookup = FALSE), "gap")

})

test_that("Spreadsheet can be registered via googlesheet", {

  iris_ss <- iris_pvt_key %>% gs_key()

  ## sheet owned by gspreadr = authenticated user but not "published to web"
  pseudo_expect_equal_to_reference(iris_ss %>% gs_gs(), "iris_pvt")

  ## sheet owned by rpackagetest and "published to web"
  pseudo_expect_equal_to_reference(gs_gap() %>% gs_gs(), "gap")
  pseudo_expect_equal_to_reference(gs_gap() %>% gs_gs(visibility = "private"),
                                   "gap")

})

test_that("Bad spreadsheet ID throws error", {

  expect_error(gs_key(4L), "is.character")
  expect_error(gs_title(rep("Gapminder", 2)), "length")
  expect_error(gs_gs("Gapminder"), "googlesheet")

  ## errors caused by well-formed input that refers to a nonexistent spreadsheet
  expect_error(gs_title("spatuala"), "doesn't match")
  expect_error(gs_key("flyingpig"), "doesn't match")
  nonexistent_url <- sub(iris_pvt_key, "flyingpig", iris_pvt_url)
  expect_error(gs_url(nonexistent_url), "doesn't match")
  nonexistent_ws_feed <- sub(iris_pvt_key, "flyingpig", iris_pvt_ws_feed)
  expect_error(gs_ws_feed(nonexistent_ws_feed), "doesn't match")

})

test_that("We get correct number and titles of worksheets", {

  ss <- gs_ws_feed(gs_gap_ws_feed(), lookup = FALSE)
  expect_equal(ss$n_ws, 5L)
  expect_true(all(c("Asia", "Africa", "Americas", "Europe", "Oceania") %in%
                    ss$ws$ws_title))

})

test_that("Print method for googlesheet works", {

  ss <- gs_gap()
  expect_output(print(ss), paste("Spreadsheet title:", ss$sheet_title))
  expect_output(print(ss), paste("Key:", gs_gap_key()))

})

gs_deauth(verbose = FALSE)
