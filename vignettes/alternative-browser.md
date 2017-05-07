# Use an alternative browser
Jennifer Bryan  
`r Sys.Date()`  

What if you want to do auth in a non-default browser? Examples below show requests for Google Chrome or Safari on Mac OS X.

At runtime, the browser is given via the `browser` element of `options()`.


```r
getOption("browser")
```

```
## function (url) 
## {
##     .Call("rs_browseURL", url)
## }
## <environment: 0x10493db78>
```

Two alternatives to change that temporarily for `gs_auth()`:

Using just base R facilities.


```r
library(googlesheets)

op <- options(browser = "/usr/bin/open -a '/Applications/Google Chrome.app'")
#op <- options(browser = "/usr/bin/open -a '/Applications/Safari.app'")
gs_auth()
options(op)
```

Using with [`withr` package](https://cran.r-project.org/package=withr).


```r
library(withr)
library(googlesheets)

with_options(
  #  list(browser = "/usr/bin/open -a '/Applications/Safari.app'"),
  list(browser = "/usr/bin/open -a '/Applications/Google Chrome.app'"),
  gs_auth()
)
```

