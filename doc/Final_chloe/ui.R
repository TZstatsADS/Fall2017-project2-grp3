library(shiny)
library(plotly)
library(shinythemes)


## UI Function
ui<- navbarPage(
  theme = shinytheme("cosmo"),

  
  ##Project Title
  "Natural Disasters",
  ############# begin of Home Page ###########################
  tabPanel("Home",
          # sidebarLayout(
            #div(class="side", sidebarPanel(width=0)),
           mainPanel(width=12,
                     img(src="tornado.png", style="width:100%")
           )
          # )
           
  ),
  ############# end of Home Page ###########################
  
  
  
  
  ############# begin of Map Page ###########################
  tabPanel("Map Explorer"
  ),
  ############# begin of Map Page ###########################
  
  
  
  
  ############# begin of Summary Statistics tab ###############
  navbarMenu("Summary Statistics",
             
             ##Google Charts
             tabPanel("Google Charts"),
             
             
             ##GNC
             tabPanel("GNC"),
             
             
             ################# start of Tree Map
             tabPanel("Tree Map", 
                      titlePanel('Percent of Death in Each State'),
                      sidebarPanel(
                        selectInput("disaster", label = "Type of natural disaster:",
                                    choices = c("Earthquake","Fire", "Severe.Storm.s.","Flood","Hurricane",
                                                "Snow","Tornado"), selected = "Severe.Storm.s."),
                        
                        sliderInput("year", label = "Timeline:",
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
                                    choices = c("Dense Fog","Dust Storm", "Excessive Heat","Extreme Cold Wind Chill","Flash Flood","Flood","Freezing Fog"            
                                                ,"Frost Freeze", "Hail","Heat","Heavy Rain", "Heavy Snow","High Surf","High Wind","Ice Storm","Lake Effect Snow","Lightning"                
                                                ,"Marine High Wind","Marine Strong Wind","Marine Thunderstorm Wind","Rip Current", "Sneakerwave", "Strong Wind"
                                                ,"Thunderstorm Wind","Tornado","Tropical Storm","Wildfire","Winter Storm","Winter Weather","Hurricane","Marine Dense Fog",
                                                "Astronomical Low Tide", "Avalanche","Blizzard","Coastal Flood", "Cold Wind Chill","Debris Flow"), selected = "Excessive Heat")
                        
                      ),
                      mainPanel(
                        plotlyOutput("pie_plot",width = "100%", height = 600)
                      )
              )
              ################ end of pie chart 
                      

  )
############# end of Summary Statistics tab ###############
  
)
  
  
  
  