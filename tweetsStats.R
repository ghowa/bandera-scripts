#Recreate the graphs and data tables references in the text
# By Rolf Fredheim (ref38@cam.ac.uk)
#________________________________________________________
#| Required packages:
#| library(animation)    #creating gifs
#| library(cldr)         #language detection
#| library(dismo)        #To access geo location API
#| library(ggmap)        #Map tools
#| library(ggplot2)      #graphs, visualisations
#| library(lubridate)    #date formatting
#| library(plyr)         #data reshaping
#| library(qdap)         #language tools
#| library(RColorBrewer) #colour selection for visualisations
#| library(RgoogleMaps)  #accessing google maps
#| library(sentiment)    #sentiment calculations
#| library(stringr)      #reshaping data
#| library(twitteR)      #accessing twitter API
#|_________________________________________________________

#Load functions, packages, and data
  source("rFunctions/twitterFunctions.R")
  loader("tweetStats")
  load("tweetData/processedData.Rdata")

#stats about the data:
  x <- (table(tt2$RT,tt2$detectedLanguage)); x[rowSums(x)>5,]#most retweeted by language
  x <- (table(tt2$to,tt2$detectedLanguage)); x[rowSums(x)>5,]#most retweeted by language
  
  x <- table(tolower(tt2$hash),tt2$detectedLanguage); x[rowSums(x)>5,]#inspect hashtags, divided by language

  table(duplicated(tt2$text))#n duplicate tweets
  sort(table(tt2$screenName)) #users who tweet about Bandera the most
  sort(table(tt2$screenName[duplicated(tt2$text)]))#users who have duplicate tweets. Possible fake accounts

  ggplot(tt2,aes(x=created,fill=detectedLanguage))+geom_bar()#time series of tweets
  ggplot(tt2[duplicated(tt2$text),],aes(x=created,fill=detectedLanguage))+geom_bar()#Time series of duplicate tweets
  
  print("Russian tweets outnumber Ukrainian ones at a ratio of: ")
  table(tt2$detectedLanguage)[2]/table(tt2$detectedLanguage)[3] #x as many Russian
  dupTemp <- tt2[duplicated(tt2$text),]
  print("Duplicates of Russian tweets outnumber duplicated Ukrainian ones at a ratio of: ")
  table(dupTemp$detectedLanguage)[1]/table(dupTemp$detectedLanguage)[2] #x as many duplicated tweets


#Geo visualisations:
  geo <- tweetMap(tt2)
  tt2 <- data.frame(geo[1])
  geo[2] #tweet map

  sort(table(tt2$country)) #tweets by country, table
  countTemp <- tt2[tt2$country=="Ukraine",] 
  sort(table(countTemp$detectedLanguage)) #Language distribution of tweets from Ukraine

  countTemp <- tt2[tt2$country=="Russia",]
  table(countTemp$detectedLanguage) #Language distribution of tweets from Russia
  

  #Summary stats by location
  tt2$count <- 1
  tt <- ddply(tt2,.(interpretedPlace,detectedLanguage,latitude,longitude),summarize, c=sum(count))
  tweetMap4(tt[tt$detectedLanguage=="RUSSIAN"|tt$detectedLanguage=="UKRAINIAN",])
  tweetMap4(tt[tt$detectedLanguage=="UKRAINIAN",])
  tweetMap4(tt[tt$detectedLanguage=="RUSSIAN",])

#Reshape data for aggregate stats
  tt <- ddply(tt,.(interpretedPlace,latitude,longitude),transform, c2=sum(c))
  tt <- tt[order(tt$c2,decreasing=T),]
  tt <- tt[4:nrow(tt),]
  tt$interpretedPlace <- as.character(tt$interpretedPlace)
  ggplot(head(tt,30),aes(x=reorder(interpretedPlace,c,decreasing=T),c,fill=detectedLanguage))+geom_bar(stat="identity")+coord_flip() #Graph of n tweets from different cities or regions

#Time series plots
  tt2$date <- floor_date(as.Date(tt2$created),"month")
  tt2$count <- 1
  countData <- ddply(tt2,.(date,detectedLanguage),summarize, n=sum(count))
  
  ggplot(countData, aes(date,n,colour=detectedLanguage))+geom_line()
  countData <- ddply(tt2,.(date,detectedLanguage,country),summarize, n=sum(count))
  countData <- countData[!is.na(countData$country),]
  ggplot(countData[countData$country=="Ukraine",], aes(date,n,colour=detectedLanguage))+geom_line()+geom_line(data=countData[countData$country=="Russia"&countData$detectedLanguage=="RUSSIAN",],colour="black")#black line shows Russian tweets from outside Ukraine. Interesting that only emerges in June 2011. Probably a change in Yandex scraper algorithm. 

