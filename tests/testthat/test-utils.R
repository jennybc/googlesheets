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
