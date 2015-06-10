------------------------------------------------------------------------

Outline of 2015-06-10 `googlesheets` Practice Talk
--------------------------------------------------

Visit the [README](README.md)

### Install and load googlesheets

Putting here just for completeness, even though we won't go hands on so soon, I bet.

``` r
devtools::install_github("jennybc/googlesheets")
```

I will go ahead and load `googlesheets` and `dplyr` (latter mostly for `%>%`).

``` r
library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))
```

### Women in macroecology

Tweet from this morning:

<blockquote class="twitter-tweet" lang="en">
<p lang="en" dir="ltr">
I'm making a women in macroecology list. Please add yourself &/or others! Keen to find students, postdocs & PIs. <a href="https://t.co/PfgJXZ1d8G">https://t.co/PfgJXZ1d8G</a>
</p>
— Natalie Cooper (@nhcooper123) <a href="https://twitter.com/nhcooper123/status/545197476454879233">December 17, 2014</a>
</blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
So let's visit that Sheet!

<https://docs.google.com/spreadsheets/d/1jmTR4-qNgdKpmKLCSfadIXF2zYNo4jlVHb7YMjnY-os>

And get it into R!

### Here are some draft slides

[Draft slides](https://speakerdeck.com/jennybc/googlesheets-draft) for a talk in July 2015
