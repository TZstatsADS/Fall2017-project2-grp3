#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
data <- read.csv("clean_state_disaster.csv")

## Begin Def server
shinyServer(function(input, output, session) {
  
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
    df2 <- data %>%
      filter(Year == input$year) %>%
      select(State, Hurricane, Severe.Storm.s.,
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
      select(State, Earthquake, Fire,
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
    HTML("<br/><br/>Motion Chart is a dynamic interface to explore various aspects of data sets. <br/><br/> 
         To explore the relationship between different the occurrence natural disasters, click the drop-down menu on either axis
         to choose a different variable.
         <br/><br/>To explore how the number of a single disaster has changed throughout the years, click the taps on the 
         top right corner of the chart to switch to a different graph.
         <br/><br/> The number of disaster is calculate by aggregating the number of disaster declared by each county/area within a state. ")
  })
  
  output$view <- renderGvis({
    
    gvisMotionChart(data, xvar="Flood",yvar="Hurricane",idvar='State',timevar = 'Year', sizevar='Population',colorvar = 'Region', options=list(width="800", height="800"))
  })
  ## end MotionChart
  
})
## End Def server

shinyApp(ui = shinyUI, server= shinyServer)
