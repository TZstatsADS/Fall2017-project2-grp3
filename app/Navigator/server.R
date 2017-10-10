#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(leaflet)
if (!require(devtools))
  install.packages("devtools")
devtools::install_github("jcheng5/googleCharts")
library(googleCharts)
library(googleVis)
library(shiny)
library(dplyr)
library(plyr)
library(data.table)
library(reshape)
library(plotly)
library(treemap)
library(ggplot2)
library(plotly)
library(RColorBrewer)
library(scales)
library(lattice)
library(DT)
library(ggmap)
library(data.table)
library(rvest)
library(stringr)
library(tidyr)
library(geojsonio)

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
#######################

states <- geojson_read("us-states.js", what = "sp")
data_set=aggregate(disaster_4y$INJUR_DEATH, by=list(disaster_4y$STATE), 
                   FUN=sum, na.rm=TRUE)

states$INJUR_DEATH=0


for (i in 1:dim(states)[1]){
  for (j in 1:dim(data_set)[1]){
    if (toupper(as.character(states$name[i]))==as.character(data_set$Group.1[j])){
      states$INJUR_DEATH[i]=data_set$x[j]
    }
    
  }
}
bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = states$INJUR_DEATH, bins = bins)



###############data part end###################

#
data <- read.csv("clean_state_disaster.csv")
##data for treemap 
data.tree <-read.csv("data.tree.csv",header=TRUE)

##data for pie chart 
data_event<-read.csv("data_event.csv",header=TRUE)
colnames(data_event)<-c("num","agegroup","Flash_Flood","Flood","Heavy_Rain","Lightning","Marine_Strong_Wind",
                        "Thunderstorm_Wind","Tornado")



## Begin Def server
shinyServer(function(input, output, session) {
  
  ##Introduction

  output$teammates = renderUI({
    HTML("<b>Group 3: Yiran Li, Hongyang Yang, Hongjie Ren, Siyi Wang, Yina Wei </b>
         <br/><br/> A RShiny App that processes and visualizes natural disaster data, allowing users from high-risk area 
        residents to government officials to explore and extract meaningful insights from disaster data sets in order to minimize costs and optimize resource allocation in the face of natural disasters.<br/>
         <br/>")
  })
  ##END Introduction
  
  ############Interactive Map by Hongyang############
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
  ############Interactive Map end############
  
  
  ############Heat Map by Hongyang and Hongjie############
  
  output$heatmap <- renderLeaflet({
    
    labels <- sprintf(
      "<strong>%s</strong><br/>%g people",
      states$name, states$INJUR_DEATH
    ) %>% lapply(htmltools::HTML)
    
    leaflet(states) %>%
      setView(-96, 37.8, 5) %>%
      addProviderTiles("MapBox", options = providerTileOptions(
        id = "mapbox.light",
        accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
      addPolygons(
        fillColor = ~pal(INJUR_DEATH),
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
      addLegend(pal = pal, values = ~INJUR_DEATH, opacity = 0.7,
                position = "bottomright", title = "Total by state from 2014 to 2017")
    
      #showNotification("Total number of people died of or injured due to natural disasters in each state from 2014 to 2017.",
                     #type = "message")
      
    
  })
  ############Heat Map end############
  
  # Provide explicit colors for the 52 US states and territories, so they don't get recoded when the
  # different series happen to be ordered differently from year to year.
  # http://andrewgelman.com/2014/09/11/mysterious-shiny-things/
  defaultColors <- c("#3366cc", "#dc3912", "#ff9900", "#109618", "#990099", "#0099c6", "#dd4477")
  series <- structure(
    lapply(defaultColors, function(color) { list(color=color) }),
    names = levels(data$Region)
  )
  
  ### BEGIN Output chart 1  
  yearData <- reactive({
    # Filter to the desired year, and put the columns
    # in the order that Google's Bubble Chart expects
    # them (name, x, y, color, size). Also sort by region
    # so that Google Charts orders and colors the regions
    # consistently.
    df <- data %>%
      filter(Year == input$year) %>%
      dplyr::select(State, Hurricane, Severe.Storm.s.,
             Region, Population) %>%
      arrange(Region)
  })
  
  output$chart <- reactive({
    # Return the data and options
    list(
      data = googleDataTable(yearData()),
      options = list(
        title = sprintf(
          "Hurricane v. Severe_Storms",
          input$year),
        series = series
      )
    )
  })
  ### END Output chart 1
  
  ### BEGIN Output chart 2
  yearData2 <- reactive({
    # Filter to the desired year, and put the columns
    # in the order that Google's Bubble Chart expects
    # them (name, x, y, color, size). Also sort by region
    # so that Google Charts orders and colors the regions
    # consistently.
    df <- data %>%
      filter(Year == input$year2) %>%
      dplyr::select(State, Earthquake, Fire,
             Region, Population) %>%
      arrange(Region)
  })

  output$chart2 <- reactive({
    # Return the data and options
    list(
      data = googleDataTable(yearData2()),
      options = list(
        title = sprintf(
          "Earthquake v. Fire",
          input$year2),
        series = series
      )
    )
  })
  ### END Output chart 2

  ## MotionChart
  output$motion_chart_descrp = renderUI({
    HTML("<br/> The number of disaster is calculate by aggregating the number of disaster declared by each county/area within a state. <br/><br/>
         To explore the relationship between different the occurrence natural disasters, click the drop-down menu on either axis
         to choose a different variable.
         <br/><br/>To explore how the number of a single disaster has changed throughout the years, click the taps on the 
         top right corner of the chart to switch to a different graph.
         ")
  })
  
  output$view <- renderGvis({
    
    gvisMotionChart(data, xvar="Flood",yvar="Hurricane",idvar='State',timevar = 'Year', sizevar='Population',colorvar = 'Region', options=list(width="800", height="800"))
  })
  ## end MotionChart
  
  ############ begin of treemap ##############
  output$tree_map=renderPlot({
    
    data_year<-data.tree[data.tree$Year==input$year99,]
    data_year[nrow(data_year)+1,4:10]<-colSums(data_year[,4:10])
    for(i in 4:10){
      data_year[,i]<-data_year[,i]/data_year[nrow(data_year),i]
    }
    data_year1<-data_year[1:nrow(data_year)-1,]
    
    data_year1$label<-paste(data_year1$State,", ",round(100*data_year1[,as.character(input$disaster99)],3),"%",sep="")
    
  
    if(sum(is.na(data_year1[,as.character(input$disaster99)])) != 0){
      showNotification("No body died of this hazard in this year. Hooray! Please choose a different year.",
                       type = "error")
    }else{
      treemap(data_year1, index='label', vSize=input$disaster99, vColor="State", type="categorical", palette="RdYlBu",
              aspRatio=30/30,drop.unused.levels = FALSE, position.legend="none")
    }
  })
  ############ end of treemap ##############
  
  ############ begin of pie plot ################
  output$pie_plot=renderPlotly(
    {
      data_disaster1<- data_event[,c("agegroup", input$disaster2)]
      
      colors1 <- c('rgb(211,94,96)', 'rgb(128,133,133)', 'rgb(144,103,167)', 'rgb(171,104,87)', 'rgb(114,147,203)')
      plot_ly(data_disaster1, labels = ~agegroup, values = ~data_disaster1[, input$disaster2], type = 'pie',
              textposition = 'inside',
              textinfo = 'label+percent',
              insidetextfont = list(color = '#FFFFFF'),
              hoverinfo = 'text',
              text = ~paste('Number of Deaths:', data_disaster1[,input$disaster2]),
              marker = list(colors = colors1,
                            line = list(color = '#FFFFFF', width = 1)),
              showlegend = FALSE) 
      
    })
  ############ end of pie plot ################
  
})
## End Def server

shinyApp(ui = shinyUI, server= shinyServer)
