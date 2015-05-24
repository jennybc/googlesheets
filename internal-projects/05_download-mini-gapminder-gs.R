#' ---
#' output: md_document
#' ---

## the point of this is to use test-gs-mini-gapminder (owned by rpackagetest) to
## download the gapminder objects used in our own tests

library("googlesheets")

## damn you render and your hard-wiring of wd = dir where file lives!
## if I don't commit this abomination, existing .httr-oauth cannot be found :(
if (basename(getwd()) == "data-for-demo") {
  setwd("..")
}
TESTDIR <- file.path("tests", "testthat")

mini_gap_key <- "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY"
mini_gap <- identify_ss(mini_gap_key, method = "key",
                        verify = FALSE, visibility = "public")
mini_gap <- register_ss(ws_feed = mini_gap$ws_feed)
mini_gap

fmts <- c("xlsx", "csv")
to_files <- file.path(TESTDIR, paste0("mini-gap.", fmts))
download_ss(from = mini_gap, to = to_files[1], overwrite = TRUE)
download_ss(from = mini_gap, to = to_files[2], overwrite = TRUE)
lapply(to_files, function(x)
  download_ss(from = mini_gap, to = x, overwrite = TRUE))

## `tsv` can be done via the browser but not via download_ss(), so we fake it
## below

mini_gap_csv <- read.csv(to_files[2])

write.table(mini_gap_csv, file.path(TESTDIR, "mini-gap.tsv"), quote = FALSE,
            sep = "\t", row.names = FALSE)

## `txt` cannot be done via the browser or via API, so we fake it below
write.table(mini_gap_csv, file.path(TESTDIR, "mini-gap.txt"), quote = FALSE,
            row.names = FALSE)

## download as `ods` can be done via the browser but not via download_ss(), so
## that's unavoidably manual :(
