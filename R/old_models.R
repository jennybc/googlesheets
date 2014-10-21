# # following example from:
# # http://stackoverflow.com/questions/11561284/classes-in-r-from-a-python-background
# 
# # spreadsheet class -----
# 
# setClass("spreadsheet", 
#          slots = list(sheet_id = "character",
#                       updated = "character",
#                       sheet_title = "character",
#                       nsheets = "numeric",
#                       sheet_names = "character",
#                       worksheets = "list" # list of worksheet objects
#          ))
# 
# # setter methods
# 
# # Note that the second argument to a function that is defined with setReplaceMethod() must be named value
# setGeneric("sheet_id<-", function(self, value) standardGeneric("sheet_id<-"))
# setReplaceMethod("sheet_id", "spreadsheet", 
#                  function(self, value) {
#                    self@sheet_id <- value
#                    self
#                  }
# )
# 
# setGeneric("updated<-", function(self, value) standardGeneric("updated<-"))
# setReplaceMethod("updated", "spreadsheet", 
#                  function(self, value) {
#                    self@updated <- value
#                    self
#                  }
# )
# 
# setGeneric("sheet_title<-", function(self, value) standardGeneric("sheet_title<-"))
# setReplaceMethod("sheet_title", 
#                  "spreadsheet", 
#                  function(self, value) {
#                    self@sheet_title <- value
#                    self
#                  }
# )
# 
# setGeneric("nsheets<-", function(self, value) standardGeneric("nsheets<-"))
# setReplaceMethod("nsheets", "spreadsheet", 
#                  function(self, value) {
#                    self@nsheets <- value
#                    self
#                  }
# )
# 
# setGeneric("worksheets<-", function(self, value) standardGeneric("worksheets<-"))
# setReplaceMethod("worksheets", "spreadsheet", 
#                  function(self, value) {
#                    self@worksheets <- value
#                    self
#                  }
# )
# 
# setGeneric("sheet_names<-", function(self, value) standardGeneric("sheet_names<-"))
# setReplaceMethod("sheet_names", "spreadsheet", 
#                  function(self, value) {
#                    self@sheet_names <- value
#                    self
#                  }
# )
# 
# # GETTERS
# 
# setGeneric("sheet_id", function(self) standardGeneric("sheet_id"))
# setMethod("sheet_id", 
#           signature(self = "spreadsheet"), 
#           function(self) {
#             self@sheet_id
#           }
# )
# 
# setGeneric("updated", function(self) standardGeneric("updated"))
# setMethod("updated", 
#           signature(self = "spreadsheet"), 
#           function(self) {
#             self@updated
#           }
# )
# 
# setGeneric("sheet_title", function(self) standardGeneric("sheet_title"))
# setMethod("sheet_title", 
#           signature(self = "spreadsheet"), 
#           function(self) {
#             self@sheet_title
#           }
# )
# 
# setGeneric("nsheets", function(self) standardGeneric("nsheets"))
# setMethod("nsheets", 
#           signature(self = "spreadsheet"), 
#           function(self) {
#             self@nsheets
#           }
# )
# 
# setGeneric("worksheets", function(self) standardGeneric("worksheets"))
# setMethod("worksheets", 
#           signature(self = "spreadsheet"), 
#           function(self) {
#             self@worksheets
#           }
# )
# 
# setGeneric("sheet_names", function(self) standardGeneric("sheet_names"))
# setMethod("sheet_names", 
#           signature(self = "spreadsheet"), 
#           function(self) {
#             self@sheet_names
#           }
# )
# 
# # worksheet class -----
# 
# setClass("worksheet", 
#          slots = list(ws_id = "character",
#                       ws_title = "character",
#                       ws_url = "character", 
#                       ws_listfeed = "character",
#                       ws_cellsfeed = "character"))
# 
# # setter methods
# 
# setGeneric("ws_id<-", function(self, value) standardGeneric("ws_id<-"))
# setReplaceMethod("ws_id", "worksheet", 
#                  function(self, value) {
#                    self@ws_id <- value
#                    self
#                  }
# )
# 
# setGeneric("ws_title<-", function(self, value) standardGeneric("ws_title<-"))
# setReplaceMethod("ws_title", "worksheet", 
#                  function(self, value) {
#                    self@ws_title <- value
#                    self
#                  }
# )
# 
# setGeneric("ws_url<-", function(self, value) standardGeneric("ws_url<-"))
# setReplaceMethod("ws_url", "worksheet", 
#                  function(self, value) {
#                    self@ws_url <- value
#                    self
#                  }
# )
# 
# setGeneric("ws_listfeed<-", function(self, value) standardGeneric("ws_listfeed<-"))
# setReplaceMethod("ws_listfeed", "worksheet", 
#                  function(self, value) {
#                    self@ws_listfeed <- value
#                    self
#                  }
# )
# 
# setGeneric("ws_cellsfeed<-", function(self, value) standardGeneric("ws_cellsfeed<-"))
# setReplaceMethod("ws_cellsfeed", "worksheet", 
#                  function(self, value) {
#                    self@ws_cellsfeed <- value
#                    self
#                  }
# )
# 
# # getter methods
# 
# setGeneric("ws_id", function(self) standardGeneric("ws_id"))
# setMethod("ws_id", 
#           signature(self = "worksheet"), 
#           function(self) {
#             self@ws_id
#           }
# )
# 
# setGeneric("ws_title", function(self) standardGeneric("ws_title"))
# setMethod("ws_title", 
#           signature(self = "worksheet"), 
#           function(self) {
#             self@ws_title
#           }
# )
# 
# setGeneric("ws_url", function(self) standardGeneric("ws_url"))
# setMethod("ws_url", 
#           signature(self = "worksheet"), 
#           function(self) {
#             self@ws_url
#           }
# )
# 
# setGeneric("ws_listfeed", function(self) standardGeneric("ws_listfeed"))
# setMethod("ws_listfeed", 
#           signature(self = "worksheet"), 
#           function(self) {
#             self@ws_listfeed
#           }
# )
# 
# setGeneric("ws_cellsfeed", function(self) standardGeneric("ws_cellsfeed"))
# setMethod("ws_cellsfeed", 
#           signature(self = "worksheet"), 
#           function(self) {
#             self@ws_cellsfeed
#           }
# )
# 
# setGeneric("dim_count", function(self) standardGeneric("dim_count"))
# setMethod("dim_count", 
#           signature(self = "worksheet"), 
#           function(self) {
#             
#             xx<- GET(self@ws_listfeed)
#             
#             xxx <- xmlInternalTreeParse(xx)
#             
#             nodes_for_rows <- getNodeSet(xxx, "//x:content", "x")
#             
#             col_counts <- lapply((strsplit(xmlSApply(nodes_for_rows, xmlValue), ",")), length)
#             
#             col_count <- max(unlist(col_counts)) + 1 # to add back first col
#             
#             row_count <- length(col_counts) + 1 # to add back header row
#             
#             dims <- c(row_count, col_count)
#             
#             names(dims) <- c("row", "col")
#             
#             dims
#           }
# )
# 
# setGeneric("row_count", function(self) standardGeneric("row_count"))
# setMethod("row_count", 
#           signature(self = "worksheet"), 
#           function(self) {
#             
#             #             xx <- GET(self@ws_listfeed)
#             #             
#             #             xxx <- xmlInternalTreeParse(xx)
#             #             
#             #             row_count <- length(getNodeSet(xxx, "//x:entry", "x")) + 1 #to add back header row
#             
#             row_count <- dim_count(self)[1]
#             
#             row_count
#             
#           }
# )
# 
# setGeneric("col_count", function(self) standardGeneric("col_count"))
# setMethod("col_count", 
#           signature(self = "worksheet"), 
#           function(self) {
#             
#             #             xx<- GET(self@ws_listfeed)
#             #             
#             #             xxx <- xmlInternalTreeParse(xx)
#             #             
#             #             nodes_for_rows <- getNodeSet(xxx, "//x:content", "x")
#             #             
#             #             col_counts <- lapply((strsplit(xmlSApply(nodes_for_rows, xmlValue), ",")), length)
#             #             
#             #             col_count <- max(unlist(col_counts)) + 1 # to add back first col
#             #             
#             col_count <- dim_count(self)[2]
#             
#             col_count
#             
#           }
# )
# 
# setGeneric("get_dataframe", function(self) standardGeneric("get_dataframe"))
# setMethod("get_dataframe", 
#           signature(self = "worksheet"), 
#           function(self) {
#             
#             xx<- GET(self@ws_cellsfeed)
#             
#             xxx <- xmlInternalTreeParse(xx)
#             
#             cell_nodes <- getNodeSet(xxx, "//x:content", "x")
# 
#             vec <- xmlSApply(cell_nodes, xmlValue)
#             
#             dims <- dim_count(self)
#             
#             my_data <- data.frame(matrix(vec, nrow = dims[1], 
#                               ncol = dims[2], byrow = TRUE, 
#                               dimnames = list(NULL, c(vec[1:dims[2]]))))[-1,]
#             
#             rownames(my_data) <- seq(1 : nrow(my_data))
#             
#             my_data
#             
#           }
# )
