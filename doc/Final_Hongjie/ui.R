#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(navbarPage("Heat map of affected people",
               tabPanel("State Map",
                div(class="outer",
                tags$head(# Include our custom CSS
                            includeCSS("styles.css"),
                            includeScript("gomap.js")
                          ),
        leafletOutput("map", width="100%", height="100%"),
# Shiny versions prior to 0.11 should use class="modal" instead.
  absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                width = 330, height = "auto",
             h2("People affected by disaster on different month "),
             h4("Please select:  "),
           selectInput("disaster", h3("Disaster"),choices = unique(map_data$EVENT_TYPE),selected ="Flash Flood", multiple = T),
           selectInput("month", h3("Month"),choices = unique(map_data$MONTH_NAME),selected ="July", multiple = T),
  # selectInput("", "Size", vars, selected = "adultpop"),
           conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
  # Only prompt for threshold when coloring or sizing by superzip
           numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
                          ),
                    br(),
           DT::dataTableOutput("reco")
        # plotOutput("histCentile", height = 200),
        # plotOutput("scatterCollegeIncome", height = 250)
                    )
                  )
               )
        )
  )