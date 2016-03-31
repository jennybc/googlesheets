# Using xmlview package

This is more for interactive use.


```r
library(googlesheets)
library(xml2)
library(xmlview)

if (!interactive()) {
  gs_auth(file.path("..", "tests", "testthat", "googlesheets_token.rds"))
}
```

```
## Auto-refreshing stale OAuth token.
```

```r
key <- "1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ"
ss <- gs_key(key)
```

```
## Authorization will be used.
```

```
## Sheet successfully identified: "12"
```

```r
ws <- 1
gs_read(ss)
```

```
## Accessing worksheet titled "Sheet1"
```

```
## No encoding supplied: defaulting to UTF-8.
```

```
## Source: local data frame [2 x 1]
## 
##     foo
##   (chr)
## 1 hello
## 2 world
```

```r
this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
req <- httr::GET(this_ws$listfeed, googlesheets:::get_google_token())
rc <- googlesheets:::content_as_xml_UTF8(req)
xml_view(rc)
```

<!--html_preserve--><div id="htmlwidget-9935" style="width:100%;height:480px;" class="xmlview html-widget"></div>
<script type="application/json" data-for="htmlwidget-9935">{"x":{"xmlDoc":"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\" xmlns:openSearch=\"http://a9.com/-/spec/opensearchrss/1.0/\" xmlns:gsx=\"http://schemas.google.com/spreadsheets/2006/extended\"><id>https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full\u003c/id><updated>2016-02-20T04:25:10.497Z\u003c/updated><category scheme=\"http://schemas.google.com/spreadsheets/2006\" term=\"http://schemas.google.com/spreadsheets/2006#list\"/><title type=\"text\">Sheet1\u003c/title><link rel=\"alternate\" type=\"application/atom+xml\" href=\"https://docs.google.com/spreadsheets/d/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/edit\"/><link rel=\"http://schemas.google.com/g/2005#feed\" type=\"application/atom+xml\" href=\"https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full\"/><link rel=\"http://schemas.google.com/g/2005#post\" type=\"application/atom+xml\" href=\"https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full\"/><link rel=\"self\" type=\"application/atom+xml\" href=\"https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full\"/><author><name>gspreadr\u003c/name><email>gspreadr@gmail.com\u003c/email>\u003c/author><openSearch:totalResults>2\u003c/openSearch:totalResults><openSearch:startIndex>1\u003c/openSearch:startIndex><entry><id>https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full/cokwr\u003c/id><updated>2016-02-20T04:25:10.497Z\u003c/updated><category scheme=\"http://schemas.google.com/spreadsheets/2006\" term=\"http://schemas.google.com/spreadsheets/2006#list\"/><title type=\"text\">hello\u003c/title><content type=\"text\"/><link rel=\"self\" type=\"application/atom+xml\" href=\"https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full/cokwr\"/><link rel=\"edit\" type=\"application/atom+xml\" href=\"https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full/cokwr/p0pjca\"/><gsx:foo>hello\u003c/gsx:foo>\u003c/entry><entry><id>https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full/cpzh4\u003c/id><updated>2016-02-20T04:25:10.497Z\u003c/updated><category scheme=\"http://schemas.google.com/spreadsheets/2006\" term=\"http://schemas.google.com/spreadsheets/2006#list\"/><title type=\"text\">world\u003c/title><content type=\"text\"/><link rel=\"self\" type=\"application/atom+xml\" href=\"https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full/cpzh4\"/><link rel=\"edit\" type=\"application/atom+xml\" href=\"https://spreadsheets.google.com/feeds/list/1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ/od6/private/full/cpzh4/12fo22a\"/><gsx:foo>world\u003c/gsx:foo>\u003c/entry>\u003c/feed>\n","styleSheet":"default","addFilter":false,"applyXPath":null,"scroll":false,"xmlDocName":"rc"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

