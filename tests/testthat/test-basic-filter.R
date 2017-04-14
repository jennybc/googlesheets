context("working with basic filters")

# load spreadsheet

# requires a spreadsheet to work
# test_that("Set & Clear Basic Filter", {
#   gs_set_basic_filter(gap_ss, ws = 1)
#   
#   gs_clear_basic_filter(gap_ss, ws = 1)
# })
# 
# test_that("Set Basic Filter with Sorting", {
#   gs_set_basic_filter(gap_ss, ws = "Americas",
#                       range = cell_cols(3:6),
#                       sort_spec = list(list(2, "DESCENDING")))
#   
#   # read back the columns 3 thru 6 and see if the 
#   # second column really is sorted descending?
# })
# 
# test_that("Set Basic Filter with Filter Criteria", {
# 
#   gs_set_basic_filter(gap_ss, ws = 1,
#                       range = cell_cols(5:6),
#                       criteria = list(list(3, "NUMBER_LESS", 1970)))
#   
#   gs_set_basic_filter(gap_ss, ws = "Americas",
#                       sort_spec = list(list(3, "DESCENDING")),
#                       criteria = list(list(4, "NUMBER_LESS", 50),
#                                       list(6, "NUMBER_GREATER_THAN_EQ", 1000)))
# })
