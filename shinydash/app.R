

library(shiny)
library(tidyverse)

# Define UI --------------------------

ui <- fluidPage(
  titlePanel(h1("EpiSTEMas Media Kit",
             h3("Un podcast semanal de",span("Ciencia",style="color:#f5dd3a"),"&",span("Tecnología", style="color:#6bcbe3")))),
  
  sidebarLayout(position = "left",
    sidebarPanel(
      h2("Estadisticas"),
      h2("Patrocinios"),
      h2("Lo que dicen..."),
      img(src = "epiSTEMas_logo.png", height = 80)
    ),
    
    mainPanel(
      plotOutput('streamsts'),
      h2("Audiencia", style = 'color:#6bcbe3'),
      h3("De donde nos escuchan:"),
      h3("Quienes nos escuchan:"),
      h2("Invitados e invitadas", style = "color:#f5dd3a"),
      h3("Nacionalidades?"),
      h3("Temas"),
      h2("Otras estadisticas/alcance", style = "color:#986538")
    ),
  )
)


# Server component -------------------

server <- function(input, output){
  
  streams <- read_csv("/data/EpistemasStreams.csv")
  
  # renderPlot() function indicates it is "reactive" and therefore should be
  # automatically re-executed when inputs change.
  
  output$streamsts <- renderPlot({
    streamsts <- ggplot(streams, aes(x=date)) +
      geom_line(aes(y=streamsSpot), color="blue") +
      geom_line(aes(y=ivoox), color="red")
  })
  
  
  
  
  
  
  
  
  
  
  
}




# Call shinyApp ----------------------

shinyApp(ui = ui, server = server)