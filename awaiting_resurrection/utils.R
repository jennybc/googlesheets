#' Plot worksheet
#'
#' @param tbl data frame returned by \code{\link{get_lookup_tbl}}
make_plot <- function(tbl)
{
  ggplot(data = tbl, aes(x = col, y = row)) +
    geom_tile(width = 1, height = 1, fill = "steelblue2", alpha = 0.4) +
    facet_wrap(~ Sheet) +
    scale_x_continuous(breaks = seq(1, max(tbl$col), 1), expand = c(0, 0),
                       limits = c(1 - 0.5, max(tbl$col) + 0.5)) +
    annotate("text", x = seq(1, max(tbl$col), 1), y = (-0.05) * max(tbl$row), 
             label = LETTERS[1:max(tbl$col)], colour = "blue",
             fontface = "bold") +
    scale_y_reverse() +
    ylab("Row") +
    theme(panel.grid.major.x = element_blank(),
          plot.title = element_text(face = "bold"),
          axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          axis.ticks.x = element_blank())
}



#' Generate a cells feed to update cell values
#' 
#' Create an update feed for the new values.
#' 
#' @param feed cell feed returned and parsed from GET request
#' @param new_values vector of new values to update cells 
#' 
#' @importFrom XML xmlNode
#' @importFrom dplyr mutate
#' @importFrom plyr dlply
create_update_feed <- function(feed, new_values)
{
  tbl <- get_lookup_tbl(feed)
  
  self_link <- getNodeSet(feed, '//ns:entry//ns:link[@rel="self"]', 
                          c("ns" = default_ns),
                          function(x) xmlGetAttr(x, "href"))  
  
  edit_link <- getNodeSet(feed, '//ns:entry//ns:link[@rel="edit"]', 
                          c("ns" = default_ns),
                          function(x) xmlGetAttr(x, "href"))
  
  dat_tbl <- mutate(tbl, self_link = unlist(self_link), 
                    edit_link = unlist(edit_link), 
                    new_vals = new_values,
                    row_id = 1:nrow(tbl))
  
  req_url <- unlist(getNodeSet(feed, '//ns:id', 
                               c("ns" = default_ns), xmlValue))[1]
  
  listt <- dlply(dat_tbl, "row_id", make_entry_node)
  new_list <- unlist(listt, use.names = FALSE)
  nodes <- paste(new_list, collapse = "\n" )
  
  # create entry element 
  the_body <- 
    xmlNode("feed", 
            namespaceDefinitions = 
              c(default_ns, 
                batch = "http://schemas.google.com/gdata/batch",
                gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("id", req_url)
    )
  
  new_body <- gsub("</feed>", paste(nodes, "</feed>", sep = "\n"), 
                   toString.XMLNode(the_body))
  new_body
}


#' Make entry element
#' 
#' Make the new value into an entry element required by the update feed. 
#' 
#' @param x a character string or numeric 
#' @importFrom XML xmlNode toString.XMLNode
make_entry_node <- function(x)
{
  node <- xmlNode("entry",
                  xmlNode("batch:id", paste0("R", x$row, "C", x$col)),
                  xmlNode("batch:operation", attrs = c(type = "update")),
                  xmlNode("id", x$self_link),
                  xmlNode("link", 
                          attrs = c("rel" = "edit", 
                                    "type" = "application/atom+xml",
                                    "href" = x$edit_link)),
                  xmlNode("gs:cell", attrs = c("row" = x$row, "col" = x$col, 
                                               "inputValue" = x$new_vals)))
  toString.XMLNode(node)
}  

#' Wrangle the namespace definitions of an XML node
#' 
#' Make the namespace definitions of an XML node actually usable in downstream 
#' queries
#' 
#' @param xml_node the \code{XMLNode} object in which to find any namespace 
#'   definitions
#'   
#' @return a named character vector of namespaces
#'   
#'   "Dealing with expressions that relate to the default namespaces in the XML 
#'   document can be confusing." This is a quote from the documentation of 
#'   \code{\link{XML::getNodeSet}} and it is, in fact, an understatement. The 
#'   XML querying functions expect the namespaces as a named character vector, 
#'   where the values are URIs and the names are prefixes. However, the function
#'   \code{\link{XML::xmlNamespaceDefinitions}} gets the namespace definitions 
#'   as a list, by default, although it will return a named character vector if 
#'   you specify \code{simplify = TRUE}. Perversely, the first element -- which 
#'   I assume to be the default namespace -- will have no name, because it is 
#'   not associated with any prefix. And this simply will not do! This helper 
#'   function prepares the namespace information for downstream use by getting 
#'   it as a character vector and specifying "ns" as the name/prefix of the 
#'   first element, assumed to correspond to the default namespace. I don't
#'   think I'm crazy, because I adapted this stickhandling code from the
#'   official examples
#'   
#'   See 
#'   http://stackoverflow.com/questions/24954792/xpath-and-namespace-specification-for-xml-documents-with-an-explicit-default-nam
#'    for another example of a similar workaround, also presumably inspired by 
#'   the official docs.
#'   
#'   @examples 
#'   ns <- rig_namespace(req$content)
rig_namespace <- function(xml_node) {
  ns <- xml_node %>% XML::xmlNamespaceDefinitions(simplify = TRUE)
  names(ns)[1] <- "ns"
  ns
}
