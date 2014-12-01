#The functions below will allow the master doc to function. 

getPckg <- function(pckg) install.packages(pckg, repos = "http://cran.r-project.org")

pckg  <-  try(require(twitteR));if(!pckg) {install.packages(pckg)}


loader <- function(dataset){
if (dataset=="tweetsData"){
  pckg1  <-  try(require(cldr));if(!pckg7) {install.packages(pckg)}
  pckg2  <-  try(require(dismo));if(!pckg8) {install.packages(pckg)}
  pckg3  <-  try(require(lubridate));if(!pckg3) {install.packages(pckg)}
  pckg4  <-  try(require(rjson));if(!pckg4) {install.packages(pckg)}
  pckg5  <-  try(require(RJSONIO));if(!pckg5) {install.packages(pckg)}
  pckg6  <-  try(require(stringr));if(!pckg6) {install.packages(pckg)}
  pckg7  <-  try(require(twitteR));if(!pckg7) {install.packages(pckg)}
  pckg8  <-  try(require(XML));if(!pckg8) {install.packages(pckg)}
  pckg9  <-  try(require(RCurl));if(!pckg9) {install.packages(pckg)}
  }
if (dataset=="tweetStats"){
  pckga  <-  try(require(animation));if(!pckga) {install.packages(pckg)}
  pckgb  <-  try(require(cldr));if(!pckgb) {install.packages(pckg)}
  pckgc  <-  try(require(dismo));if(!pckgc) {install.packages(pckg)}
  pckgd  <-  try(require(ggmap));if(!pckgd) {install.packages(pckg)}
  pckge  <-  try(require(ggplot2));if(!pckge) {install.packages(pckg)}
  pckg  <-  try(require(lubridate));if(!pckg) {install.packages(pckg)}
  pckg  <-  try(require(plyr));if(!pckg) {install.packages(pckg)}
  pckg  <-  try(require(qdap));if(!pckg) {install.packages(pckg)}
  pckg  <-  try(require(RColorBrewer));if(!pckg) {install.packages(pckg)}
  pckg  <-  try(require(RgoogleMaps));if(!pckg) {install.packages(pckg)}
  pckg  <-  try(require(sentiment));if(!pckg) {install.packages(pckg)}
  pckg  <-  try(require(stringr));if(!pckg) {install.packages(pckg)}
  pckg  <-  try(require(twitteR));if(!pckg) {install.packages(pckg)}
  }
}

#twitter functions
#loads in html files. 
importYandex <- function(dirName){
  #Enter folder name with trailing forward slash
  files <- dir(dirName)
  user <- NULL
  date <- NULL
  text <- NULL
  df <- data.frame(user,date,text)
  for (i in files){
    print(i)
    url <- paste0(dirName,i)
    doc <- htmlParse(url)
    l <- xpathSApply(doc, "//*/div[@class='message']", xmlValue)
    for (j in 1:length(l)){
      results <- xpathSApply(doc, "//*/div[@class='message']", xmlValue)[j]
      user <- xpathSApply(doc, "//*/a[@class='b-hlist__name']", xmlValue)[j]
      date <- xpathSApply(doc, "//*/a[@class='b-hlist__date']", xmlValue)[j]
      text <- xpathSApply(doc, "//*/a[@class='b-twitter-link i-bem SearchStatistics-twitter-item b-twitter-link_js_inited']", xmlValue)[j*2]
   #   text <- text[seq(1,length(text),2)][j]
      tryCatch(p <- data.frame(user,date,text),error = function(e) NULL)
      df <- rbind(df,p)}
  }
  save(df,file="tweetData/extractedTweets.Rdata")
  return(df)
}

#reshapes the data
yandexFormat <- function(df){
  
  library(XML)
  library(cldr)
 # df <- importYandex(dirName)
  print ("data imported")

  date <- as.Date("2013-03-18")
  df <- tweetDates(df,date)  
  print ("dates standardized")
  
  df <- tweetsLang(df)
  print("languages detection done")
  
  eval(parse("rFunctions/cyrillicDates.R",encoding="UTF-8"))
  df <- df[df$detectedLanguage=="RUSSIAN"|df$detectedLanguage=="POLISH"|df$detectedLanguage=="UKRAINIAN",]#remove other and undetected languages
  df <- unique(df)
  print("duplicates removed")
  print("passed data processing and date steps\n")

  tt2 <- df
  rm(df)
  print("removing references to Andrey Bandera, Antonio Banderas, etc./")
  eval(parse("rFunctions/filterSpuriousReferences.R",encoding="UTF-8"))
  
  #look up geo location
  tt2 <- geoLocationAddOn(tt2)
  #geo location detected

  
  print("extracting direct message and retweet details")
  tt2 <- tweetReshape(tt2)
  
  print("extracting hash tags")
  tt2$hash <- NA
  tt2$hash <- str_match(tt2$text,"#\\w+")
  
  print("URL decoding is slow, and likely unnecessary. Please confirm by pressing 'Y' that you wish to proceeed. Any other input will result in the step being skipped")
  n <- readline("Are you sure you want to decode URLs?: ")
  if (n=="Y"|n=="y"){
    print ("decoding URLs")
    tt2 <- tweetUrl(tt2)
    p <- data.frame(sort(table(tt2$url)))
    p <- rownames(p)
    pp <- decode_short_url(p)
    t <- unlist(pp)
    t <- (cbind(p,t))
    colnames(t) <- c("url","urlDecoded")
    tt2 <- merge(tt2,t,all=T,by="url")
  }
  if (!n=="Y"|n=="y"){print ("URL decoding skipped")}

  tt2$location <- gsub("crimean","crimea",tt2$location,ignore.case=T)
  print("starting country identification")
  print("this process may be slow")
  library(ggmap)
  detach("package:ggmap", unload = T)
  locations <- geocode(tt2$location,oneRecord=T,progress="text") # Use amazing API to guess
  locations$screenName <- tt2$screenName
  # approximate lat/lon from textual location data.
  tt2 <- cbind(tt2,locations)
  tt2 <- data.frame(tt2)
  tt2$screenName.1 <- NULL
  tt2 <- tweetCountry(tt2)
  print("country data added")
  
  
  print("extracting tweets by language")
  #creates three separate files, one for each of the languages investigated:
  tt2$text <- gsub("\n"," ",tt2$text)
  tt2 <- tt2[order(tt2$detectedLanguage),]
  writeLines(tt2$text[tt2$detectedLanguage=="POLISH"],"tweetData/plLines.txt")
  print("Polish tweets saved to plLines.txt")
  writeLines(tt2$text[tt2$detectedLanguage=="RUSSIAN"],"tweetData/ruLines.txt")
  print("Russian tweets saved to ruLines.txt")
  writeLines(tt2$text[tt2$detectedLanguage=="UKRAINIAN"],"tweetData/ukLines.txt")
  print("Ukrainian tweets saved to ukLines.txt")
  
  print("processing complete!")
  n <- readline("Do you wish to save the data (Will overwrite previous data file). Press Y to proceed")
  if (n=="Y"|n=="y") {save(tt2, file ="tweetData/processedData.Rdata")
             print("data saved to processedData.Rdata")
        } #Overwrites downloaded file. 
  print("done")
  print("data may be inspected in data.frame 'tt2'")
  tt2
}

#Looks up geo location details. Requires Twitter API
geoLocationAddOn <- function(df){
  print ("Geo location search started")
  #returns formatted table
  library(twitteR)
  #t <- unique(df$user[! df$user %in% tt2$screenName])
  t2  <- unique(df$user)
  
  #we access the API in small batches
  print("please ensure you are connected to the internet")
  readline("Press return key to proceed")
  s <- seq(1,length(t2),25)

  userInfo <- NULL
  for( i in s){
      print(paste0("currently at entry ",i," of ",max(s),". ",max(s)-i," remaining. Hang in there!"))
      x <- lookupUsers(t2[i:(i+25)],cainfo="cacert.pem")
      x <- twListToDF(x)
      userInfo <- rbind(userInfo,x)
  }
    userFrame <- userInfo 
    
  userFrame <- unique(userFrame)
  
    userFrame2 <- userFrame[,c(3,11,12)]
  tt2 <- df
  colnames(tt2)[1:2] <- c("screenName","created")
  tt2 <- merge(tt2,userFrame2,by="screenName",all.x=T)
  tt2 <- tt2[!duplicated(tt2[,c(1,3,5,6)]),]
  save(tt2,file="tweetData/dataAfterGeoLookup")
  print ("data backed up to '../tweetData/dataAfterGeoLookup'")
  print ("geolocation data loaded")
  tt2
}

#Modifies dates, reformats to standardised date stamps
tweetDates <- function(df,date){
  #standardize dates
  #because most of these strings include cyrillics, the code is hidden from r in cyrillicDates.R
  eval(parse("rFunctions/cyrillicDates.R",encoding="UTF-8")) #Because of shitty encoding issues. ARGH. 
  df$date <- gsub(",.*","",df$date)
  df$date <- as.Date(df$date,"%d-%m-%Y")
  #df$date[nchar(df$date)<11] <- numeric(as.Date(df$date[nchar(df$date)<11],"%Y-%m-%d"))
  df <- rbind(dd,df)
}

#language detection
tweetsLang <- function(df){
  df$detectedLanguage <- detectLanguage(df$text,pickSummaryLanguage=T)[,1]
  df
}

#Extract retweet and @ information
tweetReshape <- function(tt2){
  #extract Retweet info
  tt2$RT <- 0
  library(stringr)
  tt2$RT[grep("RT",tt2$text)] <- str_match(tt2$text[grep("RT",tt2$text)],"RT @[[:alnum:]_.]*")
  tt2$RT <- gsub("RT @","",tt2$RT)
  tt2$text <- gsub("RT @[[:alnum:]_.]*","",tt2$text)
  
  #extract to info
  tt2$to <- 0
  tt2$to[grep("@",tt2$text)] <- str_match(tt2$text[grep("@",tt2$text)],"@[[:alnum:]_.]*")
  tt2$text <- gsub("@[[:alnum:]_.]*","",tt2$text)
  tt2$to <- gsub("@","",tt2$to)

  tt2

}

#word cloud [unused]
tweetCloud <- function(tt4){
  library(qdap)
  word.freq <- with(tt4, wfdf(english, detectedLanguage))[, -2] #leave out polish
  csums <- colSums(word.freq[, -1])
  conv.fact <- csums[2]/csums[1]
  word.freq$RUSSIAN <- word.freq[, "RUSSIAN"] * conv.fact
  #colSums(word.freq[, -1])
  word.freq[, "total"] <- rowSums(word.freq[, -1])
  word.freq$continum <- with(word.freq, RUSSIAN-UKRAINIAN)
  word.freq <- word.freq[word.freq$total != 0,] #remove Polish only words
  MAX <- max(word.freq$continum[!is.infinite(word.freq$continum)])
  word.freq$continum <- ifelse(is.infinite(word.freq$continum), MAX, word.freq$continum)
  conv.fact2 <- abs(range(word.freq$continum ))
  conv.fact2 <- max(conv.fact2)/min(conv.fact2)
  word.freq$continum <- ifelse(word.freq$continum > 0, word.freq$continum * conv.fact2, word.freq$continum)
  cuts <- c(-250, -25, -15, -10, -5, -2.5, -1.5, -1, -.5, -.25)
  cuts <- sort(c(cuts, 0, abs(cuts)))
  word.freq$fill.var <- cut(word.freq$continum, breaks=cuts )
  head(word.freq, 10)
  
  colfunc <- colorRampPalette(c("red", "blue"))
  word.freq$colors <- lookup(word.freq$fill.var, levels(word.freq$fill.var),
      rev(colfunc(length(levels(word.freq$fill.var)))))
  
  library(wordcloud)
  library(plotrix)
  par(mar=c(7,1,1,1))
  wordcloud(word.freq$Words, word.freq$total, colors = word.freq$colors,
      min.freq = 1, ordered.colors = TRUE, random.order = FALSE, rot.per=0,
      scale = c(5, .7))
  # Add legend
  COLS <- colfunc(length(levels(word.freq$fill.var)))
  color.legend(.025, .025, .25, .04, qcv(Russian,Ukrainian), COLS)
}

#basic tweet stats
tweetStats <- function(tt4){
                            # qprep for quick cleaning
# Split each sentece into it's own line
dat4 <- sentSplit(tt4, "english") 
z <- with(dat4, word_stats(english, grouping.var=detectedLanguage))
z$ts
z$gts
plot(z, low="white", high="black")
plot(z, label=TRUE, low="white", high="black", lab.digits=1)
}

#Extract hyperlinks from the body
tweetUrl <- function(tt2){
  tt2$url <- NA
  urls <- c("http","is.gd","t.co","bit.ly","tiny.","goo.gl","j.mp","vk.cc","youtu.be","twitpic","4sq","ht.ly","j.mp")
  for (i in urls ){
    print(i)
    for (j in 1:nrow(tt2)){
    if(is.na(tt2$url[j])){
      tt2$url[j] <- str_match(tt2$text[j],paste0(i,"[[:alnum:][:punct:]]*"))
      tt2$text[j] <- gsub(paste0(i,"[[:alnum:][:punct:]]*"),"",tt2$text[j])
    }
    }
  }
  return(tt2)
}

#crude sentimtent function
sentiment <- function(some_txt){
  library(twitteR)
library(sentiment)
library(plyr)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
  # remove retweet entities
some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", some_txt)
# remove at people
some_txt = gsub("@\\w+", "", some_txt)
# remove punctuation
some_txt = gsub("[[:punct:]]", "", some_txt)
# remove numbers
some_txt = gsub("[[:digit:]]", "", some_txt)
# remove html links
some_txt = gsub("http\\w+", "", some_txt)
# remove unnecessary spaces
some_txt = gsub("[ \t]{2,}", "", some_txt)
some_txt = gsub("^\\s+|\\s+$", "", some_txt)

# define "tolower error handling" function 
try.error = function(x)
{
   # create missing value
   y = NA
   # tryCatch error
   try_error = tryCatch(tolower(x), error=function(e) e)
   # if not an error
   if (!inherits(try_error, "error"))
   y = tolower(x)
   # result
   return(y)
}
# lower case using try.error with sapply 
some_txt = sapply(some_txt, try.error)

# remove NAs in some_txt
some_txt = some_txt[!is.na(some_txt)]
names(some_txt) = NULL

# classify emotion
class_emo = classify_emotion(some_txt, algorithm="bayes", prior=1.0)
# get emotion best fit
emotion = class_emo[,7]
# substitute NA's by "unknown"
emotion[is.na(emotion)] = "unknown"

# classify polarity
class_pol = classify_polarity(some_txt, algorithm="bayes")
# get polarity best fit
polarity = class_pol[,4]

# data frame with results
sent_df = data.frame(text=some_txt, emotion=emotion,
polarity=polarity, stringsAsFactors=FALSE)

# sort data frame
sent_df = within(sent_df,
  emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))

# plot distribution of polarity
p1 <- ggplot(sent_df, aes(x=polarity)) +
geom_bar(aes(y=..count.., fill=polarity)) +
scale_fill_brewer(palette="RdGy") +
labs(x="polarity categories", y="number of tweets")

# separating text by emotion
emos = levels(factor(sent_df$emotion))
nemo = length(emos)
emo.docs = rep("", nemo)
for (i in 1:nemo)
{
   tmp = some_txt[emotion == emos[i]]
   emo.docs[i] = paste(tmp, collapse=" ")
}

# remove stopwords
emo.docs = removeWords(emo.docs, stopwords("english"))
# create corpus
corpus = Corpus(VectorSource(emo.docs))
tdm = TermDocumentMatrix(corpus)
tdm = as.matrix(tdm)
colnames(tdm) = emos

# comparison word cloud
p2 <- comparison.cloud(tdm, colors = brewer.pal(nemo, "Dark2"), scale = c(3,.5), random.order = FALSE, title.size = 1.5)
# plot distribution of emotions
p3 <- ggplot(sent_df, aes(x=emotion)) +
geom_bar(aes(y=..count.., fill=emotion)) +
scale_fill_brewer(palette="Dark2") +
labs(x="emotion categories", y="number of tweets")
return(list(p1,p2,p3))
}

#four functions for mapping the tweets
tweetMap <- function(tt2){
  #locations <- geocode(tt2$location,oneRecord=T,progress="text") # Use amazing API to guess
  #locations$screenName <- tt2$screenName
  # approximate lat/lon from textual location data.
  #with(locations, plot(longitude, latitude))
  worldMap <- map_data("world") 
  #tt2 <- cbind(tt2,locations)
  #tt2 <- data.frame(tt2)
  zp1 <- ggplot(worldMap)
  tt3 <- tt2
  zp1 <- zp1 + geom_path(aes(x = long, y = lat, group = group),  # Draw map
                         colour = gray(2/3), lwd = 1/3)
  zp1 <- zp1 + geom_point(data = tt3,  # Add points indicating users
                          aes(x = longitude, y = latitude,size=log(followersCount)),
                          colour = "RED", alpha = .1)
  zp1 <- zp1 + coord_equal()  # Better projections are left for a future post
  zp1 <- zp1 + theme_minimal()  # Drop background annotations
  return(list(tt3,zp1))
}
tweetMap2 <- function(tt2){
  worldMap <- map_data("world") 
  tt3 <- data.frame(tt2)
  zp1 <- ggplot(worldMap)
  zp1 <- zp1 + geom_path(aes(x = long, y = lat, group = group),  # Draw map
                         colour = gray(2/3), lwd = 1/3)
  zp1 <- zp1 + geom_point(data = tt3,  # Add points indicating users
                          aes(x = longitude, y = latitude,size=log(followersCount)),
                          colour = "RED", alpha = .1)
  zp1 <- zp1 + coord_equal()  # Better projections are left for a future post
  zp1 <- zp1 + theme_minimal()  # Drop background annotations
  return(zp1)
}
tweetMap3 <- function(tt2){
  worldMap <- map_data("world") 
  worldMap <- worldMap[worldMap$long>0,]
  worldMap <- worldMap[worldMap$long<100,]
  worldMap <- worldMap[worldMap$lat>30,]
  worldMap <- worldMap[worldMap$lat<70,]
  tt3 <- data.frame(tt2)
  zp1 <- ggplot(worldMap)
  zp1 <- zp1 + geom_path(aes(x = long, y = lat, group = group),  # Draw map
                         colour = gray(2/3), lwd = 1/3)
  zp1 <- zp1 + geom_point(data = tt3,  # Add points indicating users
                          aes(x = longitude, y = latitude,colour=detectedLanguage),
                           size=5,alpha = .15)
  zp1 <- zp1 + coord_equal()  # Better projections are left for a future post
  zp1 <- zp1 + theme_minimal()  # Drop background annotations
  zp1 <- zp1+ylim(30,70)+xlim(0,50)
  return(zp1)
}
tweetMap4 <- function(tt2){
  worldMap <- map_data("world") 
  worldMap <- worldMap[worldMap$long>0,]
  worldMap <- worldMap[worldMap$long<100,]
  worldMap <- worldMap[worldMap$lat>30,]
  worldMap <- worldMap[worldMap$lat<70,]
  tt3 <- data.frame(tt2)
  zp1 <- ggplot(worldMap)
  zp1 <- zp1 + geom_path(aes(x = long, y = lat, group = group),  # Draw map
                         colour = gray(2/3), lwd = 1/3)
  zp1 <- zp1 + geom_point(data = tt3,  # Add points indicating users
                          aes(x = longitude, y = latitude,size=log(c),colour=detectedLanguage),
                           alpha = .5)
  zp1 <- zp1 + coord_equal()  # Better projections are left for a future post
  zp1 <- zp1 + theme_minimal()  # Drop background annotations
  zp1 <- zp1+ylim(30,70)+xlim(0,50)+ scale_size(range = c(4, 15))
  return(zp1)
}

#Country detection. Uses Google API. No registration required
tweetCountry <- function(tt2) {
  tt2$country <- NULL
  tt2$country <- gsub(".*,","",tt2$interpretedPlace)
  tt2$country <- gsub("143000","Russia",tt2$country)
  tt2$country <- gsub(" ","",tt2$country)
  tt2$country <- gsub("RussianFederation","Russia",tt2$country)
  tt2
}

#Extracts the full url from bit.ly links etc
decode_short_url <- function(url, ...) {
  # PACKAGES #
  require(RCurl)

  # LOCAL FUNCTIONS #
  decode <- function(u) {
    Sys.sleep(0.5)
    x <- try( getURL(u, header = TRUE, nobody = TRUE, followlocation = FALSE, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")) )
    if(inherits(x, 'try-error') | length(grep(".*Location: (\\S+).*", x))<1) {
      return(u)
    } else {
      return(gsub('.*Location: (\\S+).*', '\\1', x))
    }
  }

  # MAIN #
  gc()
  # return decoded URLs
  urls <- c(url, ...)
  l <- vector(mode = "list", length = length(urls))
  l <- lapply(urls, decode)
  names(l) <- urls
  return(l)
}


tweetGifs <- function(tt2){
#[data frame]-> GIF
#create a gif of tweets
#requires: Tweets formatted with a date stamp, geo location (latitude longitude)
#Uses the animation package for visualisation
#Uses ggmap to retrieve map object from google
#Uses RgoogleMaps to centre the map
#Assumes we are interested only in Polish, Russian and Ukrainian language tweets

  library(RgoogleMaps)
  library(animation)
  library(ggmap)
  ani.options(convert = shQuote('C:/program Files/ImageMagick-6.8.3-Q16/convert.exe'))
  ani.height=400
  
    tt2$count <- 1
    tt2$month <- floor_date(tt2$created, "month")
    tt <- ddply(tt2[tt2$yandex==0,],.(month,interpretedPlace,detectedLanguage,latitude,longitude),summarize, c=sum(count))
    lat <- c(40,70)
    lon <- c(10,65)
    center = c(lat=mean(lat), lon=mean(lon))
    zoom <- min(MaxZoom(range(lat), range(lon)))
   p <-    get_map(location=c(lon=mean(lon), lat=mean(lat)),zoom=zoom,maptype="terrain",color="bw")
    tt <- tt[!tt$interpretedPlace=="Poland",]
    tt <- tt[!tt$interpretedPlace=="Russia",]
    tt <- tt[!tt$interpretedPlace=="Ukraine",]
  
  saveGIF({
      n <- length(rownames(data.frame(table(tt$month))))
      # Begin the loop that creates the 150 individual graphs
      for (i in 1:n) {
          t <- tt[tt$month==rownames(data.frame(table(tt$month)[i])),]
          t <- t[!is.na(t$month),]
          print(ggmap(p)+ geom_point(data=t, aes(x=longitude, y=latitude, colour=detectedLanguage,size=c),alpha=.5)+
                  ylim(42,61)+xlim(10,50)+ 
                  scale_size(range = c(4, 15),limits=c(1,20))+
                  scale_colour_manual(values = c("RUSSIAN" = "red","UKRAINIAN" = "blue","POLISH" = "green"))+
                  ggtitle(min(t$month)))
      }
  }, interval = 0.5, nmax = 30, ani.width = 800, ani.height = 600)

}

