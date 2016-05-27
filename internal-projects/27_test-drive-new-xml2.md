27\_test-drive-new-xml2.R
================
jenny
Fri May 13 09:40:57 2016

Task: create XML to update contents of cells in a Google Sheet.

Here's how I currently do it with the XML package.

``` r
library(readr)
library(XML)
#> Warning: package 'XML' was built under R version 3.2.4
library(purrr)

update_fodder <- read_csv("27_update-fodder.csv")
africa_cellsfeed <- "SOME_URL"

f_XML <- function(cell, cell_id, edit_link, row, col, update_value) {
  XML::xmlNode("entry",
               XML::xmlNode("batch:id", cell),
               XML::xmlNode("batch:operation",
                            attrs = c("type" = "update")),
               XML::xmlNode("id", cell_id),
               XML::xmlNode("link",
                            attrs = c("rel" = "edit",
                                      "type" = "application/atom+xml",
                                      "href" = edit_link)),
               XML::xmlNode("gs:cell",
                            attrs = c("row" = row,
                                      "col" = col,
                                      "inputValue" = update_value)))
}

list_of_nodes <- update_fodder %>%
  pmap(f_XML)
feed_node <-
  xmlNode("feed",
          namespaceDefinitions =
            c("http://www.w3.org/2005/Atom",
              batch = "http://schemas.google.com/gdata/batch",
              gs = "http://schemas.google.com/spreadsheets/2006"),
          .children = list(xmlNode("id", africa_cellsfeed))) %>%
  addChildren(kids = list_of_nodes)
## here's what I actually send as body of an httr::POST request:
write(toString.XMLNode(feed_node), "27_feed-node-XML.xml")
```

Installing / verifying `xml2` from the relevant PR.

``` r
#devtools::install_github("hadley/xml2#76")
si <- devtools::session_info("xml2")$packages
si$source[si$package == "xml2"]
#> [1] "Github (jimhester/xml2@63e5c1c)"
```

Current approach given by @jimhester.

``` r
library(xml2)
d <- xml_new_document() %>%
  xml_add_child("feed",
                xmlns = "http://www.w3.org/2005/Atom",
                "xmlns:batch" = "http://schemas.google.com/gdata/batch",
                "xmlns:gs" = "http://schemas.google.com/spreadsheets/2006")

d %>% xml_add_child("id", africa_cellsfeed)
#> {xml_node}
#> <id>
f_XML <- function(cell, cell_id, edit_link, row, col, update_value) {
  d %>%
    xml_add_child("entry") %>%
    xml_add_child("batch:id", cell) %>%
    xml_add_sibling("batch:operation", type = "update") %>%
    xml_add_sibling("id", cell_id) %>%
    xml_add_sibling("link", rel = "edit", type = "application/atom+xml",
                    href = edit_link) %>%
    xml_add_sibling("gs:cell", row = as.character(row), col = as.character(col),
                    inputValue = update_value)
}

update_fodder %>% pwalk(f_XML)

write_xml(d, "27_feed-node-xml2.xml")
```

How does this compare to the output from the `XML` package? `xml2` adds an XML declaration.

``` bash
diff -b -U 0 27_feed-node-XML.xml 27_feed-node-xml2.xml
#> --- 27_feed-node-XML.xml 2016-05-13 09:40:58.000000000 -0700
#> +++ 27_feed-node-xml2.xml    2016-05-13 09:40:58.000000000 -0700
#> @@ -0,0 +1 @@
#> +<?xml version="1.0"?>
```

Can `xml2` roundtrip it's own XML? I.e. the new linebreaks don't cause trouble? I wonder because of <https://github.com/hadley/xml2/issues/49>.

``` r
rt <- read_xml("27_feed-node-xml2.xml")
identical(as_list(d), as_list(rt))
#> [1] FALSE
head(all.equal(as_list(d), as_list(rt)))
#> [1] "Names: 20 string mismatches"                                   
#> [2] "Length mismatch: comparison on first 37 components"            
#> [3] "Component 1: Modes: list, character"                           
#> [4] "Component 1: Component 1: 1 string mismatch"                   
#> [5] "Component 2: names for target but not for current"             
#> [6] "Component 2: Length mismatch: comparison on first 1 components"
xml_children(d)[[2]]
#> {xml_node}
#> <entry>
#> [1] <batch:id>A1</batch:id>
#> [2] <batch:operation type="update"/>
#> [3] <id>https://spreadsheets.google.com/feeds/cells/1tP1SAErOJbMrTTCONdL ...
#> [4] <link rel="edit" type="application/atom+xml" href="https://spreadshe ...
#> [5] <gs:cell row="1" col="1" inputValue="country"/>
xml_children(rt)[[2]]
#> {xml_node}
#> <entry>
#> [1] <batch:id>A1</batch:id>
#> [2] <batch:operation type="update"/>
#> [3] <id>https://spreadsheets.google.com/feeds/cells/1tP1SAErOJbMrTTCONdL ...
#> [4] <link rel="edit" type="application/atom+xml" href="https://spreadshe ...
#> [5] <gs:cell row="1" col="1" inputValue="country"/>
as_list(xml_children(d)[[2]])
#> $id
#> $id[[1]]
#> [1] "A1"
#> 
#> 
#> $operation
#> list()
#> attr(,"type")
#> [1] "update"
#> 
#> $id
#> $id[[1]]
#> [1] "https://spreadsheets.google.com/feeds/cells/1tP1SAErOJbMrTTCONdL0a9lwe3KkhTuZaGhCy3MPZP8/ozf3txt/private/full/R1C1"
#> 
#> 
#> $link
#> list()
#> attr(,"rel")
#> [1] "edit"
#> attr(,"type")
#> [1] "application/atom+xml"
#> attr(,"href")
#> [1] "https://spreadsheets.google.com/feeds/cells/1tP1SAErOJbMrTTCONdL0a9lwe3KkhTuZaGhCy3MPZP8/ozf3txt/private/full/R1C1/fu9n6e"
#> 
#> $cell
#> list()
#> attr(,"row")
#> [1] "1"
#> attr(,"col")
#> [1] "1"
#> attr(,"inputValue")
#> [1] "country"
as_list(xml_children(rt)[[2]])
#> [[1]]
#> [1] "\n    "
#> 
#> $id
#> $id[[1]]
#> [1] "A1"
#> 
#> 
#> [[3]]
#> [1] "\n    "
#> 
#> $operation
#> list()
#> attr(,"type")
#> [1] "update"
#> 
#> [[5]]
#> [1] "\n    "
#> 
#> $id
#> $id[[1]]
#> [1] "https://spreadsheets.google.com/feeds/cells/1tP1SAErOJbMrTTCONdL0a9lwe3KkhTuZaGhCy3MPZP8/ozf3txt/private/full/R1C1"
#> 
#> 
#> [[7]]
#> [1] "\n    "
#> 
#> $link
#> list()
#> attr(,"rel")
#> [1] "edit"
#> attr(,"type")
#> [1] "application/atom+xml"
#> attr(,"href")
#> [1] "https://spreadsheets.google.com/feeds/cells/1tP1SAErOJbMrTTCONdL0a9lwe3KkhTuZaGhCy3MPZP8/ozf3txt/private/full/R1C1/fu9n6e"
#> 
#> [[9]]
#> [1] "\n    "
#> 
#> $cell
#> list()
#> attr(,"row")
#> [1] "1"
#> attr(,"col")
#> [1] "1"
#> attr(,"inputValue")
#> [1] "country"
#> 
#> [[11]]
#> [1] "\n  "
```

No, the linebreaks do cause problems!

But notice it doesn't affect XML written to file.

``` r
write_xml(rt, "27_feed-node-xml2-roundtrip.xml")
```

``` bash
diff -b 27_feed-node-xml2.xml 27_feed-node-xml2-roundtrip.xml
```

**Everything below here is old.**

Here's my original rough pass at writing XML with xml2. Done with <jimhester/xml2@04a83fe>, which is now out-of-date. Code is not run.

``` r
feed <- xml_new_document() %>%
  xml_add_child("feed",
                xmlns = "http://www.w3.org/2005/Atom",
                "xmlns:batch" = "http://schemas.google.com/gdata/batch",
                "xmlns:gs" = "http://schemas.google.com/spreadsheets/2006"
  )
xml_add_child(feed, "id", africa_cellsfeed)
entry <- xml_add_child(feed, "entry")
xml_add_child(entry, "batch:id", update_fodder$cell[1])
xml_add_child(entry, "batch:operation", type = "update")
xml_add_child(entry, "id", update_fodder$cell_id[1])
xml_add_child(entry, "link", rel = "edit", type = "application/atom+xml",
              href = update_fodder$edit_link[1])
xml_add_child(entry, "gs:cell", row = as.character(update_fodder$row[1]),
              col = as.character(update_fodder$col[1]),
              inputValue = update_fodder$update_value[1])
## now I just need to do that for the remaining 35 rows of update_fodder :)
write_xml(feed, "27_feed-node-xml2.xml")
```

Observations about the XML vs xml2 result (other than the scale up)

-   Why no line breaks in the xml2 output? would be so much easier to look at
-   xml2 insists on adding `<?xml version="1.0"?>` as first line; will this matter? I have no idea
-   XML uses shorter form for elements with no content; I assume this is of no practical significance
-   xml2 requires me to explicitly convert things to character (see the row and col attributes of gs:cell node)

Re setting the namespaces: the current method feels a bit weird. It feels like I should be able to provide a character vector, with possibly one unnamed element (the first one?) for the default namespace. You might also expect that the output of `xml_ns()` could somehow be used to set namespace? But that does not work.

``` r
foo <- xml_add_child(xml_new_document(), "feed", xml_ns(feed))
#> Error in inherits(x, "xml_document"): object 'feed' not found
xml_ns(feed)
#> Error in inherits(x, "xml_document"): object 'feed' not found
xml_ns(foo)
#> Error in inherits(x, "xml_document"): object 'foo' not found
```
