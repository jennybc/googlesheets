## no test shall modify any existing sheets owned by rpackagetest (unlikely,
## since tests are not run with this authorization) or gspreadr (much higher
## risk!)

## before any test that does sheet editing, create a copy of some existing sheet
## to work with

## use `p_()` to construct names for any such sheets or any sheets created via
## tests

## why? so that concurrent testing runs do not interfere with each other

## also easier to clean out files from testing

slug <- paste("test-gs", Sys.info()["user"], "", sep = "-")

TEST <- tempfile(slug, tmpdir = "") %>% basename

p_ <- function(x) paste(TEST, x, sep = "-")
