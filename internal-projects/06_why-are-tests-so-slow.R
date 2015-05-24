#' ---
#' title: "Find out which tests are so slow"
#' author: "Jenny Bryan"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---

library("plyr")
library("dplyr")
library("ggplot2")
library("testthat")

## damn you render and your hard-wiring of wd = dir where file lives!
## if I don't commit this abomination, existing .httr-oauth cannot be found :(
if (basename(getwd()) == "data-for-demo") {
  setwd("..")
}

devtools::load_all()

foo <- test_dir("tests/testthat/")

tdat <- ldply(foo, function(x)
  data_frame(file = x$file, context = x$context, test = x$test,
             user = x$user, system = x$system, real = x$real))

tdat <- tdat %>%
  arrange(desc(real)) %>%
  filter(min_rank(real) > 20) %>%
  mutate(test = factor(test, levels = rev(test)))

p <- ggplot(tdat, aes(x = test, y = real, fill = context))
p + geom_bar(stat = "identity") + coord_flip() +
  guides(fill = FALSE)
