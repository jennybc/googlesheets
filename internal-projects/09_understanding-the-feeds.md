# Understanding the feeds


```r
suppressPackageStartupMessages(library("dplyr"))
library("xml2")
library("stringr")
```

```
## Warning: package 'stringr' was built under R version 3.1.3
```

```r
## I want to use unexported functions here
devtools::load_all(pkg = "~/research/googlesheets/")
```

```
## Loading googlesheets
```

```r
#library("googlesheets")
```



We need better documentation of what we can get our hands on via the different feeds. Here we go.

## Spreadsheets feed

### `entry` nodes are where it's at

The most useful info from the spreadsheet feed consists of the `entry` nodes, one per sheet.


```r
the_url <- "https://spreadsheets.google.com/feeds/spreadsheets/private/full"
req <- gsheets_GET(the_url)

ns <- xml_ns_rename(xml_ns(req$content), d1 = "feed")
entries <- req$content %>% 
  xml_find_all(".//feed:entry", ns) %>% 
  xml_path()
length(entries)
```

```
## [1] 36
```

```r
req$content %>%
  xml_find_first(entries[1])
```

```
## {xml_node}
## <entry>
## [1] <id>https://spreadsheets.google.com/feeds/spreadsheets/private/full/ ...
## [2] <updated>2015-05-19T23:00:13.476Z</updated>
## [3] <category scheme="http://schemas.google.com/spreadsheets/2006" term= ...
## [4] <title type="text">ari copy</title>
## [5] <content type="text">ari copy</content>
## [6] <link rel="http://schemas.google.com/spreadsheets/2006#worksheetsfee ...
## [7] <link rel="alternate" type="text/html" href="https://spreadsheets.go ...
## [8] <link rel="self" type="application/atom+xml" href="https://spreadshe ...
## [9] <author>\n  <name>gspreadr</name>\n  <email>gspreadr@gmail.com</emai ...
```

The `entry` nodes have same structure for each sheet, which we explore via the first entry = sheet. What is all this stuff?

  * `id` is a URL.
  * `updated` is date-time of last update (not clear exactly what that means)
  * `category` seems utterly useless to me.
  * `title/text` and `content/text` both give the sheet's title. Below we confirm they are redundant.
  * The 3 links are arguably the most valuable stuff. Much study of those below.
  * `author/name` and `author/email` are self-explanatory.
  
#### Sheet title

Is the info in `title/text` identical to that in `content/text`?


```r
title_stuff <-
  data_frame(text = req$content %>%
               xml_find_all(".//feed:entry//feed:title", ns) %>% 
               xml_text(),
             content = req$content %>%
               xml_find_all(".//feed:entry//feed:content", ns) %>% 
               xml_text())
title_stuff
```

```
## Source: local data frame [36 x 2]
## 
##                                 text                           content
## 1                           ari copy                          ari copy
## 2          Ari's Anchor Text Scraper         Ari's Anchor Text Scraper
## 3            EasyTweetSheet - Shared           EasyTweetSheet - Shared
## 4                       #rhizo15 #tw                      #rhizo15 #tw
## 5                        gas_mileage                       gas_mileage
## 6          2014-05-10_seaRM-at-vanNH         2014-05-10_seaRM-at-vanNH
## 7  2014-05-10_seaRM-at-vanNH_MY-COPY 2014-05-10_seaRM-at-vanNH_MY-COPY
## 8                test-gs-permissions               test-gs-permissions
## 9                    #TalkPay Tweets                   #TalkPay Tweets
## 10                test-gs-old-sheet2                test-gs-old-sheet2
## ..                               ...                               ...
```

```r
with(title_stuff, identical(text, content))
```

```
## [1] TRUE
```

YES. At least for this set of sheets.

Let's set the names for `entries` to the sheet titles.


```r
names(entries) <- title_stuff$text
```

### Marshall all links returned by the spreadsheets feed

Each `entry` node has an `id` element containing a URL plus 3 additional nodes named `link`. I gather all 4 into a `tbl_df` for systematic exploration


```r
jfun <- function(x) { # gymnastics required for one sheet's worth of links
  x <- req$content %>% xml_find_first(x)
  links <- x %>% 
    xml_find_all("feed:link", ns) %>% 
    lapply(xml_attrs) %>% 
    lapply(as.list) %>%
    lapply(as_data_frame) %>% 
    bind_rows() %>% 
    mutate(source = "content/entry/link")
  links %>%
    rbind(data.frame(rel = NA, type = NA,
                     href = x %>% xml_find_first("feed:id", ns) %>% xml_text(),
                     source = "content/entry/id")) %>% 
    mutate(feed = "ss",
           sheet_title = x %>% xml_find_first("feed:title", ns) %>% xml_text()) %>% 
    select(sheet_title, feed, source, href, rel, type)
}
links <- entries %>% lapply(jfun) %>% 
  bind_rows()
```

#### Are the "self" and `id` links the same?


```r
links %>%
  filter(rel == "self" | source == "content/entry/id") %>%
  group_by(sheet_title) %>%
  summarize(query = n_distinct(href) == 1) %>%
  `[[`("query") %>%
  all
```

```
## [1] TRUE
```

YES, they are exactly the same, at least for these sheets.

#### Structure of the "self" link


```r
links %>%
  filter(rel == "self") %>%
  `[[`("href") %>%
  str_split_fixed("//*", n = 7)
```

```
##       [,1]     [,2]                      [,3]    [,4]           [,5]     
##  [1,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [2,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [3,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [4,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [5,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [6,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [7,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [8,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##  [9,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [10,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [11,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [12,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [13,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [14,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [15,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [16,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [17,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [18,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [19,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [20,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [21,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [22,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [23,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [24,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [25,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [26,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [27,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [28,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [29,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [30,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [31,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [32,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [33,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [34,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [35,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
## [36,] "https:" "spreadsheets.google.com" "feeds" "spreadsheets" "private"
##       [,6]   [,7]                                          
##  [1,] "full" "twqk79m_IJlhdWPdyvjqkDw"                     
##  [2,] "full" "tQKSYVRwBXssUfYEaMdt-aw"                     
##  [3,] "full" "14mAbIi1UyZtJTDuIa7iMb80xYtXbxCr-TGlvFbPgi3E"
##  [4,] "full" "1oBQNnsMY8Qkuui6BAE8TnC1GphJS22Rodm3oVzbbemM"
##  [5,] "full" "1WH65aJjlmhOWYMFkhDuKPcRa5mloOtsTCKxrF7erHgI"
##  [6,] "full" "1223dpf3vnjZUYUnCM8rBSig3JlGrAu1Qu6VmPvdEn4M"
##  [7,] "full" "1zeV34mJWN4T_Sl-F2lptyG1RebRRGvCPdWazWaBCeAQ"
##  [8,] "full" "1gq8qy4JXJaz8I-14XV2_tAXv2JMng86G3WpvNkSf444"
##  [9,] "full" "1IK1an_x8buIveByENsAk6eww-mHIfZeYQxr7FBWPWz8"
## [10,] "full" "1cee9I3hNJ1lAij1LBqzuLU3_UQY6Dd5atO9HBchZb4k"
## [11,] "full" "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY"
## [12,] "full" "1UXr4-haIQsmJfyjkEhlkNt2PXduBkB97e15jez9ogRo"
## [13,] "full" "1upHM4Kg9Zr3dmzW2LW_rMG44NFJruQOIv_FQ-YvRFT8"
## [14,] "full" "1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc"
## [15,] "full" "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"
## [16,] "full" "1r_R_Qxw7FLM-X_HMhyJ4TQZ3Dok_7b-fRcqQ2K9mDmM"
## [17,] "full" "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk"
## [18,] "full" "1OvDq4_BtbR6nSnnHnjD5hVC3HQ-ulZPGbo0RDGbzM3Q"
## [19,] "full" "1SDA_Gu7vCHr1hBXtgD7xB77SHd4YKy4zLZDrwnao0pM"
## [20,] "full" "1vFtO8i3zH8pk4RoxkcQw5kFtCDeooYVimUaXGD8n1WY"
## [21,] "full" "1P3ho4-XZcYyVAUZyYAHsWl3t9EW9MasbHBQkkT9i-yc"
## [22,] "full" "1ET1NGcPpAOKoqBBfcL1t1D2wcQ-3rc1H5RcYxY-TbTE"
## [23,] "full" "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
## [24,] "full" "1yet5ONlyclG5nn63nQ8XDdexzxbZm0zx1wutYKzuzao"
## [25,] "full" "1w8F3t9-LpMqiKBgZG1RImRyMKleI6OH0_YE-tHQl-j0"
## [26,] "full" "10RqUOHuieOtW5baYJXBdIBECjnVKTORlBmglgGd2l_c"
## [27,] "full" "1Hkh20-IEQzKaBTqwWrQEYqoCaqDoyLjbgX8x4keACgE"
## [28,] "full" "1_tZXIrjS5M-hIQkOWwjotzqyL8hMZpsDH9P1C8RH9L4"
## [29,] "full" "t2nkTcxxWosQbEpIhF2udYA"                     
## [30,] "full" "17nhc-Dih2Usxz2m1rX5a8h_W0NXANeCXfW2J8oAS1gA"
## [31,] "full" "1GLsDOyR8hDgkjC6fzaDCVVjYsN8tLvnySDayk3HfxxA"
## [32,] "full" "1Ti9J6t4CSr7ffyXYXoX0HesIwrf9n4bGNZKX1vROQ2o"
## [33,] "full" "1bd5wjZQI8XjPrVNUFbTLI-zhpS8qLJ1scPq1v4v3mWs"
## [34,] "full" "tyMzjZuK5v7dCKE-azr-kQA"                     
## [35,] "full" "1HpaE4o3QLflLa8uQ6BLh9grHVlpv5kB7BGAPgIWMQ-Y"
## [36,] "full" "reBYenfrJHIRd4voZfiSmuw"
```

Here's what I see:

```
https://spreadsheets.google.com/feeds/spreadsheets/private/full/KEY
```

#### Structure of the worksheets feed

I happen to know that the worksheets feed is the link with attribute `"rel"` equal to `http://schemas.google.com/spreadsheets/2006#worksheetsfeed`.


```r
links %>%
  filter(str_detect(rel, "2006#worksheetsfeed")) %>%
  `[[`("href") %>%
  str_split_fixed("//*", n = 7)
```

```
##       [,1]     [,2]                      [,3]    [,4]        
##  [1,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [2,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [3,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [4,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [5,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [6,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [7,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [8,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##  [9,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [10,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [11,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [12,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [13,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [14,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [15,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [16,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [17,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [18,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [19,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [20,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [21,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [22,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [23,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [24,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [25,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [26,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [27,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [28,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [29,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [30,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [31,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [32,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [33,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [34,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [35,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
## [36,] "https:" "spreadsheets.google.com" "feeds" "worksheets"
##       [,5]                                           [,6]      [,7]    
##  [1,] "twqk79m_IJlhdWPdyvjqkDw"                      "private" "full"  
##  [2,] "tQKSYVRwBXssUfYEaMdt-aw"                      "private" "values"
##  [3,] "14mAbIi1UyZtJTDuIa7iMb80xYtXbxCr-TGlvFbPgi3E" "private" "values"
##  [4,] "1oBQNnsMY8Qkuui6BAE8TnC1GphJS22Rodm3oVzbbemM" "private" "values"
##  [5,] "1WH65aJjlmhOWYMFkhDuKPcRa5mloOtsTCKxrF7erHgI" "private" "values"
##  [6,] "1223dpf3vnjZUYUnCM8rBSig3JlGrAu1Qu6VmPvdEn4M" "private" "full"  
##  [7,] "1zeV34mJWN4T_Sl-F2lptyG1RebRRGvCPdWazWaBCeAQ" "private" "values"
##  [8,] "1gq8qy4JXJaz8I-14XV2_tAXv2JMng86G3WpvNkSf444" "private" "full"  
##  [9,] "1IK1an_x8buIveByENsAk6eww-mHIfZeYQxr7FBWPWz8" "private" "values"
## [10,] "1cee9I3hNJ1lAij1LBqzuLU3_UQY6Dd5atO9HBchZb4k" "private" "full"  
## [11,] "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY" "private" "values"
## [12,] "1UXr4-haIQsmJfyjkEhlkNt2PXduBkB97e15jez9ogRo" "private" "full"  
## [13,] "1upHM4Kg9Zr3dmzW2LW_rMG44NFJruQOIv_FQ-YvRFT8" "private" "full"  
## [14,] "1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc" "private" "full"  
## [15,] "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ" "private" "values"
## [16,] "1r_R_Qxw7FLM-X_HMhyJ4TQZ3Dok_7b-fRcqQ2K9mDmM" "private" "values"
## [17,] "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk" "private" "full"  
## [18,] "1OvDq4_BtbR6nSnnHnjD5hVC3HQ-ulZPGbo0RDGbzM3Q" "private" "values"
## [19,] "1SDA_Gu7vCHr1hBXtgD7xB77SHd4YKy4zLZDrwnao0pM" "private" "full"  
## [20,] "1vFtO8i3zH8pk4RoxkcQw5kFtCDeooYVimUaXGD8n1WY" "private" "values"
## [21,] "1P3ho4-XZcYyVAUZyYAHsWl3t9EW9MasbHBQkkT9i-yc" "private" "full"  
## [22,] "1ET1NGcPpAOKoqBBfcL1t1D2wcQ-3rc1H5RcYxY-TbTE" "private" "values"
## [23,] "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA" "private" "full"  
## [24,] "1yet5ONlyclG5nn63nQ8XDdexzxbZm0zx1wutYKzuzao" "private" "full"  
## [25,] "1w8F3t9-LpMqiKBgZG1RImRyMKleI6OH0_YE-tHQl-j0" "private" "full"  
## [26,] "10RqUOHuieOtW5baYJXBdIBECjnVKTORlBmglgGd2l_c" "private" "values"
## [27,] "1Hkh20-IEQzKaBTqwWrQEYqoCaqDoyLjbgX8x4keACgE" "private" "full"  
## [28,] "1_tZXIrjS5M-hIQkOWwjotzqyL8hMZpsDH9P1C8RH9L4" "private" "full"  
## [29,] "t2nkTcxxWosQbEpIhF2udYA"                      "private" "values"
## [30,] "17nhc-Dih2Usxz2m1rX5a8h_W0NXANeCXfW2J8oAS1gA" "private" "full"  
## [31,] "1GLsDOyR8hDgkjC6fzaDCVVjYsN8tLvnySDayk3HfxxA" "private" "full"  
## [32,] "1Ti9J6t4CSr7ffyXYXoX0HesIwrf9n4bGNZKX1vROQ2o" "private" "full"  
## [33,] "1bd5wjZQI8XjPrVNUFbTLI-zhpS8qLJ1scPq1v4v3mWs" "private" "full"  
## [34,] "tyMzjZuK5v7dCKE-azr-kQA"                      "private" "values"
## [35,] "1HpaE4o3QLflLa8uQ6BLh9grHVlpv5kB7BGAPgIWMQ-Y" "private" "values"
## [36,] "reBYenfrJHIRd4voZfiSmuw"                      "private" "values"
```

Here's what I see:

```
https://spreadsheets.google.com/feeds/worksheets/KEY/VISIBILITY/FOO
```

where `VISIBILITY` always equals `private` when URL comes from the spreadsheets feed and `FOO` is `values` when user has only read permission and `full` when user
is also allowed to write.

#### Structure of the "alternate" link

Note: I arranged the rows here for clarity.


```r
links %>%
  filter(rel == "alternate") %>%
  arrange(href) %>% 
  `[[`("href") %>%
  str_split_fixed("//*", n = 6)
```

```
##       [,1]     [,2]                     
##  [1,] "https:" "docs.google.com"        
##  [2,] "https:" "docs.google.com"        
##  [3,] "https:" "docs.google.com"        
##  [4,] "https:" "docs.google.com"        
##  [5,] "https:" "docs.google.com"        
##  [6,] "https:" "docs.google.com"        
##  [7,] "https:" "docs.google.com"        
##  [8,] "https:" "docs.google.com"        
##  [9,] "https:" "docs.google.com"        
## [10,] "https:" "docs.google.com"        
## [11,] "https:" "docs.google.com"        
## [12,] "https:" "docs.google.com"        
## [13,] "https:" "docs.google.com"        
## [14,] "https:" "docs.google.com"        
## [15,] "https:" "docs.google.com"        
## [16,] "https:" "docs.google.com"        
## [17,] "https:" "docs.google.com"        
## [18,] "https:" "docs.google.com"        
## [19,] "https:" "docs.google.com"        
## [20,] "https:" "docs.google.com"        
## [21,] "https:" "docs.google.com"        
## [22,] "https:" "docs.google.com"        
## [23,] "https:" "docs.google.com"        
## [24,] "https:" "docs.google.com"        
## [25,] "https:" "docs.google.com"        
## [26,] "https:" "docs.google.com"        
## [27,] "https:" "docs.google.com"        
## [28,] "https:" "docs.google.com"        
## [29,] "https:" "docs.google.com"        
## [30,] "https:" "docs.google.com"        
## [31,] "https:" "docs.google.com"        
## [32,] "https:" "spreadsheets.google.com"
## [33,] "https:" "spreadsheets.google.com"
## [34,] "https:" "spreadsheets.google.com"
## [35,] "https:" "spreadsheets.google.com"
## [36,] "https:" "spreadsheets.google.com"
##       [,3]                                                   [,4]
##  [1,] "spreadsheets"                                         "d" 
##  [2,] "spreadsheets"                                         "d" 
##  [3,] "spreadsheets"                                         "d" 
##  [4,] "spreadsheets"                                         "d" 
##  [5,] "spreadsheets"                                         "d" 
##  [6,] "spreadsheets"                                         "d" 
##  [7,] "spreadsheets"                                         "d" 
##  [8,] "spreadsheets"                                         "d" 
##  [9,] "spreadsheets"                                         "d" 
## [10,] "spreadsheets"                                         "d" 
## [11,] "spreadsheets"                                         "d" 
## [12,] "spreadsheets"                                         "d" 
## [13,] "spreadsheets"                                         "d" 
## [14,] "spreadsheets"                                         "d" 
## [15,] "spreadsheets"                                         "d" 
## [16,] "spreadsheets"                                         "d" 
## [17,] "spreadsheets"                                         "d" 
## [18,] "spreadsheets"                                         "d" 
## [19,] "spreadsheets"                                         "d" 
## [20,] "spreadsheets"                                         "d" 
## [21,] "spreadsheets"                                         "d" 
## [22,] "spreadsheets"                                         "d" 
## [23,] "spreadsheets"                                         "d" 
## [24,] "spreadsheets"                                         "d" 
## [25,] "spreadsheets"                                         "d" 
## [26,] "spreadsheets"                                         "d" 
## [27,] "spreadsheets"                                         "d" 
## [28,] "spreadsheets"                                         "d" 
## [29,] "spreadsheets"                                         "d" 
## [30,] "spreadsheets"                                         "d" 
## [31,] "spreadsheets"                                         "d" 
## [32,] "ccc?key=0Ak0qDiMLT3XddHlNempadUs1djdkQ0tFLWF6ci1rUUE" ""  
## [33,] "ccc?key=0AonYZs4MzlZbcmVCWWVuZnJKSElSZDR2b1pmaVNtdXc" ""  
## [34,] "ccc?key=0AphiLdjs9wK0dDJua1RjeHhXb3NRYkVwSWhGMnVkWUE" ""  
## [35,] "ccc?key=0Audw-qi1jh3fdHdxazc5bV9JSmxoZFdQZHl2anFrRHc" ""  
## [36,] "ccc?key=0Av8m6X4cYe9hdFFLU1lWUndCWHNzVWZZRWFNZHQtYXc" ""  
##       [,5]                                           [,6]  
##  [1,] "10RqUOHuieOtW5baYJXBdIBECjnVKTORlBmglgGd2l_c" "edit"
##  [2,] "1223dpf3vnjZUYUnCM8rBSig3JlGrAu1Qu6VmPvdEn4M" "edit"
##  [3,] "14mAbIi1UyZtJTDuIa7iMb80xYtXbxCr-TGlvFbPgi3E" "edit"
##  [4,] "17nhc-Dih2Usxz2m1rX5a8h_W0NXANeCXfW2J8oAS1gA" "edit"
##  [5,] "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY" "edit"
##  [6,] "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ" "edit"
##  [7,] "1ET1NGcPpAOKoqBBfcL1t1D2wcQ-3rc1H5RcYxY-TbTE" "edit"
##  [8,] "1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc" "edit"
##  [9,] "1GLsDOyR8hDgkjC6fzaDCVVjYsN8tLvnySDayk3HfxxA" "edit"
## [10,] "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA" "edit"
## [11,] "1Hkh20-IEQzKaBTqwWrQEYqoCaqDoyLjbgX8x4keACgE" "edit"
## [12,] "1HpaE4o3QLflLa8uQ6BLh9grHVlpv5kB7BGAPgIWMQ-Y" "edit"
## [13,] "1IK1an_x8buIveByENsAk6eww-mHIfZeYQxr7FBWPWz8" "edit"
## [14,] "1OvDq4_BtbR6nSnnHnjD5hVC3HQ-ulZPGbo0RDGbzM3Q" "edit"
## [15,] "1P3ho4-XZcYyVAUZyYAHsWl3t9EW9MasbHBQkkT9i-yc" "edit"
## [16,] "1SDA_Gu7vCHr1hBXtgD7xB77SHd4YKy4zLZDrwnao0pM" "edit"
## [17,] "1Ti9J6t4CSr7ffyXYXoX0HesIwrf9n4bGNZKX1vROQ2o" "edit"
## [18,] "1UXr4-haIQsmJfyjkEhlkNt2PXduBkB97e15jez9ogRo" "edit"
## [19,] "1WH65aJjlmhOWYMFkhDuKPcRa5mloOtsTCKxrF7erHgI" "edit"
## [20,] "1_tZXIrjS5M-hIQkOWwjotzqyL8hMZpsDH9P1C8RH9L4" "edit"
## [21,] "1bd5wjZQI8XjPrVNUFbTLI-zhpS8qLJ1scPq1v4v3mWs" "edit"
## [22,] "1cee9I3hNJ1lAij1LBqzuLU3_UQY6Dd5atO9HBchZb4k" "edit"
## [23,] "1gq8qy4JXJaz8I-14XV2_tAXv2JMng86G3WpvNkSf444" "edit"
## [24,] "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk" "edit"
## [25,] "1oBQNnsMY8Qkuui6BAE8TnC1GphJS22Rodm3oVzbbemM" "edit"
## [26,] "1r_R_Qxw7FLM-X_HMhyJ4TQZ3Dok_7b-fRcqQ2K9mDmM" "edit"
## [27,] "1upHM4Kg9Zr3dmzW2LW_rMG44NFJruQOIv_FQ-YvRFT8" "edit"
## [28,] "1vFtO8i3zH8pk4RoxkcQw5kFtCDeooYVimUaXGD8n1WY" "edit"
## [29,] "1w8F3t9-LpMqiKBgZG1RImRyMKleI6OH0_YE-tHQl-j0" "edit"
## [30,] "1yet5ONlyclG5nn63nQ8XDdexzxbZm0zx1wutYKzuzao" "edit"
## [31,] "1zeV34mJWN4T_Sl-F2lptyG1RebRRGvCPdWazWaBCeAQ" "edit"
## [32,] ""                                             ""    
## [33,] ""                                             ""    
## [34,] ""                                             ""    
## [35,] ""                                             ""    
## [36,] ""                                             ""
```

We've got more variety here, due to old sheets vs new. Note that, in addition to the obvious difference in domain and overall URL structure, the old sheets present an alternative key in the "alternate" link (verified explicitly below).

Here's what I see:

```
new Sheets:
https://docs.google.com/spreadsheets/d/KEY/edit

old Sheets:
"https://spreadsheets.google.com/ccc?key=ALT_KEY"
```

### Summary of structure and content of spreadsheets feed links

```
id = "self" link:
https://spreadsheets.google.com/feeds/spreadsheets/VISIBILITY/PROJECTION/KEY
VISIBILITY = {private (always in spreadsheets feed?), public}
PROJECTION = {full (default), basic}

worksheets feed:
https://spreadsheets.google.com/feeds/worksheets/KEY/VISIBILITY/PERMISSION
VISIBILITY = {private (always in spreadsheets feed?), public}
PERMISSION = {full (read and write), values (read only)}

"alternate" link, new sheets:
https://docs.google.com/spreadsheets/d/KEY/edit

"alternate" link, old sheets:
https://spreadsheets.google.com/ccc?key=ALT_KEY
```

### New variables for old sheets vs new, sheet permissions

Create new variables to hold info about whether a sheet is old or new and whether current user is allowed to read only or to read and write.


```r
version_df <- links %>%
  filter(rel == "alternate") %>%
  transmute(sheet_title,
            version = ifelse(grepl("^https://docs.google.com/spreadsheets/d",
                                   href), "new", "old"))
perm_df <- links %>%
  filter(str_detect(rel, "2006#worksheetsfeed")) %>%
  transmute(sheet_title,
            perm = ifelse(grepl("values", href), "r", "rw"))
links <- links %>%
  left_join(version_df) %>%
  left_join(perm_df)
```

```
## Joining by: "sheet_title"
## Joining by: "sheet_title"
```

### Extract the keys in the links

Store the keys in these links as a variable.


```r
links <- links %>%
  mutate(link_key = extract_key_from_url(href))
```

Hypothesis: all link keys are uniform for a new sheet ("self" = `id` agrees with worksheets feed agrees with "alternate").


```r
links %>%
  filter(version == "new") %>%
  group_by(sheet_title) %>%
  summarize(query = n_distinct(link_key) == 1) %>%
  `[[`("query") %>%
  all
```

```
## [1] TRUE
```

Hypothesis: The "self" and worksheets feed keys agree for an old sheet but differ from the "alternate" key.


```r
links %>%
  filter(rel %>% str_detect("2006#worksheetsfeed|self|alternate")) %>%
  group_by(sheet_title) %>%
  summarize(query = n_distinct(link_key), version = first(version)) %>%
  group_by(version) %>%
  summarize(min = min(query), max = max(query))
```

```
## Source: local data frame [2 x 3]
## 
##   version min max
## 1     new   1   1
## 2     old   2   2
```

This "alternate" key -- only defined for old sheets and only available through the "alternate" link found in the spreadsheets feed -- is ultimately useful to us for any operations that require the Drive API. Empirically, I note it can also be extracted from the URL seen in the browser when visiting such a sheet.

#### Capture the "alternate" key for old sheets

Formalize this notion of the (default) key versus the "alternate" key, which is only defined for old sheets and is damned hard to get.


```r
alt_keys <- links %>%
  filter(rel == "alternate") %>%
  group_by(sheet_title) %>%
  transmute(alt_key = ifelse(version == "new", NA_character_, link_key))
sheet_keys <- links %>%
  filter(rel == "self") %>%
  group_by(sheet_title) %>%
  transmute(sheet_key = link_key)
links <- links %>%
  left_join(alt_keys) %>%
  left_join(sheet_keys)
```

```
## Joining by: "sheet_title"
## Joining by: "sheet_title"
```

### Summary of the spreadsheets feed

Note the keys shown below are truncated! Wanted to fit more variables and show that `alt_key` is `NA` for new Sheets and that `alt_key` != `sheet_key` for old Sheets.


```r
links %>%
  glimpse
```

```
## Observations: 144
## Variables:
## $ sheet_title (chr) "ari copy", "ari copy", "ari copy", "ari copy", "A...
## $ feed        (chr) "ss", "ss", "ss", "ss", "ss", "ss", "ss", "ss", "s...
## $ source      (chr) "content/entry/link", "content/entry/link", "conte...
## $ href        (chr) "https://spreadsheets.google.com/feeds/worksheets/...
## $ rel         (chr) "http://schemas.google.com/spreadsheets/2006#works...
## $ type        (chr) "application/atom+xml", "text/html", "application/...
## $ version     (chr) "old", "old", "old", "old", "old", "old", "old", "...
## $ perm        (chr) "rw", "rw", "rw", "rw", "r", "r", "r", "r", "r", "...
## $ link_key    (chr) "twqk79m_IJlhdWPdyvjqkDw", "0Audw-qi1jh3fdHdxazc5b...
## $ alt_key     (chr) "0Audw-qi1jh3fdHdxazc5bV9JSmxoZFdQZHl2anFrRHc", "0...
## $ sheet_key   (chr) "twqk79m_IJlhdWPdyvjqkDw", "twqk79m_IJlhdWPdyvjqkD...
```

```r
links %>%
  filter(source == "content/entry/id") %>% 
  #arrange(version, perm, sheet_title) %>% 
  mutate(sheet_title = substr(sheet_title, 1, 15),
         sheet_key = substr(sheet_key, 1, 15),
         alt_key = substr(alt_key, 1, 15)) %>% 
  select(sheet_title, perm, version, sheet_key, alt_key)
```

```
## Source: local data frame [36 x 5]
## 
##        sheet_title perm version       sheet_key         alt_key
## 1         ari copy   rw     old twqk79m_IJlhdWP 0Audw-qi1jh3fdH
## 2  Ari's Anchor Te    r     old tQKSYVRwBXssUfY 0Av8m6X4cYe9hdF
## 3  EasyTweetSheet     r     new 14mAbIi1UyZtJTD              NA
## 4     #rhizo15 #tw    r     new 1oBQNnsMY8Qkuui              NA
## 5      gas_mileage    r     new 1WH65aJjlmhOWYM              NA
## 6  2014-05-10_seaR   rw     new 1223dpf3vnjZUYU              NA
## 7  2014-05-10_seaR    r     new 1zeV34mJWN4T_Sl              NA
## 8  test-gs-permiss   rw     new 1gq8qy4JXJaz8I-              NA
## 9  #TalkPay Tweets    r     new 1IK1an_x8buIveB              NA
## 10 test-gs-old-she   rw     new 1cee9I3hNJ1lAij              NA
## ..             ...  ...     ...             ...             ...
```

## Worksheets feed

Now we turn to the worksheets feed. Hand-picked 4 example sheets: all possible combinations of new vs old sheets and sheets for which I do and do not have write permission.


```r
example_sheets <- c("unitables2010final copy", "ari copy",
                    "WI15 ARCHY 499", "^Gapminder$")
examples <- example_sheets %>%
  gs_ls() %>% 
  arrange(version, perm)
examples %>%
  select(sheet_title, version, perm)
```

```
## Source: local data frame [4 x 3]
## 
##               sheet_title version perm
## 1          WI15 ARCHY 499     new    r
## 2               Gapminder     new   rw
## 3 unitables2010final copy     old    r
## 4                ari copy     old   rw
```

Get the worksheets feed for each example sheet. Use sheet names to name the resulting list. Get overview of all the feeds and the first one as an example.


```r
req_list <- examples$ws_feed %>%
  lapply(gsheets_GET)
#names(req_list) <- substr(examples$sheet_title, 1, 12)
names(req_list) <- examples$sheet_title
req_list %>% str(max.level = 1)
```

```
## List of 4
##  $ WI15 ARCHY 499         :List of 9
##   ..- attr(*, "class")= chr "response"
##  $ Gapminder              :List of 9
##   ..- attr(*, "class")= chr "response"
##  $ unitables2010final copy:List of 9
##   ..- attr(*, "class")= chr "response"
##  $ ari copy               :List of 9
##   ..- attr(*, "class")= chr "response"
```

```r
req_list[[1]] %>% str(max.level = 1)
```

```
## List of 9
##  $ url        : chr "https://spreadsheets.google.com/feeds/worksheets/1vFtO8i3zH8pk4RoxkcQw5kFtCDeooYVimUaXGD8n1WY/private/values"
##  $ status_code: int 200
##  $ headers    :List of 13
##   ..- attr(*, "class")= chr [1:2] "insensitive" "list"
##  $ all_headers:List of 1
##  $ cookies    :List of 1
##  $ content    :List of 2
##   ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
##  $ date       : POSIXct[1:1], format: "2015-05-19 16:16:34"
##  $ times      : Named num [1:6] 0 0.000018 0.00002 0.000084 0.637948 ...
##   ..- attr(*, "names")= chr [1:6] "redirect" "namelookup" "connect" "pretransfer" ...
##  $ request    :List of 5
##  - attr(*, "class")= chr "response"
```

```r
ns_ws <- xml_ns_rename(xml_ns(req_list[[1]]$content), d1 = "feed")
```

A worksheet feed request returns 9 components:

  * `url` is the URL of the worksheets feed itself (this is true by definition; it's an `httr` thing)
  * `status_code`, `date`, `times` are semi-self-explanatory and/or off-topic
  * `headers` + `all_headers`, `cookies`, `request` call for some inspection (below)
  * `content` is, of course, where it's really at (next subsection)

*I have executed and inspected the below but it's not very interesting, nor is it related to our inventory of links. Remove chunk option `eval = FALSE` if you want to bring it back.*


```r
req_list %>% lapply(`[[`, "cookies")
req_list %>% lapply(`[[`, "headers")
req_list %>% lapply(`[[`, "all_headers")
req_list %>% lapply(`[[`, "request")
```

### Content from the worksheets feed

It is convenient to create a named list holding just the content.


```r
content <- req_list %>%
  lapply(`[[`,"content")
content %>% str(max.level = 1)
```

```
## List of 4
##  $ WI15 ARCHY 499         :List of 2
##   ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
##  $ Gapminder              :List of 2
##   ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
##  $ unitables2010final copy:List of 2
##   ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
##  $ ari copy               :List of 2
##   ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
```

```r
#xml2::xml_structure(content[[1]])
content[[1]]
```

```
## {xml_document}
## <feed>
##  [1] <id>https://spreadsheets.google.com/feeds/worksheets/1vFtO8i3zH8pk4 ...
##  [2] <updated>2015-04-13T20:14:47.253Z</updated>
##  [3] <category scheme="http://schemas.google.com/spreadsheets/2006" term ...
##  [4] <title type="text">WI15 ARCHY 499</title>
##  [5] <link rel="alternate" type="application/atom+xml" href="https://doc ...
##  [6] <link rel="http://schemas.google.com/g/2005#feed" type="application ...
##  [7] <link rel="http://schemas.google.com/g/2005#post" type="application ...
##  [8] <link rel="self" type="application/atom+xml" href="https://spreadsh ...
##  [9] <author>\n  <name>gayoungp</name>\n  <email>gayoungp@uw.edu</email> ...
## [10] <openSearch:totalResults>8</openSearch:totalResults>
## [11] <openSearch:startIndex>1</openSearch:startIndex>
## [12] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
## [13] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
## [14] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
## [15] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
## [16] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
## [17] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
## [18] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
## [19] <entry>\n  <id>https://spreadsheets.google.com/feeds/worksheets/1vF ...
```

```r
content %>% lapply(xml_children) %>% lapply(length)
```

```
## $`WI15 ARCHY 499`
## [1] 19
## 
## $Gapminder
## [1] 16
## 
## $`unitables2010final copy`
## [1] 58
## 
## $`ari copy`
## [1] 12
```

Interesting! There is variability in the number of nodes. What varies?


```r
f <- . %>% xml_children %>% xml_name
possible_nodes <- content %>% lapply(f) %>% unlist() %>% unique()
g <- . %>% xml_children %>% xml_name %>%
  factor(levels = possible_nodes) %>% table
```


```r
#knitr::kable(sapply(content, g))
knitr::kable(sapply(content, g), format = "html",
             table.attr = "style='width:30%;'")
```

<table style='width:30%;'>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> WI15 ARCHY 499 </th>
   <th style="text-align:right;"> Gapminder </th>
   <th style="text-align:right;"> unitables2010final copy </th>
   <th style="text-align:right;"> ari copy </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> id </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> updated </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> category </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> title </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> link </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> author </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> totalResults </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> startIndex </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> entry </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

The variation is in the multiplicity of `link` and `entry` elements.  We pursue that below, but let's inspect the more boring components before we move on. We can predict what some of this stuff is based on what we saw in the spreadsheets feed. I'm also going to check if the info here agrees with the spreadsheets feed.


```r
f <- function(x, xpath) xml_find_first(x, xpath, ns_ws) %>% xml_text()
wsf_stuff <-
  data_frame(title = sapply(content, f, "feed:title"),
             updated = sapply(content, f, "feed:updated"),
             author = sapply(content, f, "feed:author//feed:name"),
             email = sapply(content, f, "feed:author//feed:email"),
             totalResults = sapply(content, f, "openSearch:totalResults"),
             startIndex = sapply(content, f, "openSearch:startIndex"))
```


```r
knitr::kable(wsf_stuff %>% select(title, updated, author, email),
             format = "html", table.attr = "style='width:80%;'")
```

<table style='width:80%;'>
 <thead>
  <tr>
   <th style="text-align:left;"> title </th>
   <th style="text-align:left;"> updated </th>
   <th style="text-align:left;"> author </th>
   <th style="text-align:left;"> email </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> WI15 ARCHY 499 </td>
   <td style="text-align:left;"> 2015-04-13T20:14:47.253Z </td>
   <td style="text-align:left;"> gayoungp </td>
   <td style="text-align:left;"> gayoungp@uw.edu </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gapminder </td>
   <td style="text-align:left;"> 2015-03-23T20:34:08.979Z </td>
   <td style="text-align:left;"> gspreadr </td>
   <td style="text-align:left;"> gspreadr@gmail.com </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unitables2010final copy </td>
   <td style="text-align:left;"> 2009-06-02T09:31:06.582Z </td>
   <td style="text-align:left;"> Guardian.facts </td>
   <td style="text-align:left;"> guardian.facts@googlemail.com </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ari copy </td>
   <td style="text-align:left;"> 2015-05-19T23:00:13.476Z </td>
   <td style="text-align:left;"> gspreadr </td>
   <td style="text-align:left;"> gspreadr@gmail.com </td>
  </tr>
</tbody>
</table>

```r
#knitr::kable(wsf_stuff %>% select(title, totalResults, startIndex))
```

So does `updated` from a sheet's worksheets feed match `updated` from a sheet's entry in the spreadsheets feed?


```r
date_stuff <-
  data_frame(sheet_title = examples$sheet_title,
             ssf_up = examples$updated %>%
               as.POSIXct(format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
             wsf_header_last_mod =
               sapply(req_list, function(x) x$headers$`last-modified`) %>%
               httr::parse_http_date(),
             wsf_up = wsf_stuff$updated %>%
               as.POSIXct(format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
             wsf_header_date = sapply(req_list, function(x) x$headers$date) %>%
               httr::parse_http_date())
```


```r
knitr::kable(date_stuff, format = "html", table.attr = "style='width:80%;'")
```

<table style='width:80%;'>
 <thead>
  <tr>
   <th style="text-align:left;"> sheet_title </th>
   <th style="text-align:left;"> ssf_up </th>
   <th style="text-align:left;"> wsf_header_last_mod </th>
   <th style="text-align:left;"> wsf_up </th>
   <th style="text-align:left;"> wsf_header_date </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> WI15 ARCHY 499 </td>
   <td style="text-align:left;"> 2015-04-13 20:14:47 </td>
   <td style="text-align:left;"> 2015-04-13 20:14:47 </td>
   <td style="text-align:left;"> 2015-04-13 20:14:47 </td>
   <td style="text-align:left;"> 2015-05-19 23:16:23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gapminder </td>
   <td style="text-align:left;"> 2015-03-23 20:59:10 </td>
   <td style="text-align:left;"> 2015-03-23 20:34:08 </td>
   <td style="text-align:left;"> 2015-03-23 20:34:08 </td>
   <td style="text-align:left;"> 2015-05-19 23:16:24 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unitables2010final copy </td>
   <td style="text-align:left;"> 2009-06-02 09:31:06 </td>
   <td style="text-align:left;"> 2009-06-02 09:31:06 </td>
   <td style="text-align:left;"> 2009-06-02 09:31:06 </td>
   <td style="text-align:left;"> 2015-05-19 23:16:24 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ari copy </td>
   <td style="text-align:left;"> 2015-05-19 23:00:13 </td>
   <td style="text-align:left;"> 2015-05-19 23:00:13 </td>
   <td style="text-align:left;"> 2015-05-19 23:00:13 </td>
   <td style="text-align:left;"> 2015-05-19 23:16:25 </td>
  </tr>
</tbody>
</table>

Strictly "by eye" and for these examples only, I see this:

  * from the worksheets feed, `updated` is the same as the `last-modified` field of the header
  * from the worksheets feed, `date` field of the header refers to the date-time of the `GET` request to the worksheets feed
  * `updated` from the spreadsheets feed is *usually* equal to `updated` from the worksheets feed, but not always (see `ari copy` for a slight difference)

Let's compare `author` name between the spreadsheets and worksheets feed.


```r
author_stuff <-
  data_frame(sheet_title = examples$sheet_title,
             ssf_author = examples$author,
             wsf_author_name = wsf_stuff$author)
```


```r
knitr::kable(author_stuff, format = "html", table.attr = "style='width:80%;'")
```

<table style='width:80%;'>
 <thead>
  <tr>
   <th style="text-align:left;"> sheet_title </th>
   <th style="text-align:left;"> ssf_author </th>
   <th style="text-align:left;"> wsf_author_name </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> WI15 ARCHY 499 </td>
   <td style="text-align:left;"> gayoungp </td>
   <td style="text-align:left;"> gayoungp </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gapminder </td>
   <td style="text-align:left;"> gspreadr </td>
   <td style="text-align:left;"> gspreadr </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unitables2010final copy </td>
   <td style="text-align:left;"> guardian.facts </td>
   <td style="text-align:left;"> Guardian.facts </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ari copy </td>
   <td style="text-align:left;"> gspreadr </td>
   <td style="text-align:left;"> gspreadr </td>
  </tr>
</tbody>
</table>

They agree ... well, except for the *case*. Weird.

Now let's look at `totalResults` and `startIndex`. I already imagine that `totalResults` refers to the number of worksheets and will therefore compare it to the number of `entry` nodes.


```r
more_stuff <- 
  data_frame(sheet_title = examples$sheet_title,
             n_entries = content %>%
               lapply(xml_find_all,"feed:entry", ns_ws) %>% sapply(length),
             wsf_totalResults = wsf_stuff$totalResults,
             wsf_startIndex = wsf_stuff$startIndex)
```


```r
knitr::kable(more_stuff, format = "html", table.attr = "style='width:80%;'")
```

<table style='width:80%;'>
 <thead>
  <tr>
   <th style="text-align:left;"> sheet_title </th>
   <th style="text-align:right;"> n_entries </th>
   <th style="text-align:left;"> wsf_totalResults </th>
   <th style="text-align:left;"> wsf_startIndex </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> WI15 ARCHY 499 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:left;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gapminder </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unitables2010final copy </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:left;"> 48 </td>
   <td style="text-align:left;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ari copy </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
  </tr>
</tbody>
</table>

YES `totalResults` appears to be the number of `entry` elements, which is the number of worksheets or tabs. `startIndex` remains a useless mystery. From some unrelated fiddling, I think it's a feature common to various Google APIs? I wonder if it only becomes meaningful in a paginated context?

### Links in the worksheets feed

For each example sheet, we grab the `id` and the `link` nodes and prepare as we did all the links from the spreadsheets feed.


```r
jfun <- function(x) { # gymnastics required for one sheet's worth of links
  links <- x %>% 
    xml_find_all("feed:link", ns_ws) %>% 
    lapply(xml_attrs) %>% 
    lapply(as.list) %>%
    lapply(as_data_frame) %>% 
    bind_rows() %>% 
    mutate(source = "content/entry/link")
  links %>%
    rbind(data.frame(rel = NA, type = NA,
                     href = x %>% xml_find_first("feed:id", ns_ws) %>% xml_text(),
                     source = "content/entry/id")) %>% 
    mutate(feed = "ws",
           sheet_title = x %>% xml_find_first("feed:title", ns_ws)
           %>% xml_text()) %>% 
    select(sheet_title, feed, source, href, rel, type)
}
wsf_links <- content %>% lapply(jfun) %>% bind_rows()
wsf_links_table <- wsf_links %>%
  count(rel, sheet_title) %>%
  tidyr::spread(sheet_title, n)
```


```r
knitr::kable(wsf_links_table, format = "html",
             table.attr = "style='width:30%;'")
```

<table style='width:30%;'>
 <thead>
  <tr>
   <th style="text-align:left;"> rel </th>
   <th style="text-align:right;"> ari copy </th>
   <th style="text-align:right;"> Gapminder </th>
   <th style="text-align:right;"> unitables2010final copy </th>
   <th style="text-align:right;"> WI15 ARCHY 499 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> alternate </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> http://schemas.google.com/g/2005#feed </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> http://schemas.google.com/g/2005#post </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> self </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

So we always have links with these `rel` attributes: "alternate", "self", and "http://schemas.google.com/g/2005#feed". We also have a link with `rel` attribute "http://schemas.google.com/g/2005#post" for all but `unitables2010final copy`, which is an old sheet for which we only have read access. Note: the link with `rel = NA` here is the `id` link from the top-level of the worksheets feed.

What relationship do these links have to those from the top-level of the worksheets feed and from the spreadsheets feed?


```r
identical(wsf_links$href[wsf_links$rel %in% "self"], examples$ws_feed)
```

```
## [1] TRUE
```

```r
all.equal(req_list %>% sapply(`[[`, "url"),
          examples$ws_feed, check.names = FALSE)
```

```
## [1] TRUE
```

The "self" link in the worksheets feed gives the URL of the sheet's worksheets feed (the link labelled as "http://schemas.google.com/spreadsheets/2006#worksheetsfeed" in the spreadsheets feed), which is also the `url` component of the worksheets feed. Confused yet?


```r
wsf_links$href[wsf_links$rel %in% "alternate"] == examples$alternate
```

```
## [1]  TRUE  TRUE FALSE FALSE
```

It gets worse! The "alternate" link in the worksheets feed is the same as the "alternate" link in the spreadsheet feed __for new sheets_. For old sheets, these two links have the same structure but the sheet key differs. The "alternate" link from the spreadsheets feed contains what I call the *alternate key*, which is needed for the Google Drive API, whereas the "alternate" link from the worksheets feed uses what I just call the sheet's key. Which is what we use when talking to the Sheets API.

I can find no references in the package's current code to the worksheet feed links labelled as "http://schemas.google.com/g/2005#feed" and "http://schemas.google.com/g/2005#post", so I'm not going to delve into them.

### Summary of structure and content of worksheets feed links

```sh
the "worksheets feed" can be found in ...
url in worksheets feed =
  id inside the *content* of the worksheets feed =
  link named "self" inside the *content* of the worksheets feed =
  link named "http://schemas.google.com/spreadsheets/2006#worksheetsfeed" inside the corresponding entry inside the content of the spreadsheets feed

https://spreadsheets.google.com/feeds/worksheets/KEY/VISIBILITY/PERMISSION
VISIBILITY = {private (default), public}
PERMISSION = {full (read and write), values (read only)}

the "alternate" link can be found in ...
  link with `rel` attribute "alternate" in the corresponding `entry` inside the content of the spreadsheets feed
  link with `rel` attribute "alternate" inside the content of the worksheets feed

for new sheets, the "alternate" link looks like this in both places:
https://docs.google.com/spreadsheets/d/KEY/edit

for old sheets, the "alternate" link looks like this:
https://spreadsheets.google.com/ccc?key=SOME_SORT_OF_KEY
where SOME_SORT_OF_KEY = ALT_KEY in the spreadsheets feed and
      SOME_SORT_OF_KEY = KEY in the worksheets feed
```

### Collecting links from the spreadsheets and worksheets feed

Add some info from the spreadsheets feed to the worksheets feed links. Then row bind into one large table of links.


```r
wsf_links <- wsf_links %>%
  left_join(links %>%
              filter(source == "content/entry/id") %>% 
              select(sheet_title, version, perm,
                     link_key, alt_key, sheet_key),
            by = "sheet_title")
links <- bind_rows(links %>% filter(sheet_title %in% examples$sheet_title), 
                   wsf_links) %>% 
  arrange(version, perm, sheet_title, feed, source, rel)
```

Explore.


```r
links %>% 
  group_by(sheet_title) %>% 
  summarise(n = n(), ss = sum(feed == "ss"), ws = sum(feed == "ws"),
            ndist = n_distinct(href), version = version[1], perm = perm[1])
```

```
## Source: local data frame [4 x 7]
## 
##               sheet_title n ss ws ndist version perm
## 1               Gapminder 9  4  5     3     new   rw
## 2          WI15 ARCHY 499 9  4  5     3     new    r
## 3                ari copy 9  4  5     4     old   rw
## 4 unitables2010final copy 8  4  4     4     old    r
```

Among these examples, there are only 3 distinct URLs (new sheets) or 4 (old sheets). What are they?


```r
plyr::dlply(links, ~ sheet_title + href, function(x) {
  x %>% select(feed, source, rel, version, perm)
})
```

*I'm struggling to make this presentable in this report. For now, just reporting what I see in these results.*

For a new sheet, the three URLs are:

```
the "alternate" link, found in content/entry/link of ss and ws feeds:
https://docs.google.com/spreadsheets/d/KEY/edit
this link is never really used for anything

the spreadsheets link:
https://spreadsheets.google.com/feeds/spreadsheets/private/full/KEY
this link is never really used for anything

the worksheets feed:
https://spreadsheets.google.com/feeds/worksheets/KEY/private/full
this link is critical and is stored redundantly in several places
feed             source                                   rel
  ss content/entry/link         http://...2006#worksheetsfeed
  ws   content/entry/id                                  <NA>
  ws content/entry/link http://schemas.google.com/g/2005#feed
  ws content/entry/link http://schemas.google.com/g/2005#post
  ws content/entry/link                                  self
```

For an old sheet, there are four URLs instead of three, because the "alternate" links in the spreadsheets and worksheets feed contain different keys:

```
two "alternate" links, found in content/entry/link of ss and ws feeds:
spreadsheets feed: https://spreadsheets.google.com/ccc?key=ALT_KEY
worksheets feed: https://spreadsheets.google.com/ccc?key=KEY
we use the alternate link from the spreadsheets feed to get ALT_KEY

the spreadsheets link:
https://spreadsheets.google.com/feeds/spreadsheets/private/full/KEY
this link is never really used for anything

the worksheets feed:
https://spreadsheets.google.com/feeds/worksheets/KEY/private/full
this link is critical and is stored redundantly in several places
(there is no 2005#post link for a real-only old sheet)
feed             source                                   rel
  ss content/entry/link         http://...2006#worksheetsfeed
  ws   content/entry/id                                  <NA>
  ws content/entry/link http://schemas.google.com/g/2005#feed
  ws content/entry/link http://schemas.google.com/g/2005#post
  ws content/entry/link                                  self
```

#### Entries in the worksheets feed

The `entry` components correspond to worksheets within the sheet. As we did with `content`, we make a list with one component per spreadsheet, each containing another list of the sheet's `entry` elements.


```r
ws_entries <- content %>% lapply(xml_find_all, "feed:entry", ns_ws)
ws_entries %>% lapply(length)
```

```
## $`WI15 ARCHY 499`
## [1] 8
## 
## $Gapminder
## [1] 5
## 
## $`unitables2010final copy`
## [1] 48
## 
## $`ari copy`
## [1] 1
```

```r
f <- . %>% xml_children %>% xml_name
possible_nodes <- ws_entries %>% lapply(f) %>% unlist() %>% unique()
g <- . %>% xml_children %>% xml_name %>%
  factor(levels = possible_nodes) %>% table
```


```r
knitr::kable(sapply(ws_entries, g), format = "html",
             table.attr = "style='width:30%;'")
```

<table style='width:30%;'>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> WI15 ARCHY 499 </th>
   <th style="text-align:right;"> Gapminder </th>
   <th style="text-align:right;"> unitables2010final copy </th>
   <th style="text-align:right;"> ari copy </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> id </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> updated </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> category </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> title </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> content </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> link </td>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> colCount </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rowCount </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

The links are our main interest. But first let's look at the titles, colCounts, and rowCounts.


```r
ws_entries %>% lapply(xml_find_all, "feed:title", ns_ws) %>% lapply(xml_text)
ws_entries %>% lapply(xml_find_all, "gs:rowCount", ns_ws) %>% lapply(xml_text)
ws_entries %>% lapply(xml_find_all, "gs:colCount", ns_ws) %>% lapply(xml_text)
```

Let's look at the links now. I'm going to work with the links for the **first** worksheet from each spreadsheet and count on the rest to have similar structure.


```r
ws_links <- ws_entries %>%
  lapply(`[`, 1) %>% 
  lapply(xml_find_all, "feed:link", ns_ws)
ws_links %>% sapply(length)
```

```
##          WI15 ARCHY 499               Gapminder unitables2010final copy 
##                       5                       6                       4 
##                ari copy 
##                       5
```

```r
examples %>% select(sheet_title, perm, version)
```

```
## Source: local data frame [4 x 3]
## 
##               sheet_title perm version
## 1          WI15 ARCHY 499    r     new
## 2               Gapminder   rw     new
## 3 unitables2010final copy    r     old
## 4                ari copy   rw     old
```

The number of links per worksheet is maximized for a "read and write" new sheet: 6 links per worksheet. There are 5 links per worksheet in the cases of a "read only" new sheet and a "read and write" old sheet. There are only 4 links per worksheet for a "read only" old sheet.


```r
jfun <- function(x) { # gymnastics required for one sheet's worth of links
  links <- x %>% 
    xml_find_all("feed:entry", ns_ws) %>% 
    `[`(1) %>% 
    xml_find_all("feed:link", ns_ws) %>% 
    lapply(xml_attrs) %>% 
    lapply(as.list) %>%
    lapply(as_data_frame) %>% 
    bind_rows()
  links %>%
    mutate(sheet_title = x %>%
             xml_find_first("feed:title", ns_ws) %>% xml_text()) %>% 
    select(sheet_title, href, rel, type)
}
one_ws_links <-
  content %>%
  lapply(jfun) %>% 
  bind_rows() %>% 
  mutate(rel = rel %>% basename)
one_ws_links_table <- one_ws_links %>%
  count(rel, sheet_title) %>%
  tidyr::spread(sheet_title, n)
```


```r
knitr::kable(one_ws_links_table, format = "html",
             table.attr = "style='width:30%;'")
```

<table style='width:30%;'>
 <thead>
  <tr>
   <th style="text-align:left;"> rel </th>
   <th style="text-align:right;"> ari copy </th>
   <th style="text-align:right;"> Gapminder </th>
   <th style="text-align:right;"> unitables2010final copy </th>
   <th style="text-align:right;"> WI15 ARCHY 499 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2006#cellsfeed </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2006#exportcsv </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2006#listfeed </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2008#visualizationApi </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> edit </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> self </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

The old sheets (`ari copy` and `unitables2010final copy`) are lacking the 2006#exportcsv, a fact we know all too well. And the "read only" sheets are missing the "edit" link, which stands to reason.
