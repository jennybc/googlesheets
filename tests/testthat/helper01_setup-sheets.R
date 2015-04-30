`%>%` <- dplyr::`%>%`

## Gapminder (owned by rpackagetest)
gap_url <- "https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/"
gap_title <- "test-gs-gapminder"
gap_key <- "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"
gap_ws_feed <- construct_ws_feed_from_key(gap_key, "public")

## Mini gapminder (owned by rpackagetest)
mini_gap_url <- "https://docs.google.com/spreadsheets/d/1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY/edit#gid=2141688971"
mini_gap_title <- "test-gs-mini-gapminder"
mini_gap_key <- "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY"
mini_gap_ws_feed <- construct_ws_feed_from_key(mini_gap_key, "public")

## Public testing sheet (owned by rpackagetest)
pts_url <- "https://docs.google.com/spreadsheets/d/1amnxLg9VVDoE6KSIZvutYkEGNgQyJSnLJgHthehruy8/"
pts_title <- "test-gs-public-testing-sheet"
pts_key <- "1amnxLg9VVDoE6KSIZvutYkEGNgQyJSnLJgHthehruy8"
pts_ws_feed <- construct_ws_feed_from_key(pts_key, "public")

## Old sheet (owned by rpackagetest)
# old_url <- "https://docs.google.com/spreadsheet/ccc?key=0Ai6OdwH-k_ZcdElYSWIxNkhwRkMzdnJTenowazFSS3c"
# old_key <- "tIXIb16HpFC3vrSzz0k1RKw"
# old_ws_feed <- "https://spreadsheets.google.com/feeds/worksheets/tIXIb16HpFC3vrSzz0k1RKw/private/values" # it appears only private works for old sheets?
# old_alt_key <- "0Ai6OdwH-k_ZcdElYSWIxNkhwRkMzdnJTenowazFSS3c"
# old_title <- "test-gs-old-sheet"

## Old sheet (owned by gspreadr)
old_url <- "https://docs.google.com/spreadsheet/ccc?key=0Audw-qi1jh3fdDBsbVJTa3VBZW5lRUp5NVhHc1FQaXc"
old_key <- "t0lmRSkuAeneEJy5XGsQPiw"
old_ws_feed <- "https://spreadsheets.google.com/feeds/worksheets/t0lmRSkuAeneEJy5XGsQPiw/private/values" # it appears only private works for old sheets?
old_alt_key <- "0Audw-qi1jh3fdDBsbVJTa3VBZW5lRUp5NVhHc1FQaXc"
old_title <- "test-gs-old-sheet2"

## WTF sheets (owned by gspreadr)
## first sheet -- "Testing helper" -- exists solely so that ...
## second sheet can have as it's title the key of the first sheet
## important that these are owned by gspreadr because they're used to test
##   that only applies to the spreadsheets feed, which requires auth
wtf1_url <- "https://docs.google.com/spreadsheets/d/1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc/edit#gid=0"
wtf1_key <- "1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc"
wtf1_title <- "gs-test-testing helper"
wtf2_title <- wtf1_key
wtf2_key <- "1upHM4Kg9Zr3dmzW2LW_rMG44NFJruQOIv_FQ-YvRFT8"
wtf2_url <- "https://docs.google.com/spreadsheets/d/1upHM4Kg9Zr3dmzW2LW_rMG44NFJruQOIv_FQ-YvRFT8/edit#gid=0"

## old style sheets ...
## these are hard to get your hands on now (except, ironically, for my users!)
## I have had Google forcibly convert at least two test sheets from
##   old style to new style
## I recently got an old style sheet via this link:
## http://its.faith.edu.ph/news/oldstylegooglesheet
## the actual link to make a copy of an old style sheet is this:
## https://drive.google.com/open?id=0AixWk2YYzNjidGxZS1ItdkN1bzJyeFFTSGxjc0lXamc&authuser=0&newcopy

## Gapminder alternative (owned by gspreadr)
gap_alt_url <- "https://docs.google.com/spreadsheets/d/1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA/"
gap_alt_title <- "Gapminder"
gap_alt_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
gap_alt_ws_feed <- "https://spreadsheets.google.com/feeds/worksheets/1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA/private/full"

## Public testing sheet (owned by gspreadr)
pts_alt_url <- "https://docs.google.com/spreadsheets/d/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/"
pts_alt_title <- "Public Testing Sheet"
pts_alt_key <- "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk"
pts_alt_ws_feed <- "https://spreadsheets.google.com/feeds/worksheets/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/private/full"

## Private iris sheet (owned by gspreadr)
iris_pvt_url <- "https://docs.google.com/spreadsheets/d/1UXr4-haIQsmJfyjkEhlkNt2PXduBkB97e15jez9ogRo/"
iris_pvt_title <- "test-gs-iris-private"
iris_pvt_key <- "1UXr4-haIQsmJfyjkEhlkNt2PXduBkB97e15jez9ogRo"
iris_pvt_ws_feed <- "https://spreadsheets.google.com/feeds/worksheets/1UXr4-haIQsmJfyjkEhlkNt2PXduBkB97e15jez9ogRo/private/full"
