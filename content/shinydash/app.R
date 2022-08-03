
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(treemap)
library(rnaturalearth) # for maps
library(plotly)
library(leaflet)

# LOAD DATA ---

streams <- read_csv("data/EpistemasStreams.csv")
streams$date <- as.Date(streams$date, "%d-%m-%y")

weeks <- as.Date(cut(streams$date,
                            breaks = "week",
                            start.on.monday = T))
desc <- streams$streamsSpot+streams$ivoox
weekly <- cbind.data.frame(weeks, desc)



guests <- read_csv("data/EpistemasGuests.csv")
guests$pregrado <- as.factor(guests$pregrado)
guests$stem <- as.factor(guests$stem)
guests$nacionalidad <- as.factor(guests$nacionalidad)

streams_paises <- read_csv("data/EpistemasPaisStr.csv")

streams_paises <- streams_paises %>%
  mutate(Total = Spotify+Ivoox)

redes <- read_csv("data/EpistemasRedes.csv")

gen <- read_csv("data/EpistemasGenero.csv")

edad <- read_csv("data/EpistemasEdad.csv")

# Define UI --------------------------


ui <- fluidPage(
  tags$h2(img(src = "epiSTEMas_Logo.png", height = 80, width = 80), "Epistemas Media Kit"), 
  tags$h5("última actualización de datos: 31 de julio 2022"),
  
  setBackgroundColor(color = "black"),
  useShinydashboard(),

  tags$style(".small-box.bg-green { background-color: #1db954 !important; color: #000000 !important; }"),
  tags$style(".small-box.bg-purple { background-color: #872ec4 !important; color: #000000 !important; }"),
  tags$style(".small-box.bg-fuchsia { background-color: #E4405F !important; color: #000000 !important; }"),
  tags$style(".small-box.bg-aqua { background-color: #f5dd3a !important; color: #000000 !important; }"),
  tags$style(".small-box.bg-blue { background-color: #1877F2 !important; color: #000000 !important; }"),
  tags$style(".small-box.bg-light-blue { background-color: #1DA1F2 !important; color: #000000 !important; }"),
  tags$style(".small-box.bg-yellow { background-color: #6bcbe3 !important; color: #000000 !important; }"),
  tags$style(".small-box.bg-navy { background-color: #0A66C2 !important; color: #000000 !important; }"),
  tags$style(HTML(".fa-spotify { font-size: 50px; }")),
  tags$style(HTML(".fa-headphones { font-size: 50px; }")),
  tags$style(HTML(".fa-link { font-size: 50px; }")),
  tags$style(HTML(".fa-newspaper { font-size: 50px; }")),
  tags$style(HTML(".fa-instagram { font-size: 50px; }")),
  tags$style(HTML(".fa-facebook { font-size: 50px; }")),
  tags$style(HTML(".fa-twitter { font-size: 50px; }")),
  tags$style(HTML(".fa-linkedin { font-size: 50px; }")),
  tags$style("h2, p { color: #ffffff; }"),
  tags$style("h5 { color: #656565; }"),
  tags$style("text {font-size: 25px; color: #242526;}"),
  
  
  fluidRow(
#    infoBox(width = 2, "Seguidores Spotify", tags$text(redes[1, 2]), icon = icon("spotify"), fill=T, color = "green")),
        column(2, tags$p("Podcasts"), offset = 1,
               fluidRow(
                 valueBox(
                   uiOutput("spotify"), value = tags$text(redes[1, 2], style = "font-size: 75%"), subtitle = "Seguidores en Spotify",
                   icon = icon("spotify"), color = "green"),
                 valueBox(
                   uiOutput("otras"), value = tags$text(sum(26+2+19), style = "font-size: 75%"), subtitle = "Otras plataformas de podcasts",
                   icon = icon("headphones"), 
                   color = "purple"))),
        column(2, tags$p("Sitios propios"),
               fluidRow(
                 valueBox(
                   uiOutput("website"), value = tags$text(redes[12, 2], style = "font-size: 75%"),
                   subtitle = "Visitas/mes sitio web",
                   icon = icon("link"),
                   color = "aqua"),
                 valueBox(
                   uiOutput("boletin"), value = tags$text(redes[2, 2], style = "font-size: 75%"),
                   subtitle = "Suscripciones al boletin \n (open rate %)",
                   icon = icon("newspaper"),
                   color = "yellow"))),
        column(2, tags$p("Instagram"),
               fluidRow(
                 valueBox(
                   uiOutput("insta"), value = tags$text(redes[4, 2], style = "font-size: 75%"),
                   subtitle = "Seguidores",
                   icon = icon("instagram"),
                   color = "fuchsia"),
                 valueBox(
                   uiOutput("insta"), value = tags$text(redes[6, 2], style = "font-size: 75%"),
                   subtitle = "Alcance (mes anterior)",
                   icon = icon("instagram"),
                   color = "fuchsia"))),
        column(2, tags$p("Facebook"),
               fluidRow(
                 valueBox(
                   uiOutput("fb"), value = tags$text(redes[7, 2], style = "font-size: 75%"),
                   subtitle = "Seguidores",
                   icon = icon("facebook"),
                   color = "blue"),
                 valueBox(
                   uiOutput("fb"), value = tags$text(redes[9, 2], style = "font-size: 75%"),
                   subtitle = "Alcance (mes anterior)",
                   icon = icon("facebook"),
                   color = "blue"))),
        column(2, tags$p("Otras redes"),
               fluidRow(
                 valueBox(
                   uiOutput("tw"), value = tags$text(redes[10, 2], style = "font-size: 75%"),
                   subtitle = "Seguidores en Twitter",
                   icon = icon("twitter"),
                   color = "light-blue"),
                 valueBox(
                   uiOutput("li"), value = tags$text(redes[11, 2], style = "font-size: 75%"),
                   subtitle = "Seguidores en LinkedIn",
                   icon = icon("linkedin"),
                   color = "navy")))),
  
  fluidRow(
    tabBox(width = 12,
           tabPanel("Quienes nos escuchan",
                    fluidRow(
                      column(7,
                             fluidRow(
                               plotlyOutput("plot"),
                               plotlyOutput("descargas_mapa")
                             )),
                      column(4, offset = 1,
                             fluidRow(
                               plotlyOutput("edad"),
                               plotlyOutput("donut")
                             ))
                    )
           ),
           tabPanel("Descargas & Contenido",
                    fluidRow(
                      column(12,
                             fluidRow(
                               plotlyOutput("streamsts")
                             ))
                    )
           ))
    )
)



#TO DO> ADD HREF TO VALUEBOXES!!!


# Server component -------------------

server <- function(input, output){
  
  
  output$plot <- renderPlotly({
    streams_paises %>%
      filter(Total>20) %>%
      mutate(Pais = fct_reorder(Pais, Total)) %>%
      arrange(desc(Total)) %>%
      plot_ly(y = ~Pais, 
              x = ~Total, 
              color = ~Pais, 
              type = "bar", 
              colors = c("#f5dd3a","#6bcbe3"),
              showlegend = F,
              orientation = "h") %>%
      layout(font = list(color = "#858585"),
             title = list(text = "(Paises en donde nos han escuchado >20X)",
                          x = 0.2,
                          font = list(size = 14, color = "#858585")),
             xaxis = list(title = "No. Descargas",
                          gridcolor = "#353535"),
             yaxis = list(title = " "),
             paper_bgcolor = "#171717",
             plot_bgcolor = "#171717",
             margin = list(t= 50,r= 0,b= 10,l= 0))
    
  })

  
  output$descargas_mapa <- renderPlotly({
    #text on hover
    streams_paises$hover <- with(streams_paises, paste(Pais, '<br>',
                                                       "Spotify", Spotify, "<br>",
                                                       "Otras plataformas", Ivoox))
    # specify map projection/options
    g <- list(
      showframe = T,
      showland = T,
      landcolor = toRGB("grey70"),
      showocean = T,
      oceancolor = toRGB("LightBlue"),
      showlakes = T,
      lakecolor = toRGB("LightBlue"),
      showcoastlines = T,
      coastlinecolor = toRGB("#171717"),
      showcountries = T,
      countrycolor = toRGB("#171717"),
      countrywidth = 0.2,
      resolution = 20,
      fitbounds = "locations",
      center = list(lon = -55, lat = 14),
#     projection = list(type = 'natural earth')
      projection = list(type = 'orthographic')
#      projection = list(type = 'winkel tripel', scale=4)
    )
    
    map <- plot_geo(streams_paises,
                    type = "choropleth",
                    locations = streams_paises$code,
                    z = streams_paises$Total,
                    text = streams_paises$hover,
                    showscale = F,
                    colors = c("#f5dd3a","#6bcbe3"),
                    marker = list(line = list(color = toRGB("#986538"), width = 0.5)),
                    colorbar = list(xpad = 0,
                                    ypad = 0)) %>%
      layout(geo=g,
             margin = list(0,0,0,0),
             paper_bgcolor = "#171717",
             plot_bgcolor = "#171717",
             title = list(text = "Todos los paises en donde nos han escuchado:",
                          x = 0.2,
                          font = list(size = 14, color = "#959595")))
    map
  })
  
  output$edad <- renderPlotly({
    
    edad[-c(2)] %>%
      pivot_longer(!`Rango Edad`, names_to = "genero", values_to = "n") %>%
      mutate(Percentage = round((n/sum(n))*100)) %>%
      plot_ly(x = ~`Rango Edad`,
              y = ~Percentage,
            type = "bar",
            name = ~genero,
            color = ~genero,
            colors = c(Masculino = "#986538", Femenino = "#6bcbe3", `No binario` = "#f5dd3a", `No especifica` = "white")) %>%
      layout(barmode = "stack", bargap = 0.05,
             xaxis = list(title = "Edades"),
             yaxis = list(title = "%"),
             paper_bgcolor = "#171717",
             plot_bgcolor = "#171717",
             font = list(color = "#858585"),
             legend = list(x = 0.7, y = 1, bgcolor = 'rgba(255, 255, 255, 0)', bordercolor = 'rgba(255, 255, 255, 0)'),
             title = list(text = "Nos escuchan jovenes...?", 
                          font = list(size = 14, color = "#858585")))
    
  })
  
  output$donut <- renderPlotly({
    
    plot_ly(data = gen, 
            labels = ~`Género`,
            values = ~Porcentaje, 
        #    type = "pie",
            textposition = 'inside',
            textinfo = 'label+percent',
            insidetextfont = list(color = '#FFFFFF'),
            hoverinfo = 'label+percent',
            text = ~paste(Porcentaje, ' %'),
            marker = list(colors = c("#6bcbe3", "#986538", "white", "#f5dd3a")),
            showlegend = F,
        insidetextorientation = "radial") %>%
      add_pie(hole = 0.5) %>%
      
      layout(paper_bgcolor = "#171717",
           plot_bgcolor = "#171717")
  
  })
  
  output$streamsts <- renderPlotly({
    
    streams$hover <- with(streams, paste("Escuchas diarias en:", '<br>',
                                         "Spotify:", streamsSpot, "<br>",
                                         "Otras plataformas:", ivoox))

    weeklystrts <- weekly %>%
      group_by(weeks) %>%
      summarize(value = sum(desc))
  
    streams %>%
      mutate(StreamsTot = streamsSpot + ivoox,
             cums = cumsum(StreamsTot)) %>%
      plot_ly(x = ~date,
              y = ~StreamsTot,
              type = "scatter",
              mode = "lines",
              text = ~hover,
              name = "Descargas diarias",
              line = list(color = "#6bcbe3",
                          width = 2)) %>%
      add_trace(x = ~date,
                y = ~cums,
                type = "scatter",
                mode = "lines",
                name = "Descargas acumuladas",
                yaxis = "y2",
                line = list(color = "#f5dd3a",
                            width = 1,
                            dash = "dot")) %>%
      add_trace(data = weeklystrts,
                x = ~weeks,
                y = ~value,
                type = "scatter",
                mode = "lines",
                name = "Semanales",
                inherit = F,
                line = list(color = "#6bcbe3",
                            width = 1.5,
                            dash = "dot")) %>%
      layout(xaxis = list(title = "",
                          tickangle = 90),
             yaxis = list(tickfont = list(color = "#6bcbe3"),
                          title = list(text = "Descargas",
                                       standoff = 25)),
             yaxis2 = list(tickfont = list(color="#f5dd3a"),
                           overlaying = "y",
                           side = "right",
                           title = list(text = "Descargas acumuladas",
                                        standoff = 25))) %>%
      layout(xaxis = list(
        zerolinecolor = 'ffff',
        zerolinewidth = 2,
        gridcolor = '#353535'),
        yaxis = list(
          zerolinecolor = '#171717',
          zerolinewidth = 2,
          gridcolor = '#171717'),
        paper_bgcolor = "#171717",
        plot_bgcolor = "#171717",
        font = list(color = "#858585"),
        legend = list(x = 0.05, y = 0.95),
        title = list(text = "En promedio 70 descargas por semana por cada nuevo episodio", 
                     font = list(size = 14, color = "#858585")),
        margin = list(t= 50,r= 80,b= 20,l= 70))
  
  

  })
  
  
  output$treemap <- renderPlot({
    
    treestem <-  guests %>%
      group_by(stem, pregrado) %>%
      summarize(n = n(),
                prop = (n/66)*100)
    
    treemap(
      dtf = treestem,
      index = c("stem","pregrado"),
      vSize = "n",
      bg.labels = c("white"),
      align.labels=list(
        c("center", "center"), 
        c("right", "bottom")
      )  
    ) 
    
    plot_ly(
      data = treestem,
      type = "treemap",
      labels = ~pregrado,
      parents = ~stem,
      values = ~n)
    

    dt1 <- data.frame(
      topic = c("", "Eve", "Eve", "", "Seth", "Eve", "Eve", "", "Eve"),
      subtopic = c("Eve", "b", "c", "Seth", "sb", "x", "y", "Awan", "tr"),
      n = c(10, 14, 12, 10, 2, 6, 6, 1, 4)
    )
    
  
  })
  
  #    ggplot(aes(area = n, fill = stem, subgroup = stem, subgroup2 = pregrado, label = pregrado)) +
  #    geom_treemap(start = "topleft", layout = "srow") +
  #    geom_treemap_subgroup2_border(color = "#171717", size = 1, start = "topleft", layout = "srow") +
  #    geom_treemap_subgroup_border(color = "#171717", size = 2, start = "topleft", layout = "srow") +
  #    geom_treemap_subgroup_text(color = "#000000", alpha = 0.1, angle = 30, grow=T, place = "center", fontface="italic", start = "topleft", layout = "srow") +
  #    geom_treemap_subgroup2_text(color = "#000000", alpha = 0.7, size = 12, reflow=T, place = "center", fontface="bold", start = "topleft", layout = "srow") +
  #    scale_fill_manual(values = c("#f5dd3a", "#986538", "#f5dd3a", "#6bcbe3"))
  
  #  theme(legend.position = "none",
  #        plot.background = element_rect(fill = "#000000"))
  
  #ggplotly(treestem)
  
}


# Call shinyApp ----------------------

shinyApp(ui = ui, server = server)