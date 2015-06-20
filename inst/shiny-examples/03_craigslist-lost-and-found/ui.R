library(shiny)
library(shinythemes)

shinyUI(
  fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Craigslist Lost & Found"),
    sidebarLayout(
      sidebarPanel(
        h6(paste("Post types are identified by keywords (lost', 'missing', 'stolen', or 'found') in the description of a post.",
                 "Posts are identified as 'unknown' if those keywords cannot be detected.")),
        uiOutput("selectedDate"),
        br(),
        plotOutput("plotDailyData"),
        br(),
        br(),
        uiOutput("dateRange"),
        br(),
        checkboxInput("postTypes", "Compare post types")
      ),
      mainPanel(
        DT::dataTableOutput("dataForDay"),
        h3("Total Number of Posts"),
        plotOutput("plotDataCount")
      )
    )
  ))
