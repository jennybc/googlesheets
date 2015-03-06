context("updating cell values")

test_that("Cells are updated", {
  
  ss <- register_ss(pts_title)
  
  ws_title <- "for_updating"
  small_df1 <- data.frame("Apples" = 1, "Oranges" = 2)
  small_df2 <- data.frame("a" = 98:100, "b" = 98:100, "c" = 98:100)
  
  # Bad input
  expect_error(update_cells(ss, ws_title, "A1:A5", c(1,2,3)), "does not match")
  
  # update 1 cell
  expect_message(update_cells(ss, ws_title, "A1", "Bananas"), 
                 "successfully updated") 
  
  # update >1 cell, ref cell given
  expect_message(update_cells(ss, ws_title, "B1", small_df1), 
                 "successfully updated")
  
  # update >1 cell, range given
  expect_message(update_cells(ss, ws_title, "A2:C3", 1:6),
                 "successfully updated")
  
  expect_message(update_cells(ss, ws_title, "R4C1:R7C3", small_df2),
                 "successfully updated")
  
  expect_true(all(c("Bananas", "Apples", "Oranges", 1:6, "a", "b", "c", 98:100) %in% 
                get_cells(ss, ws = ws_title, "A1:C7")$cell_text))

  # update with empty strings to "clear" cells -> cells wont be returned in cf
  ss <- update_cells(ss, ws_title, "A4:C7", rep("", 12))
  expect_equal(get_via_cf(ss, ws_title) %>% nrow, 9)
  
  expect_message(ss <- update_cells(ss, ws_title, "AA1", "Way out there!"), 
                 "dimensions changed")
  # clean up
  resize_ws(ss, ws_title, 1000, 26)
})