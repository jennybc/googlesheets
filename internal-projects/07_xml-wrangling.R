#' ---
#' title: "Ways we have parsed XML"
#' author: "Jenny Bryan"
#' date: "`r format(Sys.time(), '%d %B, %Y')`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#'     toc: true
#' ---

#' Internal notes on some of the ways we have taken XML from a feed and turned
#' it into a data.frame. I'm sick of rediscovering this stuff and don't really
#' know how to effectively search back in time in a git repo.

suppressPackageStartupMessages(library("dplyr"))
library("XML")
library("xml2")

#' ## Example data
#'
#' The examples below all use a bit of XML that's a simplified snippet of what
#' we get back from the spreadsheets feed. It's in the file
#' [spreadsheets_feed.xml](spreadsheets_feed.xml).
#'
#' ## Get out of XML fast
#'
#' Early on we struggled to not shoot ourselves in the foot with `XML` and the
#' ease with which a [user can create a memory
#' leak](http://www.omegahat.org/RSXML/MemoryManagement.html). We got skittish,
#' threw up our hands, turned the XML into a list, and did stuff in R. For
#' posterity's sake, here's an example of this sort of workflow.
#'
#' In hindsight, this is not a great idea. It actually leads to more data
#' wrangling, believe it or not, and is slow. That does not matter for the
#' spreadsheets feed but does matter for the cell feed.

## turn XML into a list, using a function from the XML package, and proceed
ssf <- XML::xmlParse("spreadsheets_feed.xml")
ssf_list <- xmlToList(ssf)

## each node named 'entry' = info on an individual sheet
entries <- ssf_list[grep("entry", names(ssf_list))]

## helper function to grab all the links for an entry and turn into a one-row
## data_frame with 3 link variables
wrangle_links <- function(x) {
  links <- x[(grep("link", names(x)))]
  links <- do.call(cbind, unname(links))
  links <- setNames(links["href", , drop = TRUE],
                    links["rel", , drop = TRUE])
  names(links) <-
    gsub("http://schemas.google.com/spreadsheets/2006#worksheetsfeed",
         "ws_feed", names(links))
  as_data_frame(as.list(links))
}

## create data_frame of links for all sheets
links <- plyr::ldply(entries, wrangle_links, .id = NULL)

## create data_frame of info for all sheets
rlist_sheet_df <- dplyr::data_frame(
  sheet_title = plyr::laply(entries, function(x) x$title$text),
  sheet_key = plyr::laply(entries, `[[`, "id") %>% basename,
  owner = plyr::laply(entries, function(x) x$author$name),
  ws_feed = links$ws_feed,
  alternate = links$alternate,
  self = links$self
)
rlist_sheet_df %>% glimpse
#rlist_sheet_df %>% View

#' ## Use the XML package
#'
#' As we got more experience with XML and XPath, in particular, we got much
#' better at querying XML. Here's how I would do the above with the XML package
#' today.
#'
#' Main lesson: XPath is very powerful. Extremely helpful for reaching down into
#' nooks and crannies of the XML and grabbing a specific thing (usually value or
#' attribute) based on specific criteria (e.g. node name, attribute presence and
#' value). If you always isolate a node set using XPath, then immediately grab
#' the value or attribute you need, you can ignore the scary memory management
#' stuff.

## leave as XML and use XML package
ssf <- XML::xmlParse("spreadsheets_feed.xml")

## namespace fiddliness
rig_namespace <- function(xml_node) {
  ns <- xml_node %>% xmlNamespaceDefinitions(simplify = TRUE)
  names(ns)[1] <- "feed"
  ns
}
ns <- rig_namespace(ssf)

XML_sheet_df <- dplyr::data_frame(
  sheet_title = xpathSApply(ssf, "//feed:entry//feed:title", xmlValue,
                            namespaces = ns),
  sheet_key = xpathSApply(ssf, "//feed:entry//feed:id", xmlValue,
                          namespaces = ns) %>% basename,
  owner = xpathSApply(ssf, "//feed:entry//feed:author/feed:name", xmlValue,
                      namespaces = ns),
  ws_feed =
    xpathSApply(ssf,
                "//feed:entry//feed:link[contains(@rel,'2006#worksheetsfeed')]",
                xmlGetAttr, "href", namespaces = ns),
  alternate = xpathSApply(ssf, "//feed:entry//feed:link[@rel='alternate']",
                          xmlGetAttr, "href", namespaces = ns),
  self = xpathSApply(ssf, "//feed:entry//feed:link[@rel='self']",
                          xmlGetAttr, "href", namespaces = ns)
)
XML_sheet_df %>% glimpse

#' Note that we are getting exactly the same result as above.

identical(rlist_sheet_df, XML_sheet_df)

#' Some links on the XML package. There is a lot of documentation, in some
#' sense, but it's not easy to find and navigate.
#'
#'   * [CRAN homepage](http://cran.r-project.org/web/packages/XML/index.html)
#'   * [homepage for the package](http://www.omegahat.org/RSXML/), as indicated on CRAN
#'
#' ## Use the xml2 package
#'
#' We've been following development of the
#' [xml2](https://github.com/hadley/xml2) package with great interest, with the
#' [plan to switch over](https://github.com/jennybc/googlesheets/pull/102) and
#' return to proper XML parsing (vs. converting to an R list). Here's how we do
#' the above using xml2.

## leave as XML and use xml2 package
ssf <- read_xml("spreadsheets_feed.xml")
ns <- xml_ns_rename(xml_ns(ssf), d1 = "feed")

xml2_sheet_df <- dplyr::data_frame(
  sheet_title =
    ssf %>% xml_find_all("//feed:entry//feed:title", ns) %>% xml_text,
  sheet_key =
    ssf %>% xml_find_all("//feed:entry//feed:id", ns) %>% xml_text %>%
    basename,
  owner =
    ssf %>% xml_find_all("//feed:entry//feed:author/feed:name", ns) %>%
    xml_text,
  ws_feed =
    ssf %>% xml_find_all(
      "//feed:entry//feed:link[contains(@rel, '2006#worksheetsfeed')]", ns) %>%
    xml_attr("href"),
  alternate =
    ssf %>% xml_find_all(
      "//feed:entry//feed:link[@rel='alternate']", ns) %>%
    xml_attr("href"),
  self =
    ssf %>% xml_find_all(
      "//feed:entry//feed:link[@rel='self']", ns) %>%
    xml_attr("href")
)
xml2_sheet_df %>% glimpse

#' Note that we are getting exactly the same result as above.

identical(xml2_sheet_df, XML_sheet_df)

#' Some more links I want to park somewhere
#'
#'   * I got some help from Hadley on XML-related wranging in [this issue thread](https://github.com/hadley/xml2/issues/24) from xml2
#'   * Gaston Sanchez has a nice series of slides on dealing with data from the web.
#'
#'      - http://gastonsanchez.com/work/webdata/
#'      - [basics of XML and HTML](http://gastonsanchez.com/work/webdata/getting_web_data_r3_basics_xml_html.pdf) -- PDF slides
#'      - [parsing XML and HTML content](http://gastonsanchez.com/work/webdata/getting_web_data_r4_parsing_xml_html.pdf) -- PDF slides
