context("edit worksheets")

activate_test_token()

pts_copy <- p_("pts-copy")
ss <- gs_copy(gs_key(pts_key, lookup = FALSE, verbose = FALSE),
              to = pts_copy, verbose = FALSE)

test_that("Add a new worksheet", {

  ss_before <- ss
  ss_after <-
    gs_ws_new(ss_before, "Test Sheet", input = head(iris), trim = TRUE)
  expect_is(ss_after, "googlesheet")

  new_ws_index <- ss_before$n_ws + 1
  expect_equal(new_ws_index, ss_after$n_ws)
  expect_equal(ss_after$ws$row_extent[new_ws_index], 7L)
  expect_equal(ss_after$ws$col_extent[new_ws_index], 5L)
  expect_equal(ss_after$ws$ws_title[new_ws_index], "Test Sheet")

  ## this worksheet gets deleted below

})

test_that("Delete a worksheet by title and index", {

  ss_before <- gs_key(ss$sheet_key)

  expect_message(ss_after <- gs_ws_delete(ss_before, "Test Sheet"), "deleted")

  expect_is(ss_after, "googlesheet")

  expect_equal(ss_before$n_ws - 1, ss_after$n_ws)
  expect_false("Test Sheet" %in% ss_after$ws$ws_title)

  expect_message(ss_after <- gs_ws_new(ss_after, "one more to delete"), "added")
  ws_pos <- match("one more to delete", ss_after$ws$ws_title)
  expect_message(ss_final <- gs_ws_delete(ss_after, ws_pos), "deleted")

  expect_equal(ss_after$n_ws - 1, ss_final$n_ws)
  expect_false("one more to delete" %in% ss_final$ws$ws_title)

  ## can't delete a non-existent worksheet
  expect_error(gs_ws_delete(ss_before, "Hello World"))
})

test_that("Worksheet is renamed by title and index", {

  ss_before <- gs_key(ss$sheet_key)
  ss_after <- gs_ws_rename(ss_before, "shipwrecks", "oops")

  expect_is(ss_after, "googlesheet")
  expect_true("oops" %in% ss_after$ws$ws_title)
  expect_false("shipwrecks" %in% ss_after$ws$ws_title)

  ss_final <- gs_ws_rename(ss_after, 4, "shipwrecks")
  expect_is(ss_final, "googlesheet")
  expect_false("oops" %in% ss_final$ws$ws_title)
  expect_true("shipwrecks" %in% ss_final$ws$ws_title)

  ## renaming not allowed to cause duplication of a worksheet name
  expect_error(gs_ws_rename(ss_final, "shipwrecks", "embedded_empty_cells"),
               "already exists")

})

test_that("Worksheet is resized by title and index", {

  ss_before <- gs_key(ss$sheet_key)

  ws_title_pos <- match("for_resizing", ss_before$ws$ws_title)

  row <- sample(1:20, 2)
  col <- sample(1:10, 2)

  ss_after <- gs_ws_resize(ss_before, "for_resizing",
                           row_extent = row[1], col_extent = col[1])

  expect_equal(ss_after$ws$row_extent[ws_title_pos], row[1])
  expect_equal(ss_after$ws$col_extent[ws_title_pos], col[1])

  ss_final <- gs_ws_resize(ss_after, ws_title_pos,
                           row_extent = row[2], col_extent = col[2])

  expect_equal(ss_final$ws$row_extent[ws_title_pos], row[2])
  expect_equal(ss_final$ws$col_extent[ws_title_pos], col[2])

})

test_that("Worksheet modification errors for invalid args", {

  expect_error(ss %>% gs_ws_rename(to = ss))
  expect_error(ss %>% gs_ws_rename(from = 1:3, to = "yo"))
  expect_error(ss %>% gs_ws_rename(to = LETTERS[1:2]))
  expect_error(ss %>% gs_ws_rename(to = 3))
  expect_error(ss %>% gs_ws_rename(from = ss, to = "yo"))

  expect_error(ss %>% gs_ws_resize(ws = ss))
  expect_error(ss %>% gs_ws_resize(ws = 1:2))
  expect_error(ss %>% gs_ws_resize(ws = LETTERS[1:2]))
  expect_error(ss %>% gs_ws_resize(row_extent = "yo"))
  expect_error(ss %>% gs_ws_resize(row_extent = 1:10))
  expect_error(ss %>% gs_ws_resize(col_extent = exp(1)))

  expect_error(ss %>% gs_ws_modify(from = 1, to = ss))
  expect_error(ss %>% gs_ws_modify(from = 1, to = LETTERS[1:2]))
  expect_error(ss %>% gs_ws_modify(from = 1, new_dim = 1L))
  expect_error(ss %>% gs_ws_modify(from = 1, new_dim = "yo"))

})

gs_grepdel(TEST, verbose = FALSE)
gs_deauth(verbose = FALSE)
