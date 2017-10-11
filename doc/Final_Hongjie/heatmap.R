

library(rgdal)
if (!require(geojsonio)) {
  install.packages("geojsonio")
  library(geojsonio)
}
#install.packages("spdplyr")
library(leaflet)
library(RColorBrewer)
library(spdplyr)


# From http://leafletjs.com/examples/choropleth/us-states.js

# set the working directory with "us-states.js" file
setwd("C:/Hongjie/5243 Applied Data Science/heatmap")

# draw basic map and the outline of states
states <- geojson_read("us-states.js",what = "sp")

plot(states)

# get 4 years disaster data
load("disaster_4y.RData")
our_data <- na.omit(disaster_4y)

# get injured & dead people numeber
people <- data.frame(STATE=our_data$STATE, INJUR_DEATH=our_data$INJUR_DEATH, YEAR=our_data$YEAR)

# calculate number of injured & dead people each state each year
aggdata <- aggregate(people$INJUR_DEATH, by=list(state=people$STATE, year=people$YEAR),FUN=sum)

# keep the data which have same state names as states
states_name <- toupper(states$name)
aggdata <- subset(aggdata, state %in% states_name)

# match the order of states
agg2014 <- aggdata[match(states_name,aggdata[aggdata$year==2014,]$state),]
agg2015 <- aggdata[match(states_name,aggdata[aggdata$year==2015,]$state),]
agg2016 <- aggdata[match(states_name,aggdata[aggdata$year==2016,]$state),]
agg2017 <- aggdata[match(states_name,aggdata[aggdata$year==2017,]$state),]

# attach the aggregate columns to jason data frame
states@data$agg2014 <- agg2014$x
states@data$agg2015 <- agg2015$x
states@data$agg2016 <- agg2016$x
states@data$agg2017 <- agg2017$x


# the sample part, draw heatmap, take 2014 as an example
bins <- c(0, 5, 10, 15, 20, 25, 30, 35, Inf)
pal <- colorBin("YlOrRd", domain = agg2014$x, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, agg2014$x
) %>% lapply(htmltools::HTML)

leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles("MapBox", options = providerTileOptions(
    id = "mapbox.light",
    accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
  addPolygons(
    fillColor = ~pal(agg2014),
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
  addLegend(pal = pal, values = ~agg2014, opacity = 0.7, title = NULL,
            position = "bottomright")
