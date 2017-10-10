library(leaflet)
library(shiny)
require(RColorBrewer)

####################data preprocessing######################
load("disaster_4y.RData")
#delete all rows without location value 
map_data=na.omit(disaster_4y)
disaster_level=unique(map_data$EVENT_TYPE)
disaster_choices=disaster_level[order(disaster_level)]
disaster_choices=c('All',as.character(disaster_choices))


states_level = unique(map_data$STATE)
states_choices=states_level[order(states_level)]
states_choices=c('All',as.character(states_choices))


months_level = unique(map_data$MONTH_NAME)
months_choices=months_level[order(factor(months_level,levels=month.name))]

###############data part end###################



########### shiny app user interface##############
shinyUI(navbarPage("Nature Disaster Navigator  ",
                   
                   ############Interactive Map by Hongyang############
                   tabPanel("Map Explorer",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")
                                ),
                                
                                leafletOutput("map", width="100%", height="100%"),
                                
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 200, height = "auto",
                                              
                                              h2("Filter disaster by state and month "),
                                              h4("Please select:  "),
                                              selectInput("disaster", h3("Disaster"),choices = disaster_choices,selected ="Flash Flood", multiple = T),
                                              selectInput("state", h3("State/Location"),choices = states_choices,selected ="TEXAS", multiple = T),
                                              selectInput("month", h3("Month"),choices = months_choices,selected ="July", multiple = T),
                                              br()
                                )
                                
                                
                            )
                   )
                   ############map end############
                   
)
)