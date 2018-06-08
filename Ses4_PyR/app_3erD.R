library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)

ui <- dashboardPage(
  dashboardHeader(title="Análisis de Twitter"#,
                  #dropdownMenu(type="message", 
                   #             messageItem(from="Finance update", message="hola mundo"))
                  ),
  dashboardSidebar(
    sidebarMenu(
    menuItem("Campañas"),
      menuSubItem("Anaya", tabName = "anaya", icon=icon("bicycle")),
      menuSubItem("AMLO", tabName = "amlo", icon=icon("edit")),
      menuSubItem("Meade", tabName = "meade", icon=icon("envira")),
      menuSubItem("Debate", tabName = "debate", icon = icon("dashboard")),
    menuItem("Registros"),
    sliderInput("bins", "Tweets coniderados",1,100,50)
  )),
  dashboardBody(
    tabItems(
      tabItem(tabName = "anaya", fluidRow(box(title="Menciones",plotOutput("ploteo")))),
      tabItem(tabName = "amlo", h1("AMLO")),
      tabItem(tabName = "meade", h2("MEADE")),
      tabItem(tabName = "debate", h3("DEBATE"))
    )
  )
)

server <- function(input, output) {
  output$ploteo <- renderPlot({
    hist(faithful$eruptions, breaks= input$bins)
  })
}
shinyApp(ui, server)

