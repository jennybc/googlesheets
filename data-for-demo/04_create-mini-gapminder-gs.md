    ## the point of this is to create a sheet based on gapminder but that is quite
    ## small

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
    delete_ss(regex = "^test-gs-mini-gapminder$")

    ## Sheets found and slated for deletion:
    ## test-gs-mini-gapminder
    ## Success. All moved to trash in Google Drive.

    gap_ss <- new_ss("test-gs-mini-gapminder")

    ## Sheet "test-gs-mini-gapminder" created in Google Drive.
    ## Identifying info is a googlesheet object; googlesheets will re-identify the sheet based on sheet key.
    ## Sheet identified!
    ## sheet_title: test-gs-mini-gapminder
    ## sheet_key: 1Hm4HCrI0UsN0eVFXbRHY9JI4Lhdy8HWE8qevZzGmWDs

    l_ply(levels(gapminder$continent), add_ws, ss = gap_ss)

    ## Worksheet "Africa" added to sheet "test-gs-mini-gapminder".
    ## Worksheet "Americas" added to sheet "test-gs-mini-gapminder".
    ## Worksheet "Asia" added to sheet "test-gs-mini-gapminder".
    ## Worksheet "Europe" added to sheet "test-gs-mini-gapminder".
    ## Worksheet "Oceania" added to sheet "test-gs-mini-gapminder".

    gap_ss <- gap_ss %>% delete_ws("Sheet1")

    ## Accessing worksheet titled "Sheet1"
    ## Worksheet "Sheet1" deleted from sheet "test-gs-mini-gapminder".

    gap_ss

    ##                   Spreadsheet title: test-gs-mini-gapminder
    ##   Date of googlesheets::register_ss: 2015-04-25 18:17:30 GMT
    ##     Date of last spreadsheet update: 2015-04-25 18:17:29 GMT
    ##                          visibility: private
    ## 
    ## Contains 5 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## Africa: 1000 x 26
    ## Americas: 1000 x 26
    ## Asia: 1000 x 26
    ## Europe: 1000 x 26
    ## Oceania: 1000 x 26
    ## 
    ## Key: 1Hm4HCrI0UsN0eVFXbRHY9JI4Lhdy8HWE8qevZzGmWDs

    upload_times <- llply(levels(gapminder$continent), function(ct) {
      gap_ss %>%
        edit_cells(ws = ct,
                   input = gapminder %>%
                     filter(continent == ct) %>%
                     arrange(year) %>%
                     slice(1:5),
                   header = TRUE, trim = TRUE) %>%
        system.time()
    })

    ## Range affected by the update: "A1:F6"
    ## Worksheet "Africa" successfully updated with 36 new value(s).
    ## Accessing worksheet titled "Africa"
    ## Worksheet "Africa" dimensions changed to 6 x 6.
    ## Range affected by the update: "A1:F6"
    ## Worksheet "Americas" successfully updated with 36 new value(s).
    ## Accessing worksheet titled "Americas"
    ## Worksheet "Americas" dimensions changed to 6 x 6.
    ## Range affected by the update: "A1:F6"
    ## Worksheet "Asia" successfully updated with 36 new value(s).
    ## Accessing worksheet titled "Asia"
    ## Worksheet "Asia" dimensions changed to 6 x 6.
    ## Range affected by the update: "A1:F6"
    ## Worksheet "Europe" successfully updated with 36 new value(s).
    ## Accessing worksheet titled "Europe"
    ## Worksheet "Europe" dimensions changed to 6 x 6.
    ## Range affected by the update: "A1:F6"
    ## Worksheet "Oceania" successfully updated with 36 new value(s).
    ## Accessing worksheet titled "Oceania"
    ## Worksheet "Oceania" dimensions changed to 6 x 6.

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
    ##   continent rows  time        tpr
    ## 1    Africa  624 7.804 0.01250641
    ## 2  Americas  300 7.604 0.02534667
    ## 3      Asia  396 7.472 0.01886869
    ## 4    Europe  360 7.185 0.01995833
    ## 5   Oceania   24 6.853 0.28554167

    sum(slow$time)

    ## [1] 36.918

    gap_ss <- gap_ss %>% register_ss()

    ## Identifying info is a googlesheet object; googlesheets will re-identify the sheet based on sheet key.
    ## Sheet identified!
    ## sheet_title: test-gs-mini-gapminder
    ## sheet_key: 1Hm4HCrI0UsN0eVFXbRHY9JI4Lhdy8HWE8qevZzGmWDs

    gap_ss

    ##                   Spreadsheet title: test-gs-mini-gapminder
    ##   Date of googlesheets::register_ss: 2015-04-25 18:18:08 GMT
    ##     Date of last spreadsheet update: 2015-04-25 18:18:05 GMT
    ##                          visibility: private
    ## 
    ## Contains 5 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## Africa: 6 x 6
    ## Americas: 6 x 6
    ## Asia: 6 x 6
    ## Europe: 6 x 6
    ## Oceania: 6 x 6
    ## 
    ## Key: 1Hm4HCrI0UsN0eVFXbRHY9JI4Lhdy8HWE8qevZzGmWDs
