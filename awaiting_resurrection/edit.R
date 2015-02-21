#' Rename a worksheet
#'
#' @param ss spreadsheet object
#' @param old_title worksheet's current title
#' @param new_title worksheets's new title
#' 
#' @export
rename_worksheet <- function(ss, old_title, new_title)
{
  index <- match(old_title, names(ss$worksheets))
  
  if(is.na(index))
    stop("Worksheet not found.")
  
  ws <- ss$worksheets[[index]]
  
  req_url <- build_req_url("worksheets", key = ss$sheet_id, ws_id = ws$ws_id)
  req <- gsheets_GET(req_url)
  feed <- gsheets_parse(req)
  
  edit_url <- unlist(getNodeSet(feed, '//ns:link[@rel="edit"]', 
                                c("ns" = default_ns),
                                function(x) xmlGetAttr(x, "href")))
  
  new_feed <- sub(old_title, new_title, toString.XMLNode(feed))
  
  gsheets_PUT(edit_url, new_feed)
}
