library(shiny)
library(shinythemes)

shinyUI(
  fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Craigslist Lost & Found"),
    sidebarLayout(
      sidebarPanel(
        h6(paste("This app is hard-wired to read a single, public Google",
                 "Sheet that uses the IMPORTXML function.")),
        h6("Visit the Sheet in the browser:",
           a("HERE", href = "https://docs.google.com/spreadsheets/d/1qtvN-PKWvIbmTJ-RSmga1m2iGn7Mze4w_yRg9ZJx2TU/",
             target="_blank")),
        h6(a("Click Here to See Code on Github",
             href="https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples/03_craigslist-lost-and-found",
             target="_blank")),
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
