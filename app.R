library(shiny)
library(data.table)

source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)