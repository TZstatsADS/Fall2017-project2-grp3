#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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
library(leaflet)
library(dplyr)
library(plyr)
library(plotly)
require(RColorBrewer)

data <- read.csv("clean_state_disaster.csv")

# Use global max/min for axes so the view window stays
# constant as the user moves between years
xlim <- list(
  min = -20,
  max = max(data$Hurricane) + 10
)

ylim <- list(
  min = -20,
  max = max(data$Severe.Storm.s.) + 10
)

xlim2 <- list(
  min = -5,
  max = max(data$Earthquake) + 5
)

ylim2 <- list(
  min = -10,
  max = max(data$Fire) + 5
)

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
months_choices=c('All',months_level[order(factor(months_level,levels=month.name))])

year_level=unique(map_data$YEAR)
year_choices=c('All', year_level[order(year_level)])
###############data part end###################


shinyUI(
  navbarPage(
            ##Project Title
            "The Natural Disaster Navigator",
             theme = shinythemes::shinytheme("cosmo"),  # <--- Specify theme here
             # #tabPanel("Google Charts", "Motion Graph"),

             #"Natural Disasters",
             ############# begin of Home Page ###########################
             tabPanel("Home",
                    
                      # mainPanel(width=12,
                      #           img(src="tornado.png", style="width:100%")
                      # ),
                      
                      mainPanel(width=12,
                                img(src="tornado.png", height = 400, width = 860, style="display: block; margin-left: auto; margin-right: auto;")
                      ),
                      
                      h1("The Natural Disaster Navigator", align = "center"),
                      h4(htmlOutput("teammates"), align = "center")
                      # )
                      
             ),
   ############# end of Home Page ###########################
   
   
   ############# Begin of Map Page ###########################
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
                              h4("Please select:"),
                              selectInput("disaster", h3("Disaster"),choices = disaster_choices,selected ="Flash Flood", multiple = T),
                              selectInput("state", h3("State/Location"),choices = states_choices,selected ="TEXAS", multiple = T),
                              selectInput("month", h3("Month"),choices = months_choices,selected ="July", multiple = T),
                              br()
                )
                
                
            )
            
   ),
   ############# END of Map Explorer ###########################
   
   ############Heat Map by Hongyang and Hongjie############
   tabPanel("Heat Map: Injuries and Deaths",
            
            div(class="outer",
                
                tags$head(
                  # Include our custom CSS
                  includeCSS("styles.css"),
                  includeScript("gomap.js")
                ),
                
                leafletOutput("heatmap", width="100%", height="100%"),
                absolutePanel(id="controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                              width = 200, height = "auto",
                              
                              h2("Injuries and Deaths each year"),
                              h4("Please select:"),
                              selectInput("year1", h3("Year"),choices = year_choices,selected ="All", multiple = T),
                              br()
                  )
                
            )
            
            
   ),
   ############Heat Map end############
             
             navbarMenu("Google Charts",
                        tabPanel("Hurricane v. Severe Storms", googleChartsInit(),
                                 
                                 # Use the Google webfont "Source Sans Pro"
                                 tags$link(
                                   href=paste0("http://fonts.googleapis.com/css?",
                                               "family=Source+Sans+Pro:300,600,300italic"),
                                   rel="stylesheet", type="text/css"),
                                 tags$style(type="text/css",
                                            "body {font-family: 'Source Sans Pro'}"
                                 ),
                                 
                                 h2("Natural Disasters by State and Year"),
                                 
                                 ### BEGIN Google Chart 1
                                 googleBubbleChart("chart",
                                                   width="100%", height = "475px",
                                                   # Set the default options for this chart; they can be
                                                   # overridden in server.R on a per-update basis. See
                                                   # https://developers.google.com/chart/interactive/docs/gallery/bubblechart
                                                   # for option documentation.
                                                   options = list(
                                                     fontName = "Source Sans Pro",
                                                     fontSize = 17,
                                                     # Set axis labels and ranges
                                                     hAxis = list(
                                                       title = "Number of Hurricanes",
                                                       viewWindow = xlim
                                                     ),
                                                     vAxis = list(
                                                       title = "Number of Severe Storms",
                                                       viewWindow = ylim
                                                     ),
                                                     # The default padding is a little too spaced out
                                                     chartArea = list(
                                                       top = 50, left = 75,
                                                       height = "75%", width = "75%"
                                                     ),
                                                     # Allow pan/zoom
                                                     explorer = list(),
                                                     # Set bubble visual props
                                                     bubble = list(
                                                       opacity = 0.4, stroke = "none",
                                                       # Hide bubble label
                                                       textStyle = list(
                                                         color = "none"
                                                       )
                                                     ),
                                                     # Set fonts
                                                     titleTextStyle = list(
                                                       fontSize = 20
                                                     ),
                                                     tooltip = list(
                                                       textStyle = list(
                                                         fontSize = 16
                                                       )
                                                     )
                                                   )
                                 ),
                                 
                                 fluidRow(
                                   shiny::column(10, offset = 4,
                                                 sliderInput("year", "Year",
                                                             min = min(data$Year), max = max(data$Year),
                                                             value = min(data$Year), step = 1, animate = FALSE)
                                   )
                                 ) 
                                 ### END Google Chart 1),
                                 
                        
             ), 
             tabPanel("Earth Quakes v. Fires",   
                      ### BEGIN Google Chart 2
                      # This line loads the Google Charts JS library
                      #googleChartsInit(),

                      # Use the Google webfont "Source Sans Pro"
                      tags$link(
                        href=paste0("http://fonts.googleapis.com/css?",
                                    "family=Source+Sans+Pro:300,600,300italic"),
                        rel="stylesheet", type="text/css"),
                      tags$style(type="text/css",
                                 "body {font-family: 'Source Sans Pro'}"
                      ),

                      h2("Natural Disasters by State and Year"),

                      googleBubbleChart("chart2",
                                        width="100%", height = "475px",
                                        # Set the default options for this chart; they can be
                                        # overridden in server.R on a per-update basis. See
                                        # https://developers.google.com/chart/interactive/docs/gallery/bubblechart
                                        # for option documentation.
                                        options = list(
                                          fontName = "Source Sans Pro",
                                          fontSize = 17,
                                          # Set axis labels and ranges
                                          hAxis = list(
                                            title = "Number of Earthquake",
                                            viewWindow = xlim2
                                          ),
                                          vAxis = list(
                                            title = "Number of Fire",
                                            viewWindow = ylim2
                                          ),
                                          # The default padding is a little too spaced out
                                          chartArea = list(
                                            top = 50, left = 75,
                                            height = "75%", width = "75%"
                                          ),
                                          # Allow pan/zoom
                                          explorer = list(),
                                          # Set bubble visual props
                                          bubble = list(
                                            opacity = 0.4, stroke = "none",
                                            # Hide bubble label
                                            textStyle = list(
                                              color = "none"
                                            )
                                          ),
                                          # Set fonts
                                          titleTextStyle = list(
                                            fontSize = 20
                                          ),
                                          tooltip = list(
                                            textStyle = list(
                                              fontSize = 16
                                            )
                                          )
                                        )
                      ),

                      fluidRow(
                        shiny::column(10, offset = 4,
                                      sliderInput("year2", "Year",
                                                  min = min(data$Year), max = max(data$Year),
                                                  value = min(data$Year), step = 1, animate = FALSE)
                        )
                      ) 
                      ### END Google Chart 2
                      
                      
             ) ),
             
   ######## Begin Motion Graph #############
             navbarMenu("Motion Graph",
                        tabPanel("Description", 
                                 h3("Explore the Motion Chart"),
                                 h4("Motion Chart is a dynamic interface to explore various aspects of data sets. "),
                                 htmlOutput("motion_chart_descrp")),
                        tabPanel("Plot",            
                                 mainPanel(
                                  htmlOutput("view"))
             )),
  ########## End Motion Graph ##############
  
  ############# begin of Summary Statistics tab ###############
  navbarMenu("Summary Statistics",
             
             ################# start of Tree Map
             tabPanel("Tree Map", 
                      titlePanel('Percent of Death in Each State'),
                      sidebarPanel(
                        selectInput("disaster99", label = "Type of natural disaster:",
                                    choices = c("Earthquake","Fire", "Severe.Storm.s.","Flood","Hurricane",
                                                "Snow","Tornado"), selected = "Severe.Storm.s."),
                        
                        sliderInput("year99", label = "Timeline:",
                                    min = 2010, max = 2016, value = 2011, step = 1)
                        
                      ),
                      mainPanel(
                        plotOutput("tree_map",width = "100%", height = 600)
                      )
             ),
             ################ end of Tree Map  
             
             
             
             ################# start of pie chart 
             tabPanel("Pie Chart", 
                      titlePanel("Percent of Death in Each Age Group"),
                      sidebarPanel(
                        selectInput("disaster2", label = "Type of natural disaster:",
                                    choices = c("Flash_Flood","Flood","Heavy_Rain","Lightning","Marine_Strong_Wind",
                                                "Thunderstorm_Wind","Tornado"), selected = "Flood")
                        
                      ),
                      mainPanel(
                        plotlyOutput("pie_plot",width = "100%", height = 600)
                      )
             )
             ################ end of pie chart 
             
             
  )
  ############# end of Summary Statistics tab ###############
  
))#END of shinyUI
