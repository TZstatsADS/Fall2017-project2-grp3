library(shiny)
library(data.table)
library(plyr)
library(reshape)
library(plotly)
library(treemap)

##data for treemap 
data.tree <-read.csv("data.tree.csv",header=TRUE)

##data for pie chart 
data_event<-read.csv("data_event.csv",header=TRUE)
colnames(data_event)<-c("num","agegroup", "Astronomical Low Tide", "Avalanche","Blizzard","Coastal Flood", "Cold Wind Chill","Debris Flow"             
                        ,"Dense Fog", "Dust Devil","Dust Storm", "Excessive Heat","Extreme Cold Wind Chill","Flash Flood","Flood","Freezing Fog"            
                        ,"Frost Freeze", "Hail","Heat","Heavy Rain", "Heavy Snow","High Surf","High Wind","Ice Storm","Lake Effect Snow","Lightning"                
                        ,"Marine High Wind","Marine Strong Wind","Marine Thunderstorm Wind","Rip Current", "Sneakerwave", "Strong Wind"
                        ,"Thunderstorm Wind","Tornado","Tropical Storm","Wildfire","Winter Storm","Winter Weather","Hurricane","Marine Dense Fog")       


shinyServer(function(input, output) {
  ############ begin of treemap ##############
  output$tree_map=renderPlot({
    
    data_year<-data.tree[data.tree$Year==input$year,]
    data_year[nrow(data_year)+1,4:10]<-colSums(data_year[,4:10])
    for(i in 4:10){
      data_year[,i]<-data_year[,i]/data_year[nrow(data_year),i]
    }
    data_year<-data_year[1:nrow(data_year)-1,]
    
    data_year$label<-paste(data_year$State,", ",round(100*data_year[,as.character(input$disaster)],3),"%",sep="")
    treemap(data_year, index='label', vSize=input$disaster, vColor="State", type="categorical", palette="RdYlBu",
            aspRatio=30/30,drop.unused.levels = FALSE, position.legend="none")
  
  })
  ############ end of treemap ##############
  
  ############ begin of pie plot ################
  output$pie_plot=renderPlotly(
    {
      data_disaster<- data_event[,c("agegroup", input$disaster2)]
      
      colors <- c('rgb(211,94,96)', 'rgb(128,133,133)', 'rgb(144,103,167)', 'rgb(171,104,87)', 'rgb(114,147,203)')
      
      plot_ly(data_disaster, labels = ~agegroup, values = ~data_disaster[,input$disaster2], type = 'pie',
              textposition = 'inside',
              textinfo = 'label+percent',
              insidetextfont = list(color = '#FFFFFF'),
              hoverinfo = 'text',
              text = ~paste('Number of Deaths:', data_disaster[,input$disaster2]),
              marker = list(colors = colors,
              line = list(color = '#FFFFFF', width = 1)),
              showlegend = FALSE) #%>%
        #layout(title = as.character(input$disaster2))
      
    })
  ############ end of pie plot ################
  
})

