#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
library(leaflet)
library(dplyr)
library(plyr)

# ## Beginning of function converting state abbreviations into full names
# abb2state <- function(name, convert = F, strict = F){
#   data(state)
#   # state data doesn't include DC
#   state = list()
#   state[['name']] = c(state.name,"District Of Columbia", "Virgin Islands", "Puerto Rico")
#   state[['abb']] = c(state.abb,"DC", "VI", "PR")
#   
#   if(convert) state[c(1,2)] = state[c(2,1)]
#   
#   single.a2s <- function(s){
#     if(strict){
#       is.in = tolower(state[['abb']]) %in% tolower(s)
#       ifelse(any(is.in), state[['name']][is.in], NA)
#     }else{
#       # To check if input is in state full name or abb
#       is.in = rapply(state, function(x) tolower(x) %in% tolower(s), how="list")
#       state[['name']][is.in[[ifelse(any(is.in[['name']]), 'name', 'abb')]]]
#     }
#   }
#   sapply(name, single.a2s)
# }
# 
# ## End of function converting state abbreviations into full names
# 
# state_disaster <- read.csv("us_disaster_by state.csv")
# state_pop <- read.csv("us_pop_by_state.csv")
# state_pop$State <- gsub(".", '', state_pop$State, fixed = T)
# colnames(state_pop)[2:ncol(state_pop)] <- gsub("X", '', colnames(state_pop)[2:ncol(state_pop)], fixed = T)
# state_disaster$State <- as.vector(unlist(as.character(abb2state(state_disaster$State)))) #Converting to full state names
# summary(state_disaster)
# head(state_disaster[state_disaster$Declaration_Year==2010,])
# dup_rows <- duplicated(state_disaster[, c("Declaration_Year", "State", "Title")])#**
# head(state_disaster[!dup_rows, 1:ncol(state_disaster)]) #**
# head(state_disaster[!dup_rows,1])
# sum(!dup_rows)
# length(state_disaster[!dup_rows,1])
# tail(state_disaster[!dup_rows,]) #**
# #split(unlist(state_disaster$Incident_Type), as.factor(unlist(state_disaster$State)))
# unique(state_disaster$Incident_Type)
# table(unlist(state_disaster$State))
# # 
# # split(state_disaster$Declaration_Year, as.factor(unlist(state_disaster$State)))
# # split(unlist(state_disaster$State), as.factor(state_disaster$Declaration_Year))[1]
# # 
# # state_disaster%>% 
# #   group_by(Declaration_Year)
# hist(table(unlist(state_disaster$State)))
# 
# 
####
# unique_state_disaster <- state_disaster[!dup_rows,]
# clean_state_disaster <- data.frame()
# state_regions <- data.frame(State = state.name, Region = state.region)
# for( i in 2010:2016){
#   df <- state_disaster[as.numeric(unique_state_disaster$Declaration_Year)==i, ]
#   year_i_table <- table(as.factor(unlist(df$State)), as.factor(unlist(df$Incident_Type)))
#   year_i_df <- as.data.frame.matrix(year_i_table)
#   year_i_df$Year <- rep(i, nrow(year_i_df))
#   year_i_df$State <- rownames(year_i_df)
#   state_i_pop_df <- state_pop[, c(1, which(colnames(state_pop) == i))]
#   merged_state_df <- merge(state_i_pop_df,year_i_df)
#   colnames(merged_state_df)[2] <- "Population"
#   merged_state_df_final <- merge(merged_state_df, state_regions)
#   clean_state_disaster <- rbind(clean_state_disaster, merged_state_df_final)
# 
# }
# 
# write.csv(clean_state_disaster, "clean_state_disaster.csv")

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
  
  yearData <- reactive({
    # Filter to the desired year, and put the columns
    # in the order that Google's Bubble Chart expects
    # them (name, x, y, color, size). Also sort by region
    # so that Google Charts orders and colors the regions
    # consistently.
    df <- data %>%
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
  
  ## MotionChart
  output$view <- renderGvis({
    
    gvisMotionChart(data, xvar="Hurricane",yvar="Terrorist",idvar='State',timevar = 'Year', sizevar='Population',colorvar = 'Region', options=list(width="800", height="800"))
  })
  ## end MotionChart
  
})
## End Def server

shinyApp(ui = shinyUI, server= shinyServer)
#runApp()
