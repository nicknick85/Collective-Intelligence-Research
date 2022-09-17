library(data.table)

probabilities <- fread("Data\\overall_probabilities.csv")
betstape <- fread("Data\\InCSV\\tickdata_betstape.csv")
markets <- fread("Data\\InCSV\\tickdata_markets.csv")
selections <- fread("Data\\InCSV\\tickdata_selections.csv")

ui <- fluidPage(
  titlePanel("Observer"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("event_name", "Select event",
                  choices = unique(probabilities$name)),
      selectInput("outcome_name", "Select outcome",
                  choices = unique(probabilities$selection)),
      sliderInput(inputId = "time",
                  label = "Select time moment",
                  min = 0,
                  max = 1,
                  value = 1)
    ),
    
    mainPanel(
      tabsetPanel(tabPanel("Overall information", tableOutput("table1")),
                  tabPanel("Detailed information", tableOutput("table2")))
    )
  )
)