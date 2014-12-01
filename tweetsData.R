#|  Written in Windows 7, 64 bit
#|  R version 2.15.2
#|  By Rolf Fredheim (ref38@cam.ac.uk)
#|_____________________________________________________________
#|  Required libraries:
#|  library(cldr)         #language detection
#|  library(dismo)        #To access geo location API
#|  library(lubridate)    #date formatting
#|  library(plyr)         #data reshaping
#|  library(rjson)        #for Twitter
#|  library(RJSONIO)      #for Twitter
#|  library(stringr)      #reshaping data
#|  library(twitteR)      #accessing twitter API
#|  library(XML)          #html parsing
#|  library(RCurl)        #fetching data from internet
#|_____________________________________________________________

#Set working directory to root folder:
setwd("yourRootHere")

#Load the required functions
source("rFunctions/twitterFunctions.R")

#Load the required packages. Will install any unavailable packages
loader("yandexData")

#To handle cyrillic characters
Sys.setlocale("LC_CTYPE","russian")


#REQUIRES TWITTER API
  #load stored authentication data
  #If you have not set up Twitter API access, follow the walkthrough here:
  #WALKTHROUGH
  load("c:/Users/Rolf/documents/cred.Rdata") #EDIT
  registerTwitterOAuth(Cred)
  download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")  


#Data processing, shaping OR load the data
  df <- importYandex("tweets/")
  load("tweetData/extractedTweets.Rdata")

tt2 <- yandexFormat(df)
  #Assumes yandex html files
  #takes a directory, converts all html pages in that directory into tweets in a data frame
  #DIR -> data.frame
  #Requires activated twitter API and cacert.pem loaded
