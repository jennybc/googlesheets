27\_test-drive-new-xml2.R
================
jenny
Thu May 12 15:43:07 2016

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

Here's a very rough pass at doing something similar with xml2. First, here's the version of xml2 I'm using.

``` r
si <- devtools::session_info("xml2")$packages
si$source[si$package == "xml2"]
#> [1] "Github (jimhester/xml2@04a83fe)"
```

Now I create the feed node and add just one entry. I'm leaving it for @jimhester to show me the best way to add many entries at once.

``` r
library(xml2)

feed <- xml_new_document() %>%
  xml_add_child("feed",
                xmlns = "http://www.w3.org/2005/Atom",
                "xmlns:batch" = "http://schemas.google.com/gdata/batch",
                "xmlns:gs" = "http://schemas.google.com/spreadsheets/2006"
  )
xml_add_child(feed, "id", africa_cellsfeed)
#> {xml_node}
#> <id>
entry <- xml_add_child(feed, "entry")
xml_add_child(entry, "batch:id", update_fodder$cell[1])
#> {xml_node}
#> <id>
xml_add_child(entry, "batch:operation", type = "update")
#> {xml_node}
#> <operation>
xml_add_child(entry, "id", update_fodder$cell_id[1])
#> {xml_node}
#> <id>
xml_add_child(entry, "link", rel = "edit", type = "application/atom+xml",
              href = update_fodder$edit_link[1])
#> {xml_node}
#> <link>
xml_add_child(entry, "gs:cell", row = as.character(update_fodder$row[1]),
              col = as.character(update_fodder$col[1]),
              inputValue = update_fodder$update_value[1])
#> {xml_node}
#> <cell>
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
xml_ns(feed)
#> d1    <-> http://www.w3.org/2005/Atom
#> batch <-> http://schemas.google.com/gdata/batch
#> gs    <-> http://schemas.google.com/spreadsheets/2006
xml_ns(foo)
#>  <->
```
