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

    ## Identifying info will be handled as: key.
    ## Unverified sheet key: 1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY.

    mini_gap <- register_ss(ws_feed = mini_gap$ws_feed)
    mini_gap

    ##                   Spreadsheet title: test-gs-mini-gapminder
    ##   Date of googlesheets::register_ss: 2015-04-25 19:00:05 GMT
    ##     Date of last spreadsheet update: 2015-04-25 18:23:09 GMT
    ##                          visibility: public
    ## 
    ## Contains 5 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## Africa: 6 x 6
    ## Americas: 6 x 6
    ## Asia: 6 x 6
    ## Europe: 6 x 6
    ## Oceania: 6 x 6
    ## 
    ## Key: 1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY

    fmts <- c("xlsx", "csv")
    to_files <- file.path(TESTDIR, paste0("mini-gap.", fmts))
    download_ss(from = mini_gap, to = to_files[1], overwrite = TRUE)

    ## Sheet successfully downloaded: /Users/jenny/research/googlesheets/tests/testthat/mini-gap.xlsx

    download_ss(from = mini_gap, to = to_files[2], overwrite = TRUE)

    ## Sheet successfully downloaded: /Users/jenny/research/googlesheets/tests/testthat/mini-gap.csv

    lapply(to_files, function(x)
      download_ss(from = mini_gap, to = x, overwrite = TRUE))

    ## Sheet successfully downloaded: /Users/jenny/research/googlesheets/tests/testthat/mini-gap.xlsx
    ## Sheet successfully downloaded: /Users/jenny/research/googlesheets/tests/testthat/mini-gap.csv

    ## [[1]]
    ## NULL
    ## 
    ## [[2]]
    ## NULL

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
