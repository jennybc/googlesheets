## clean up all crap potentially left behind by aborted
##   * testing runs
##   * compilations of README.Rmd
##   * compilations of vignettes/basic-usage.Rmd

## in theory we clean up as we go, but ... reality

## this is going to take a while to develop but it should pay off with fewer
## failed travis builds

## cleaning up after actions in context("edit sheets")
my_patterns <- c("testing[0-9]{1}", "gap-data",
                 paste("Copy of", pts_title),
                 "eggplants are purple",
                 "cat", "catherine", "tomCAT", "abdicate", "FLYCATCHER",
                 "test-old-sheet-copy")
my_patterns <- my_patterns %>% stringr::str_c(collapse = "|")
delete_ss(regex = my_patterns, verbose = FALSE)

pts <- register_ss(pts_title, verbose = FALSE)
if("Test Sheet" %in% pts$ws$ws_title) {
  pts <- delete_ws(pts, "Test Sheet", verbose = FALSE)
}
if("Somewhere in Asia" %in% pts$ws$ws_title) {
  pts <- rename_ws(pts, "Somewhere in Asia", "Asia", verbose = FALSE)
}
pts <- googlesheets:::resize_ws(pts, "for_resizing", row_extent = 1000,
                                col_extent = 26, verbose = FALSE)

## cleaning up after actions in context("edit cells")
pts <- register_ss(pts_title, verbose = FALSE)
ws <- "for_updating"

# update with empty strings to "clear" cells
pts <- pts %>% googlesheets:::resize_ws(ws, 10, 26, verbose = FALSE)
input <- matrix("", nrow = 10, ncol = 26)
pts <- pts %>% edit_cells(ws, input, verbose = FALSE)
