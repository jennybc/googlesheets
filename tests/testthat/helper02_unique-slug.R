slug <- paste("test-gs", Sys.info()["user"], "", sep = "-")

TEST <- tempfile(slug, tmpdir = "") %>% basename()

p_ <- function(x) paste(TEST, x, sep = "-")
