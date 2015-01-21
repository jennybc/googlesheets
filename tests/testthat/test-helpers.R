context("helper functions")

test_that("Column letter converts to correct column number", {
  
  expect_equal(letter_to_num("A"), 1)
  expect_equal(letter_to_num("Z"), 26)
  expect_equal(letter_to_num("AB"), 28)
})

test_that("Column number converts to correct column letter", {
  
  expect_equal(num_to_letter(1), "A")
  expect_equal(num_to_letter(28), "AB")
  expect_equal(num_to_letter(26), "Z")
})


test_that("A1 notation converts to R1C1 notation", {
  
  expect_equal(label_to_coord("A1"), "R1C1")
  expect_equal(label_to_coord("AB10"), "R10C28")
})


test_that("R1C1 notation converts to A1 notation", {
  
  expect_equal(coord_to_label("R1C1"), "A1")
  expect_equal(coord_to_label("R10C28"), "AB10")
})


test_that("Header is set", {
  x <- data.frame(1:5, 1:5)
  
  expect_equal(nrow(set_header(x)), nrow(x) - 1)
})


test_that("Count the correct number of cells in the range", {
  
  expect_equal(ncells("A1:A1"), 1)
  expect_equal(ncells("B2:I22"), 168)
  expect_equal(ncells("C1:A1"), 3)
})


test_that("Range occupied by dataframe is correct", {
  
  dat <- data.frame(a = 1:3, b = 1:3, c = 1:3)
  
  vec <- c(1:3)
  
  expect_equal(build_range(dat, "A1", header = TRUE), "A1:C4")
  expect_equal(build_range(dat, "A1", header = FALSE), "A1:C3")
  expect_equal(build_range(vec, "C1"), "C1:E1")
})


test_that("Fill in missing columns", {
  
  dat <- data.frame("row" = c(1, 1), "col" = c(1, 3), 
                    "val" = c("Val1", "Val2"))
  
  new_dat <- fill_missing_col(dat, 1)
  expect_equal(nrow(new_dat), 3)
  expect_true(2 %in% new_dat$col)
  expect_true(NA %in% new_dat$val)
  
})


test_that("Fill in missing rows", {
  
  dat <- data.frame("row" = c(1, 3), "col" = c(1, 1), 
                    "val" = c("Val1", "Val2"))
  
  new_dat <- fill_missing_row(dat, 1)
  expect_equal(nrow(new_dat), 3)
  expect_true(2 %in% new_dat$row)
  expect_true(NA %in% new_dat$val)
  
})


test_that("Lookup table is made and filled", {
  
  the_url <- paste0("https://spreadsheets.google.com/feeds/cells/",
                    "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/opero9d/",
                    "public/full?&min-col=1&max-col=7")
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  x <- get_lookup_tbl(feed)
  
  expect_equal(nrow(x), 42)

  new_x <- fill_missing_tbl(x)

  expect_equal(nrow(new_x), nrow(x) + 7)
  expect_true(4 %in% new_x$col)
  expect_true(NA %in% new_x$val)
  
  new_x_1 <- fill_missing_tbl(x, row_only = TRUE)

  expect_equal(nrow(new_x_1), nrow(x))
})


test_that("Worksheet is empty", {
  sheet1 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk",
                        visibility = "public")

  wks <- open_worksheet(sheet1, "Blank")
  
  expect_error(check_empty(wks), "Worksheet does not contain any values.")
})


test_that("Worksheet dimensions are correct", {
  
  sheet1 <- open_by_key("1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", 
                        visibility = "public")
  
  ws <- sheet1$worksheets[[5]]
  ws$visibility <- "public"
  ws <- worksheet_dim(ws)
  
  expect_equal(ws$nrow, 7)
  expect_equal(ws$ncol, 7)
})


test_that("Worksheet is plotted", {

tbl <- data.frame("row" = c(1, 1, 1), "col" = c(1, 2, 3), "val" = c(0, 0, 0))

expect_that(make_plot(tbl), is_a("ggplot"))
})


## Hard to test : ssfeed_to_df(), create_update_feed(), make_entry_node()

# test_that("Info from spreadsheets feed put into data frame", {
#   
#   dat <- ssfeed_to_df()
#   
#   expect_equal(ncol(dat), 5)
# })
