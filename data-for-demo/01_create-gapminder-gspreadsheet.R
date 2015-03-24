#' ---
#' output: md_document
#' ---

library("gapminder")
library("gspreadr")
library("plyr")
suppressPackageStartupMessages(library("dplyr"))

## damn you render and your hard-wiring of wd = dir where file lives!
## if I don't commit this abomination, existing .httr-oauth cannot be found :(
if (getwd() %>% basename == "data-for-demo") {
  setwd("..")
}

## "make clean"
delete_ss(regex = "^Gapminder$")

gap_ss <- new_ss("Gapminder")

l_ply(levels(gapminder$continent), add_ws, ss = gap_ss)

gap_ss <- gap_ss %>% delete_ws("Sheet1")
gap_ss

upload_times <- llply(levels(gapminder$continent), function(ct) {
  gap_ss %>%
    edit_cells(ws = ct,
               input = gapminder %>% filter(continent == ct),
               header = TRUE, trim = TRUE) %>%
    system.time()
})

slow <- data_frame(continent = levels(gapminder$continent),
                   rows = gapminder %>%
                     group_by(continent) %>% 
                     tally() %>% 
                     `[[`("n"),
                   time = upload_times %>% sapply(`[[`,"elapsed"),
           tpr = time/rows)

slow

sum(slow$time)

gap_ss <- gap_ss %>% register_ss()
gap_ss
