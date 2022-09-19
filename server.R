source("Model/GetProbability.R")
source("Model/GetGraph.R")

library(data.table)
probabilities <- fread("Data\\overall_probabilities.csv")
betstape <- fread("Data\\InCSV\\tickdata_betstape.csv")
markets <- fread("Data\\InCSV\\tickdata_markets.csv")
selections <- fread("Data\\InCSV\\tickdata_selections.csv")

server <- function(input, output) {
  event_name <- reactive(input$event_name)
  event_name_deb <- debounce(event_name, 1000)
  timemoment <- reactive(input$time)
  timemoment_deb <- debounce(timemoment, 1000)
  outcome <- reactive(input$outcome_name)
  outcome_deb <- debounce(outcome, 1000)

  output$table1 <- renderTable({
    names <- unique(probabilities$name)
    host <- probabilities[probabilities$selection=="HOST WINS", ]$probability
    draw <- probabilities[probabilities$selection=="DRAW", ]$probability
    guest <- probabilities[probabilities$selection=="GUEST WINS", ]$probability
    probabilities_wide <- data.frame(name = names,
                                     host_wins = host,
                                     draw = draw,
                                     guest_wins = guest)
    probabilities_wide
  })
  output$table2 <- renderTable({
    evt_id <- probabilities$id[probabilities$name == event_name_deb()]
    selection <- -1
    if (outcome_deb() == "HOST WINS") {
      selection <- 1
    } else if (outcome_deb() == "DRAW") {
      selection <- 2
    } else if (outcome_deb() == "GUEST WINS") {
      selection <- 3
    }
    dat <- GetDataFromCSV(evt_id, betstape, markets, selections)
    forecast <- GetForecast(timemoment_deb(), dat, selection, 1000, iStart = 1)
    res <- data.frame(name = character(5), value = character(5))
    res$name[1] <- "event name"
    res$value[1] <- event_name_deb()
    res$name[2] <- "outcome"
    res$value[2] <- outcome_deb()
    res$name[3] <- "estimated probability"
    res$value[3] <- forecast$mu
    res$name[4] <- "estimated error"
    res$value[4] <- forecast$sgm
    res$name[5] <- "accumulated volume"
    res$value[5] <- forecast$j
    res
  })
}
