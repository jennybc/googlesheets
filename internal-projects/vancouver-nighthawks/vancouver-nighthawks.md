

```r

library(googlesheets)
library(magrittr)

gs_auth("jenny_token.rds") ## Sheet is NOT published to the web
#> Auto-refreshing stale OAuth token.

vn_ss <- gs_title("2015-05-23_seaRM-at-vanNH")
#> Sheet successfully identifed: "2015-05-23_seaRM-at-vanNH"
game_play <- vn_ss %>%
  gs_read(ws = 10, range = cell_limits(c(2, NA), c(1, 2)))
#> Accessing worksheet titled "10"
game_play %>% head
#> Source: local data frame [6 x 2]
#> 
#>   Offense Defense
#> 1      NA     42P
#> 2    21pu      NA
#> 3      NA    29pu
#> 4      NA      31
#> 5      NA      29
#> 6      NA      31
point_info <- vn_ss %>%
  gs_read_cellfeed(ws = 10, range = "D1:D4") %>%
  gs_simplify_cellfeed(col_names = FALSE)
#> Accessing worksheet titled "10"
point_info
#>                   D1                   D2                   D3 
#> "Seattle Rainmakers"                  "1"            "3:12:00" 
#>                   D4 
#>            "1:49:00"
```


---
title: "vancouver-nighthawks.R"
author: "jenny"
date: "Wed Jun 17 22:18:54 2015"
---
