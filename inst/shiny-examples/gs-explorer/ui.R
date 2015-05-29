library(shiny)
library(shinythemes)
library(DT)

shinyUI(fluidPage(#theme = shinytheme("cerulean"),

  titlePanel("My Google Sheets Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      h3(textOutput("greeting")),
      br(),
      wellPanel(uiOutput("currentUser")),
      uiOutput("loginButton"),
      br(),
      uiOutput("selectSheet"),
      br(),
      br(),
      uiOutput("logoutButton"),
      br(),
      h6(a("Click Here to See Code", href="https://github.com/jennybc/googlesheets", target="_blank"))
    ),
    mainPanel(
      tabsetPanel(id = "panel",
        tabPanel("All Sheets",
                 h4(textOutput("introInfo")),
                 DT::dataTableOutput("gsLs")),
        tabPanel("Sheet Info", 
                 h2("Spreadsheet Info"),
                 DT::dataTableOutput("sheetInfo"),
                 h3("Worksheets contained:"),
                 DT::dataTableOutput("sheetWsInfo")),
        tabPanel("Sheet Inspection", 
                 uiOutput("selectWs"),
                 plotOutput("plotSheet"))
      )
    )
  )
))