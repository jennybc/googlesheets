context("utility functions")

test_that("Column letter converts to correct column number", {
  
  expect_equal(letter_to_num("A"), 1)
  expect_equal(letter_to_num("Z"), 26)
  expect_equal(letter_to_num("AB"), 28)
  expect_equal(letter_to_num(c("A", "Z", "AB")), c(1, 26, 28))

})

test_that("Column number converts to correct column letter", {
  
  expect_equal(num_to_letter(1), "A")
  expect_equal(num_to_letter(28), "AB")
  expect_equal(num_to_letter(26), "Z")
  expect_error(num_to_letter(703))
  
})

test_that("A1 notation converts to R1C1 notation", {
  
  expect_equal(label_to_coord("A1"), "R1C1")
  expect_equal(label_to_coord("AB10"), "R10C28")
  expect_equal(label_to_coord(c("A1", "AB10")), c("R1C1", "R10C28"))

})


test_that("R1C1 notation converts to A1 notation", {
  
  expect_equal(coord_to_label("R1C1"), "A1")
  expect_equal(coord_to_label("R10C28"), "AB10")
  expect_equal(coord_to_label(c("R1C1", "R10C28")), c("A1", "AB10"))
  
})

ss <- register_ss(ws_feed = pts_ws_feed)

test_that("We can obtain worksheet info from a registered spreadsheet", {

  ## retrieve by worksheet title
  africa <- get_ws(ss, "Africa")
  expect_equal(africa$ws_title, "Africa")
  expect_equal(africa$row_extent, 1000L)
  
  ## retrieve by positive integer
  europe <- get_ws(ss, 4)
  expect_equal(europe$ws_title, "Europe")
  expect_equal(africa$col_extent, 26L)
  
  ## doubles get truncated, i.e. 1.3 --> 1
  asia <- get_ws(ss, 1.3)
  expect_equal(asia$ws_title, "Asia")

})

test_that("We throw error for bad worksheet request", {

  expect_error(get_ws(ss, -3))
  expect_error(get_ws(ss, factor(1)))
  expect_error(get_ws(ss, LETTERS))
  
  expect_error(get_ws(ss, "Mars"), "not found")
  expect_error(get_ws(ss, 100L), "only contains")
    
})

test_that("We can a extract a key from a URL", {
  
  # new style URL
  expect_equal(extract_key_from_url(pts_url), pts_key)
  
  # old style URL
  #expect_equal(extract_key_from_url(old_url), old_key)
  # 2015-02-27 Anecdotally it appears you cannot extract current keys for use
  # with the API from old style Sheets URLs ... must identify via title, I
  # guess?
  
  # worksheets feed
  expect_equal(extract_key_from_url(pts_ws_feed), pts_key)
  
})
