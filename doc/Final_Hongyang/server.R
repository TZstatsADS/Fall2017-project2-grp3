library(shiny)
library(ggplot2)
library(plotly)
library(plyr)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(DT)
library(dplyr)
library(ggmap)
library(data.table)
library(rvest)
library(stringr)
library(tidyr)



####################data preprocessing######################
load("disaster_4y.RData")
#delete all rows without location value 
map_data=na.omit(disaster_4y)

disaster_level=unique(map_data$EVENT_TYPE)
states_level = unique(map_data$STATE)
months_level = unique(map_data$MONTH_NAME)

#generate 16 colors for different types of disasters
disaster_colors=c(brewer.pal(8, "Set1"),brewer.pal(8, "Set2"))
#add a new column to map data
map_data$colors=NULL
#match 16 colors to disasters
for (i in 1:length(disaster_colors)){
  map_data[map_data$EVENT_TYPE==disaster_level[i],'colors']=disaster_colors[i]
}

#############data navigator function#############
outputdata <- function(disaster='Flash Flood',state='TEXAS',month='July'){
 #prevent null condition
   if (is.null(disaster)){disaster='Flash Flood'}
  if (is.null(state)){state='TEXAS'}
  
  if(disaster=='All'){
    disaster_index=(map_data$EVENT_TYPE%in%disaster_level)
  }else{
    disaster_index=(map_data$EVENT_TYPE%in%disaster)
  }
  
  if(state=='All'){
    state_index=(map_data$STATE%in%states_level)
  }else{
    state_index=(map_data$STATE%in%state)
    
  }
    month_index=(map_data$MONTH_NAME%in%month)

  selectData <- map_data[disaster_index & state_index & month_index,]
  return(selectData)
}

###############data part end###################


shinyServer(function(input, output) {
  
  
  ############Interactive Map by Hongyang############
  observe({
    output$map <- renderLeaflet({
      
      disasterby <- (input$disaster)
      stateby <-(input$state)
      monthby <- (input$month)
      
      
      selectData <- outputdata(disasterby,stateby,monthby)
      leaflet() %>%
        addTiles(
          urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
          attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
        ) %>% addCircles(selectData$BEGIN_LON,selectData$BEGIN_LAT,fillColor = (selectData$colors),color = (selectData$colors))%>%
        addLegend("topleft", colors= disaster_colors, labels=disaster_level)%>%
        setView(lng = -93.85, lat = 37.45, zoom = 5)
       
  
    })
  })
  ############map end############
  
  
  
  
  
})
  






#deployApp(appName = "myapp")
