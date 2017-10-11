#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(rgdal)
if (!require(geojsonio)) {
  install.packages("geojsonio")
  library(geojsonio)
}



library(shiny)
library(leaflet)
library(RColorBrewer)

# Heat map part
setwd("C:/Hongjie/5243 Applied Data Science/heatmap")

links <- "https://raw.githubusercontent.com/TZstatsADS/Fall2017-project2-grp3/934a5c4495fcf5f99d27f86e47029bb400edd858/doc/us-states.js?token=Aad3biXhTy58FLj2qcLhSsWV0Fv8ofsBks5Z5WrpwA%3D%3D"

link <- "http://leafletjs.com/examples/choropleth/us-states.js"
states <- geojson_read(link)

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, states$density
) %>% lapply(htmltools::HTML)

leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles("MapBox", options = providerTileOptions(
    id = "mapbox.light",
    accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
  addPolygons(
    fillColor = ~pal(density),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto")) %>%
  addLegend(pal = pal, values = ~density, opacity = 0.7, title = NULL,
            position = "bottomright")



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  observe({
    
    m <- leaflet(states) %>%
      setView(-96, 37.8, 4) %>%
      addProviderTiles("MapBox", options = providerTileOptions(
        id = "mapbox.light",
        accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')))
    m %>% add_polygons()
    m %>% addPolygons(
      fillColor = ~pal(density),
      weight = 2,
      opacity = 1,
      color = "white",
      dashArray = "3",
      fillOpacity = 0.7,
      highlight = highlightOptions(
        weight = 5,
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE))
    
    output$map <- renderLeaflet({
      
      disasterby <- (input$disaster)
      monthby <- (input$month)
      
      # selectData <- outputdata(disaster,state,month)
      # selectData <- map_data[(map_data$EVENT_TYPE%in%'Flash Flood')&(map_data$STATE%in%'TEXAS')&(map_data$MONTH_NAME%in%'July'),]
      
      selectData <- map_data[(map_data$EVENT_TYPE%in%disasterby)
                             &(map_data$MONTH_NAME%in%monthby),]
      
      leaflet() %>%
        addTiles(
          urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
          attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
        ) %>% addCircles(selectData$BEGIN_LON,selectData$BEGIN_LAT)%>%
        setView(lng = -93.85, lat = 37.45, zoom = 5)
     })
  })
 })
