#' ---
#' output: github_document
#' ---

#+ setup, include = FALSE
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)

#' Task: create XML to update contents of cells in a Google Sheet.
#'
#' Here's how I currently do it with the XML package.
library(readr)
library(XML)
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

#' Installing / verifying `xml2` from the relevant PR.
#+ xml2-setup
#devtools::install_github("hadley/xml2#76")
si <- devtools::session_info("xml2")$packages
si$source[si$package == "xml2"]

#' Current approach given by @jimhester.
#+ xml2-write
library(xml2)
d <- xml_new_document() %>%
  xml_add_child("feed",
                xmlns = "http://www.w3.org/2005/Atom",
                "xmlns:batch" = "http://schemas.google.com/gdata/batch",
                "xmlns:gs" = "http://schemas.google.com/spreadsheets/2006")

d %>% xml_add_child("id", africa_cellsfeed)
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

#' How does this compare to the output from the `XML` package? `xml2` adds an
#' XML declaration.
#+ xml-diff, engine='bash'
diff -b -U 0 27_feed-node-XML.xml 27_feed-node-xml2.xml

#' Can `xml2` roundtrip it's own XML? I.e. the new linebreaks don't cause
#' trouble? I wonder because of <https://github.com/hadley/xml2/issues/49>.
rt <- read_xml("27_feed-node-xml2.xml")
identical(as_list(d), as_list(rt))
head(all.equal(as_list(d), as_list(rt)))
xml_children(d)[[2]]
xml_children(rt)[[2]]
as_list(xml_children(d)[[2]])
as_list(xml_children(rt)[[2]])
#' No, the linebreaks do cause problems!
#'
#' But notice it doesn't affect XML written to file.
write_xml(rt, "27_feed-node-xml2-roundtrip.xml")

#+ xml2-diff, engine='bash'
diff -b 27_feed-node-xml2.xml 27_feed-node-xml2-roundtrip.xml

#' __Everything below here is old.__
#'
#' Here's my original rough pass at writing XML with xml2. Done with
#' jimhester/xml2@04a83fe, which is now out-of-date. Code is not run.
#+ xml2-first-pass, eval = FALSE
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

#' Observations about the XML vs xml2 result (other than the scale up)
#'
#' * Why no line breaks in the xml2 output? would be so much easier to look at
#' * xml2 insists on adding `<?xml version="1.0"?>` as first line; will this
#' matter? I have no idea
#' * XML uses shorter form for elements with no content; I assume this is of no
#' practical significance
#' * xml2 requires me to explicitly convert things to character (see the row and
#' col attributes of gs:cell node)
#'
#' Re setting the namespaces: the current method feels a bit weird. It feels
#' like I should be able to provide a character vector, with possibly one
#' unnamed element (the first one?) for the default namespace. You might also
#' expect that the output of `xml_ns()` could somehow be used to set namespace?
#' But that does not work.
foo <- xml_add_child(xml_new_document(), "feed", xml_ns(feed))
xml_ns(feed)
xml_ns(foo)
