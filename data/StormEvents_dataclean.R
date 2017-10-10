
########data Preprocessing by Hongyang Yang#############

stormevent_2017=read.csv('StormEvents_details-ftp_v1.0_d2017_c20170918.csv')
stormevent_2016=read.csv('StormEvents_details-ftp_v1.0_d2016_c20170918.csv')
stormevent_2015=read.csv('StormEvents_details-ftp_v1.0_d2015_c20170918.csv')
stormevent_2014=read.csv('StormEvents_details-ftp_v1.0_d2014_c20170718.csv')


colnames(stormevent_2016)



getDisasterData=function(storemevent){
  disasters=storemevent[,c('BEGIN_YEARMONTH','BEGIN_DAY','BEGIN_TIME',
                                   'EPISODE_ID','EVENT_ID','STATE','YEAR','MONTH_NAME','EVENT_TYPE',
                                    'INJURIES_DIRECT','INJURIES_INDIRECT',
                                   'DEATHS_DIRECT','DEATHS_INDIRECT',
                                   'BEGIN_LAT','BEGIN_LON')]
  disasters$INJURIES=disasters[,'INJURIES_DIRECT']+disasters[,'INJURIES_INDIRECT']
  disasters$DEATHS=disasters[,'DEATHS_DIRECT']+disasters[,'DEATHS_INDIRECT']
  disasters$INJUR_DEATH=disasters[,'INJURIES']+disasters[,'DEATHS']
  
  
  disasters$INJURIES_DIRECT=NULL
  disasters$INJURIES_INDIRECT=NULL
  disasters$DEATHS_DIRECT=NULL
  disasters$DEATHS_INDIRECT=NULL
  return(disasters)
  
}

disaster_2017=getDisasterData(stormevent_2017)
disaster_2016=getDisasterData(stormevent_2016)
disaster_2015=getDisasterData(stormevent_2015)
disaster_2014=getDisasterData(stormevent_2014)
  
disaster_4y=rbind(disaster_2017,disaster_2016,disaster_2015,disaster_2014)


save(disaster_4y, file = "disaster_4y.RData")
# Save multiple objects
# To load the data again


#######################explore dataset#########################################
which.max(disaster_4y$DEATHS)
disaster_4y[which.max(disaster_4y$DEATHS),]

unique(disaster_4y$EVENT_TYPE)
table(disaster_4y$EVENT_TYPE)
aggregate(disaster_4y$INJUR_DEATH, by=list(disaster_4y$EVENT_TYPE), 
          FUN=sum, na.rm=TRUE)
aggregate(disaster_4y$INJUR_DEATH, by=list(disaster_4y$STATE), 
          FUN=sum, na.rm=TRUE)



aggregate(disaster_2016$DEATHS, by=list(disaster_2016$MONTH_NAME), 
          FUN=sum, na.rm=TRUE)

(disaster_2016[disaster_2016$MONTH_NAME=='July','EVENT_TYPE'])


aggregate(disaster_2016$DEATHS[disaster_2016$MONTH_NAME=='July'], by=list(disaster_2016$EVENT_TYPE[disaster_2016$MONTH_NAME=='July']), 
          FUN=sum, na.rm=TRUE)


table(disaster_2016$STATE[disaster_2016$EVENT_TYPE=='Excessive Heat'])
(disaster_2016$BEGIN_LAT[disaster_2016$EVENT_TYPE=='Flash Flood'])
table(disaster_2016$STATE[disaster_2016$EVENT_TYPE=='Flash Flood'])


table(disaster_2016$MONTH_NAME[disaster_2016$STATE=='SOUTH DAKOTA'])

texas_flash_flood=disaster_2016[disaster_2016$STATE=='TEXAS'&disaster_2016$EVENT_TYPE=='Flash Flood',]
table(texas_flash_flood$MONTH_NAME)

###############Diaster_4y####################

#disaster_2017
#disaster_2016
#disaster_2015
#disaster_2014

INJUR_DEATH_17=aggregate(disaster_2017$INJUR_DEATH, by=list(disaster_2017$MONTH_NAME), 
          FUN=sum, na.rm=TRUE)
INJUR_DEATH_16=aggregate(disaster_2016$INJUR_DEATH, by=list(disaster_2016$MONTH_NAME), 
          FUN=sum, na.rm=TRUE)
INJUR_DEATH_15=aggregate(disaster_2015$INJUR_DEATH, by=list(disaster_2015$MONTH_NAME), 
          FUN=sum, na.rm=TRUE)
INJUR_DEATH_14=aggregate(disaster_2014$INJUR_DEATH, by=list(disaster_2014$MONTH_NAME), 
          FUN=sum, na.rm=TRUE)

INJUR_DEATH_t=cbind(INJUR_DEATH_16,INJUR_DEATH_15$x,INJUR_DEATH_14$x)



