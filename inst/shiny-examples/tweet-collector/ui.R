library(shiny)
library(DT)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("flatly"),
  
  titlePanel("Tweet Collector"),
  sidebarLayout(
    sidebarPanel(
      h4("Try a hashtag, or use search operators like AND OR, as well as from: 
         and to: eg '#JobsNow AND from:BarackObama' (without quotes)"),
      textInput("search", label = NULL, value = ""),
      uiOutput("numTweets"),
      br(),
      actionButton("searchBtn", "Search"),
      br(),
      uiOutput("selectCols"),
      br(),
      h3("Stats"),
      DT::dataTableOutput("tweetStats"),
      br(),
      br(),
      downloadButton("download", label = "Download")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Summary", DT::dataTableOutput("tweetsTable"))
      )
    )
  )
))