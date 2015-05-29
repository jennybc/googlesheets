context("consume tricky data")

ss <- gs_key(pts_key, lookup = FALSE, visibility = "public", verbose = FALSE)

test_that("We can handle embedded empty cells via csv", {

  dat_csv <- ss %>% gs_read_csv("embedded_empty_cells")
  expect_equal(dim(dat_csv), c(7L, 7L))
  expect_equal(which(is.na(dat_csv$country)), c(3L, 5L))
  expect_equal(which(is.na(dat_csv$year)), c(5L, 6L))
  expect_equal(which(is.na(dat_csv$pop)), 5L)
  expect_true(all(is.na(dat_csv$X)))
  expect_equal(which(is.na(dat_csv$continent)), c(2L, 5L))
  expect_equal(which(is.na(dat_csv$lifeExp)), 5L)
  expect_equal(which(is.na(dat_csv$gdpPercap)), 4:5)

  expect_equal(vapply(dat_csv, class, character(1)),
               c(country = "character", year = "integer", pop = "integer",
                 X = "logical", continent = "character",
                 lifeExp = "numeric", gdpPercap = "numeric"))

})

test_that("We can handle embedded empty cells via list feed", {

  dat <- ss %>% gs_read_listfeed("embedded_empty_cells")
  ## compare with csv!
  ## the blank column is dropped
  ## data reading stops at the empty row
  expect_equal(dim(dat), c(4L, 6L))

  expect_equal(which(is.na(dat$country)), 3L)
  expect_equal(which(is.na(dat$continent)), 2L)
  expect_equal(which(is.na(dat$gdppercap)), 4L) # gdppercap has been lowercased

  expect_equal(vapply(dat, class, character(1)),
               c(country = "character", year = "integer", pop = "integer",
                 continent = "character", lifeexp = "numeric",
                 gdppercap = "numeric"))

})

test_that("We can handle embedded empty cells via cell feed", {

  ## for comparison
  dat_csv <- ss %>% gs_read_csv("embedded_empty_cells")

  raw_cf <- ss %>% gs_read_cellfeed("embedded_empty_cells")
  expect_equal(dim(raw_cf), c(38L, 5L))

  dat_cf <- raw_cf %>% gs_reshape_cellfeed()
  expect_equal(dim(dat_cf), c(7L, 7L))
  ## converting to data.frames for test because of this
  ## https://github.com/hadley/dplyr/issues/1095
  ## bug (now fixed) where NA_character_ mishandled by all.equal
  class(dat_cf) <- "data.frame"
  class(dat_csv) <- "data.frame"
  expect_identical(dat_cf, dat_csv %>% dplyr::rename(X4 = X))

  raw_cf <- ss %>%
    gs_read_cellfeed("embedded_empty_cells", return_empty = TRUE)
  expect_equal(dim(raw_cf), c(56L, 5L))
  dat_cf <- raw_cf %>% gs_reshape_cellfeed()
  class(dat_cf) <- "data.frame"

  ## when return_empty = TRUE, empty character cells show up as "", not
  ## NA_character_
  ## also the missing variable name is "X" from the cell feed ... comply here
  dat_cf <- dat_cf %>%
    dplyr::mutate(country = ifelse(country == "", NA, country),
                  continent = ifelse(continent == "", NA, continent)) %>%
    dplyr::rename(X = X4)

  expect_identical(dat_cf, dat_csv)

})

test_that("Special Characters can be imported correctly", {

  expect_equal_to_reference(gs_read_listfeed(ss, ws = "special_chars"),
                            "pts_special_chars.rds")

})

test_that("We can cope with tricky column names", {

  ## FYI this is as much about documenting what happens with weird names, as it
  ## is about testing

  diabolical <- gs_read_csv(ss, "diabolical_column_names")
  expect_identical(dim(diabolical), c(3L, 8L))
  expect_identical(names(diabolical),
                   c("id", "content", "X4.3", "X", "lifeExp", "X.1",
                     "Fahrvergnügen", "Hey.space"))

  ## wait to deal with the list feed after I merge this and then merge the
  ## 'switch-to-xml2' branch ... the overlap with boilerplate names will be
  ## resolved with superior XML parsing and namespace handling
#   diabolical <- get_via_lf(ss, "diabolical_column_names")
#   Source: local data frame [3 x 6]
#     _cpzh4 _cre1l lifeexp _ciyn3 fahrvergnügen heyspace
#   1    jan  alpha     uno spring           ein      mon
#   2    feb   beta     dos summer          zwei     tues
#   3    mar  gamma    tres   fall          drei      wed

  ## empty cells will not be here ...
  diabolical <- gs_read_cellfeed(ss, "diabolical_column_names")
  expect_identical(dim(diabolical), c(30L, 5L))
  expect_identical(diabolical$cell_text[diabolical$row == 1L],
                   c("id", "content", "4.3", "lifeExp",
                     "Fahrvergnügen", "Hey space"))
  ## but reshaping will create variables when data exists, even in absence of
  ## column name
  diabolical <- diabolical %>%
    gs_reshape_cellfeed()
  expect_identical(dim(diabolical), c(3L, 8L))
  expect_identical(names(diabolical),
                   c("id", "content", "X4.3", "X4", "lifeExp", "X6",
                     "Fahrvergnügen", "Hey.space"))

  ## empty cells WILL be here ...
  diabolical <-
    gs_read_cellfeed(ss, "diabolical_column_names", return_empty = TRUE)
  expect_identical(dim(diabolical), c(32L, 5L))
  expect_identical(diabolical$cell_text[diabolical$row == 1L],
                   c("id", "content", "4.3", "", "lifeExp", "",
                     "Fahrvergnügen", "Hey space"))
  diabolical <- diabolical %>%
    gs_reshape_cellfeed()
  expect_identical(dim(diabolical), c(3L, 8L))
  expect_identical(names(diabolical),
                   c("id", "content", "X4.3", "X4", "lifeExp", "X6",
                     "Fahrvergnügen", "Hey.space"))

})
