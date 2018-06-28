context("consume tricky data")

ss <- gs_key(pts_key, lookup = FALSE, visibility = "public", verbose = FALSE)

test_that("We can handle embedded empty cells via csv", {

  expect_warning(
    dat_csv <- ss %>% gs_read_csv("embedded_empty_cells"),
    "Missing column names filled in"
  )
  expect_equal(dim(dat_csv), c(7L, 7L))
  expect_equal(which(is.na(dat_csv$country)), c(3L, 5L))
  expect_equal(which(is.na(dat_csv$year)), c(5L, 6L))
  expect_equal(which(is.na(dat_csv$pop)), 5L)
  expect_true(all(is.na(dat_csv[[4]])))
  expect_equal(which(is.na(dat_csv$X5)), c(2L, 5L))
  expect_equal(which(is.na(dat_csv$lifeExp)), 5L)
  expect_equal(which(is.na(dat_csv$gdpPercap)), 4:5)

  ## type depends on readr, which has met difficulties updating on CRAN
  var_class <- vapply(dat_csv, class, character(1))
  expect_identical(
    var_class[c("country", "X4", "X5", "lifeExp", "gdpPercap")],
    c(country = "character", X4 = "logical", X5 = "character",
      lifeExp = "numeric", gdpPercap = "numeric")
  )
  expect_true(all(var_class[c("year", "pop")] %in% c("integer", "numeric")))
})

test_that("We can handle embedded empty cells via list feed", {

  dat_lf <- ss %>% gs_read_listfeed("embedded_empty_cells")
  ## compare with csv!
  ## the blank column is dropped
  ## data reading stops at the empty row
  expect_equal(dim(dat_lf), c(4L, 6L))

  expect_equal(which(is.na(dat_lf$country)), 3L)
  expect_equal(which(is.na(dat_lf$X4)), 2L)
  expect_equal(which(is.na(dat_lf$gdpPercap)), 4L)

  ## type depends on readr, which has met difficulties updating on CRAN
  var_class <- vapply(dat_lf, class, character(1))
  expect_identical(
    var_class[c("country", "lifeExp", "gdpPercap")],
    c(country = "character", lifeExp = "numeric", gdpPercap = "numeric")
  )
  expect_true(all(var_class[c("year", "pop")] %in% c("integer", "numeric")))
  expect_true(var_class["X4"] %in% c("character", "logical"))
})

test_that("We can handle embedded empty cells via cell feed", {

  expect_warning(
    dat_csv <- ss %>% gs_read_csv("embedded_empty_cells"),
    "Missing column names filled in"
  )

  raw_cf <- ss %>% gs_read_cellfeed("embedded_empty_cells")
  expect_equal(dim(raw_cf), c(37L, 7L))

  dat_cf <- raw_cf %>% gs_reshape_cellfeed()
  expect_equal(dim(dat_cf), c(7L, 7L))

  expect_equal(dat_cf, dat_csv)

  raw_cf <- ss %>%
    gs_read_cellfeed("embedded_empty_cells", return_empty = TRUE)
  expect_equal(dim(raw_cf), c(56L, 7L))
  dat_cf <- raw_cf %>% gs_reshape_cellfeed()
  expect_equivalent(dat_cf, dat_csv)

})

test_that("Special Characters can be imported correctly", {
  skip("Subject to type discrepancies due to readr version.")
  expect_equal_to_reference(gs_read_listfeed(ss, ws = "special_chars"),
                            test_path("for_reference/pts_special_chars.rds"))

})

test_that("We can cope with tricky column names", {

  row_one <- c("id", "content", "4.3", "", "lifeExp",
               "", "Fahrvergnügen", "Hey space")
  row_one_no_empty <- row_one[row_one != ""]
  vnames <- c("id", "content", "4.3", "X4", "lifeExp",
              "X6", "Fahrvergnügen", "Hey space")

  ## FYI this is as much about documenting what happens with weird names, as it
  ## is about testing

  expect_warning(
    diabolical <- gs_read_csv(ss, "diabolical_column_names"),
    "Missing column names filled in"
  )
  expect_identical(dim(diabolical), c(3L, 8L))
  expect_identical(names(diabolical), vnames)

  ## empty cells will not be here ...
  diabolical <- gs_read_cellfeed(ss, "diabolical_column_names")
  expect_identical(dim(diabolical), c(30L, 7L))
  expect_identical(diabolical$value[diabolical$row == 1L], row_one_no_empty)

  ## but reshaping will create variables when data exists, even in absence of
  ## column name
  diabolical <- diabolical %>% gs_reshape_cellfeed()
  expect_identical(dim(diabolical), c(3L, 8L))
  expect_identical(names(diabolical), vnames)

  ## empty cells WILL be here ...
  diabolical <-
    gs_read_cellfeed(ss, "diabolical_column_names", return_empty = TRUE)
  expect_identical(dim(diabolical), c(32L, 7L))
  expect_identical(diabolical$value[diabolical$row == 1L], row_one)
  diabolical <- diabolical %>% gs_reshape_cellfeed()
  expect_identical(dim(diabolical), c(3L, 8L))
  expect_identical(names(diabolical), vnames)

})

test_that("we don't error on a sheet with only colnames", {
  expect_equivalent(ss %>% gs_read("colnames_only"),
                    dplyr::data_frame(V1 = logical(), V2 = logical()))
  expect_equivalent(ss %>% gs_read_csv("colnames_only"),
                    dplyr::data_frame(V1 = logical(), V2 = logical()))
  ## retval is truly empty because variable names can only discovered from
  ## actual row data, of which there is none
  expect_identical(ss %>% gs_read_listfeed("colnames_only"),
                   dplyr::data_frame())
  ## checking only for equality because cellfeed retval has ws_title as
  ## attribute
  expect_equal(ss %>% gs_read_cellfeed("colnames_only"),
               dplyr::data_frame(cell = c("A1", "B1"),
                                 cell_alt = c("R1C1", "R1C2"),
                                 row = 1L,
                                 col = 1:2,
                                 value = c("V1", "V2"),
                                 input_value = c("V1", "V2"),
                                 numeric_value = NA_character_))
})
