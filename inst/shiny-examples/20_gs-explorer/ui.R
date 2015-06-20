library(shiny)
#library(shinythemes)
library(DT)

shinyUI(fluidPage(#theme = shinytheme("cerulean"),

  titlePanel("My Google Sheets Explorer"),

  sidebarLayout(
    sidebarPanel(
      h3(textOutput("greeting")),
      br(),
      wellPanel(uiOutput("currentUser")),
      br(),
      uiOutput("loginButton"),
      br(),
      uiOutput("selectSheet"),
      br(),
      uiOutput("logoutButton"),
      br(),
      ## Make this link more specific when final name and location settles
      h5(a("Click Here to See Code on Github",
           href="https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples",
           target="_blank"))
    ),
    mainPanel(
      tabsetPanel(id = "panel",
        tabPanel("All Sheets",
                 DT::dataTableOutput("listSheets")),
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
