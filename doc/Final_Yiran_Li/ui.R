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

shinyUI(
  navbarPage("The Natural Disaster Navigator",
             theme = shinythemes::shinytheme("cerulean"),  # <--- Specify theme here
             #tabPanel("Google Charts", "Motion Graph"),
             
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
             
             navbarMenu("Motion Graph",
                        tabPanel("Description", "Explore the Motion Chart",
                                 htmlOutput("motion_chart_descrp")),
                        tabPanel("Plot",            
                                 mainPanel(
                                  htmlOutput("view"))
             ))

  
))#END of shinyUI