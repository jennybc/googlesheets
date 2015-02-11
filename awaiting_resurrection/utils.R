#' Convert column IDs from letter representation to numeric
#'
#' @param x character vector of letter-style column IDs (case insensitive)
letter_to_num <- function(x) {
  x %>%
    stringr::str_to_upper %>%
    stringr::str_split('') %>% 
    plyr::llply(match, table = LETTERS) %>%
    plyr::laply(function(z) sum(26 ^ rev(seq_along(z) - 1) * z)) %>%
    unname
}


#' Convert column IDs from numeric to letter representation
#'
#' @param x vector of numeric column IDs
num_to_letter <- function(x) {
  stopifnot(x <= letter_to_num('ZZ')) # Google spreadsheets have 300 columns max
  paste0(c("", LETTERS)[((x - 1) %/% 26) + 1],
         LETTERS[((x - 1) %% 26) + 1], sep = "")
}

#' Convert label (A1) notation to coordinate (R1C1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells.
#'
#' @param x label notation for position of cell
label_to_coord <- function(x) {
  paste0("R", stringr::str_extract(x, "[[:digit:]]*$") %>% as.integer,
         "C", stringr::str_extract(x, "^[[:alpha:]]*") %>% letter_to_num)
}


#' Convert coordinate (R1C1) notation to label (A1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells.
#'
#' @param x coord notation for position of cell
coord_to_label <- function(x) {
  paste0(sub("^R[0-9]+C([0-9]+)$", "\\1", x) %>% as.integer %>% num_to_letter,
         sub("^R([0-9]+)C[0-9]+$", "\\1", x))
}


#' Set header for data frame 
#'
#' Take first row of data frame and make it the header. Rownames are also reset.
#'
#' @param x a data frame.
set_header <- function(x)
{
  names(x) <- x[1, ]
  x <- x[2:nrow(x), ]
  rownames(x) <- NULL
  x
}


#' Determine the number of cells in the range
#' 
#' @param range character string for range value
#'
#' @return numeric value for count of cells in range.
ncells <- function(range)
{
  bounds <- unlist(strsplit(range, split = ":"))
  rows <- as.numeric(gsub("[^0-9]", "", bounds))  
  cols <- unname(sapply(gsub("[^A-Z]", "", bounds), letter_to_num))
  
  i <- seq(rows[1], rows[2])
  j <- seq(cols[1], cols[2])
  cells_in_range <- expand.grid(i, j)
  nrow(cells_in_range)
}


#' Determine the range occupied by a data frame
#' 
#' @param dat a data frame
#' @param anchor position of cell used as an "anchor"
#' @param header \code{logical} indicating whether the header of the data should 
#' be included in the range
#'
#' @return character string for the range taken up by a data frame
build_range <- function(dat, anchor, header) {
  
  if(!is.data.frame(dat)) {
    row <- 0
    col <- length(dat) - 1
  } else {
    
    if(header) {
      row <- nrow(dat)
    } else { 
      row <- nrow(dat) - 1 
    }
    col <- ncol(dat) - 1
  }
  
  letter <- unlist(strsplit(anchor, "[0-9]+"))
  
  right_col_num <- letter_to_num(letter) + col
  right_col_letter <- num_to_letter(right_col_num)
  
  row_num <- gsub("[[:alpha:]]", "", anchor)
  bottom_row <- as.numeric(row_num) + row
  
  paste0(anchor, ":", right_col_letter, bottom_row)
}



#' Fill in missing tuples for lookup table
#' 
#' The lookup table returned by get_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of every column or every column 
#' up to the right-most column of every row. 
#' 
#' @param lookup_tbl data frame returned by \code{\link{get_lookup_tbl}}
#' @param row_min top-most row to start 
#' @param col_min left-most column to start
#' @param row_only \code{logical}, set to \code{TRUE} to fill missing rows only 
#' 
#' @importFrom dplyr arrange mutate
#' @importFrom plyr ddply
fill_missing_tbl <- function(lookup_tbl, row_min = 1, col_min = 1, 
                             row_only = FALSE) 
{
  if(row_only) {
    lookup_tbl_clean1 <- ddply(lookup_tbl, "col", 
                               function(x) fill_missing_row(x, row_min))
  } else {
    lookup_tbl_clean <- ddply(lookup_tbl, "row", 
                              function(x) fill_missing_col(x, col_min))
    lookup_tbl_clean1 <- ddply(lookup_tbl_clean, "col", 
                               function(x) fill_missing_row(x, row_min))
    
    lookup_tbl_clean1$row <- as.numeric(lookup_tbl_clean1$row)
  }
  
  lookup_tbl_clean1$col <- as.numeric(lookup_tbl_clean1$col)
  arrange(lookup_tbl_clean1, row, col) 
}

#' Fill in missing columns in a row
#' 
#' The lookup table returned by \code{\link{get_lookup_tbl}} may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every column up to the right-most column of the row.
#' 
#' @param x data frame returned by \code{\link{get_lookup_tbl}}
#' @param col_min leftmost column that row begins at
#' 
#' @note This function operates on the lookup table grouped by row.
#'
fill_missing_col <- function(x, col_min) 
{
  r <- as.numeric(x$col)
  
  for(i in col_min: max(r)) {
    if(is.na(match(i, r))) {
      new_tuple <- c(unique(x$row), i, NA)
      x <- rbind(x, new_tuple)
    }
  }
  x
} 


#' Fill in missing rows in column
#' 
#' The lookup table returned by \code{\link{get_lookup_tbl}} may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of the column.
#' 
#' @param x data frame returned by \code{\link{get_lookup_tbl}}
#' @param row_min top-most row that column begins at
#' 
#' @note This function operates on the lookup table grouped by column.
#'
fill_missing_row <- function(x, row_min) 
{
  r <- as.numeric(x$row)
  
  for(i in row_min: max(r)) {
    if(is.na(match(i, r))) {
      new_tuple <- c(i, unique(x$col), NA)
      x <- rbind(x, new_tuple)
    }
  }
  x
}


#' Check if worksheet is empty
#'
#' Throw an error if worksheet is empty
#'
#' @param ws worksheet object
check_empty <- function(ws) {
  if(ws$nrow == 0)
    stop("Worksheet does not contain any values.")
}


#' Wrapper around xmlInternalTreeParse
#'
#' Simply for code neatness.
#'
#' @param req response from \code{\link{gsheets_GET}} request
#' @importFrom XML xmlInternalTreeParse
gsheets_parse <- function(req) 
{
  xmlInternalTreeParse(req)
}


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

#' paste with separator set to slash
#' 
#' paste with separator set to slash, for use in building URLs 
#' 
#' @param ... one or more R objects, to be converted to character vectors
slaste <- function(...) paste(..., sep = "/")

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

#' Retrieve a worksheet from a spreadsheet
#' 
#' Retrieve a worksheet from a spreadsheet based on either a positive integer
#' index or worksheet title.
#' 
#' @param ss a registered spreadsheet
#' @param ws a positive integer or character string specifying which worksheet
get_ws <- function(ss, ws) {
  if(is.character(ws)) {
    index <- match(ws, ss$ws$ws_title)
    if(is.na(index)) {
      stop(sprintf("Worksheet %s not found.", ws))    
    } else {
      ws <- index
    }
  }
  if(ws > ss$n_ws) {
    stop(sprintf("Spreadsheet only contains %d worksheets.", ss$n_ws)) 
  }
  ss$ws[ws, ]
}

#' Filter a list by name
#' 
#' @param x a list
#' @param name a regular expression
lfilt <- function(x, name, ...) {
  x[grep(name, names(x), ...)]
}

#' Pluck out elements from list components by name
#' 
#' @param x a list
#' @param xpath a string giving the name of the component you want, XPath style
#' 
#' Examples: ...
llpluck <- function(x, xpath) {
  x %>% plyr::llply("[[", xpath) %>% plyr::llply(unname)
}
lapluck <- function(x, xpath) {
  x %>% plyr::laply("[[", xpath) %>% unname
}

#' OMG this is just here to use during development, i.e. after
#' devtools::load_all(), when inspecting big hairy lists
str1 <- function(...) str(..., max.level = 1)