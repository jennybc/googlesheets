library(rdrop2)

drop_dir()

butler_pics <- drop_dir("Butler pics")

dir.create("pics")

jfun <- function(x)
  drop_get(x, file.path("pics", basename(x)), overwrite = TRUE)
vapply(butler_pics$path, jfun, logical(1))

## JPG names were edited manually
