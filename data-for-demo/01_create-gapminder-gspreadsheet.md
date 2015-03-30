    library("gapminder")
    library("googlesheets")
    library("plyr")
    suppressPackageStartupMessages(library("dplyr"))

    ## damn you render and your hard-wiring of wd = dir where file lives!
    ## if I don't commit this abomination, existing .httr-oauth cannot be found :(
    if (getwd() %>% basename == "data-for-demo") {
      setwd("..")
    }

    ## "make clean"
    delete_ss("^Gapminder$")

    ## No matching sheets found.

    gap_ss <- new_ss("Gapminder")

    ## Sheet "Gapminder" created in Google Drive.
    ## Identifying info is a gspreadsheet object; gspreadr will re-identify the sheet based on sheet key.
    ## Sheet identified!
    ## sheet_title: Gapminder
    ## sheet_key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA

    l_ply(levels(gapminder$continent), add_ws, ss = gap_ss)

    ## Worksheet "Africa" added to sheet "Gapminder".
    ## Worksheet "Americas" added to sheet "Gapminder".
    ## Worksheet "Asia" added to sheet "Gapminder".
    ## Worksheet "Europe" added to sheet "Gapminder".
    ## Worksheet "Oceania" added to sheet "Gapminder".

    gap_ss <- gap_ss %>% delete_ws("Sheet1")

    ## Worksheet "Sheet1" deleted from sheet "Gapminder".

    str(gap_ss)

    ##               Spreadsheet title: Gapminder
    ##   Date of gspreadr::register_ss: 2015-03-23 13:29:48 PDT
    ## Date of last spreadsheet update: 2015-03-23 20:29:47 UTC
    ## 
    ## Contains 5 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## Africa: 1000 x 26
    ## Americas: 1000 x 26
    ## Asia: 1000 x 26
    ## Europe: 1000 x 26
    ## Oceania: 1000 x 26
    ## 
    ## Key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA

    upload_times <- llply(levels(gapminder$continent), function(ct) {
      gap_ss %>%
        edit_cells(ws = ct,
                   input = gapminder %>% filter(continent == ct),
                   header = TRUE, trim = TRUE) %>%
        system.time()
    })

    ## Range affected by the update: "A1:F625"
    ## Worksheet "Africa" successfully updated with 3750 new value(s).
    ## Worksheet "Africa" dimensions changed to 625 x 6.
    ## Range affected by the update: "A1:F301"
    ## Worksheet "Americas" successfully updated with 1806 new value(s).
    ## Worksheet "Americas" dimensions changed to 301 x 6.
    ## Range affected by the update: "A1:F397"
    ## Worksheet "Asia" successfully updated with 2382 new value(s).
    ## Worksheet "Asia" dimensions changed to 397 x 6.
    ## Range affected by the update: "A1:F361"
    ## Worksheet "Europe" successfully updated with 2166 new value(s).
    ## Worksheet "Europe" dimensions changed to 361 x 6.
    ## Range affected by the update: "A1:F25"
    ## Worksheet "Oceania" successfully updated with 150 new value(s).
    ## Worksheet "Oceania" dimensions changed to 25 x 6.

    slow <- data_frame(continent = levels(gapminder$continent),
                       rows = gapminder %>%
                         group_by(continent) %>% 
                         tally() %>% 
                         `[[`("n"),
                       time = upload_times %>% sapply(`[[`,"elapsed"),
               tpr = time/rows)

    slow

    ## Source: local data frame [5 x 4]
    ## 
    ##   continent rows    time        tpr
    ## 1    Africa  624  50.508 0.08094231
    ## 2  Americas  300  25.107 0.08369000
    ## 3      Asia  396  32.112 0.08109091
    ## 4    Europe  360  27.079 0.07521944
    ## 5   Oceania   24 126.545 5.27270833

    sum(slow$time)

    ## [1] 261.351

    gap_ss <- gap_ss %>% register_ss()

    ## Identifying info is a gspreadsheet object; gspreadr will re-identify the sheet based on sheet key.
    ## Sheet identified!
    ## sheet_title: Gapminder
    ## sheet_key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA

    str(gap_ss)

    ##               Spreadsheet title: Gapminder
    ##   Date of gspreadr::register_ss: 2015-03-23 13:34:10 PDT
    ## Date of last spreadsheet update: 2015-03-23 20:34:08 UTC
    ## 
    ## Contains 5 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## Africa: 625 x 6
    ## Americas: 301 x 6
    ## Asia: 397 x 6
    ## Europe: 361 x 6
    ## Oceania: 25 x 6
    ## 
    ## Key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
