#process Youtube raw data
Sys.setlocale("LC_CTYPE","russian")

youTubeProcess <- function(output,input1,input2){
youtubeImport <- function(filename,type){
 # library(stringr)
  #library(lubridate)
 # y <- read.csv(filename,sep=";",header=F)
  #y <- unique(y)
 # y <- y[-1,]
#  y <- y[,c(1,3,4,2)]
#  y$V1 <- as.character(y$V1)
#  colnames(y) <- c("V1","V2","V3","V4")
#  #y$V1 <- str_sub(y$V1, 1, 11)
 # y$V3 <- as.Date(y$V3)
  #y2 <- names(table(y$V1))
 # output <- NULL
#  y$V4 <- gsub(" ","",y$V4)
  #y <- y[as.character(y$V4)==type,]
 # y$V4 <- NULL
#    for (j in y2){
    #y3 <- unique(y[y$V1==j,])
   # y3 <- y3[order(y3$V3),]
  #  print(j)
 #   for (i in 2:nrow(y3))
      #{
    ##  x <- y3[i,2]
   #   if (nrow(y3)==1){b=y3[1,3]
  #    } else if(y3[(i-1),3]==y3[i,3]-days(1)){
 #       b <- seq((y3[(i-1),3]),(y3[i,3]),by="day")
#      #} else if(y3[(i-1),3]<y3[i,3]-days(1)){
     #   b <- seq((y3[(i-1),3]),(y3[i,3])-days(1),by="day")
    #    } else b <- y3[i,3]
   #   c <- length(b)
  #    d <- x/c
 #     v <- data.frame(y3[i,1],b,d)
#      output <- rbind(output,v)
    #  }
  ##  }
 # output
}


#Loop to extract data for views, comments, favs, and dislikes
t=c("view","comments","favs","dislikes","likes")
for (i in t)
  {
  type=i
  
  #There are two pieces of data, one latin, one cyrillic
    outputLatin <- youtubeImport(input1,i)
    #outputCyrillic <- youtubeImport(input2,i)
  
  #Merge the two data sets
    output <- rbind(outputLatin)
    save(output,file=paste0("youTubeData/output",i))
    print (paste0("finished processing ",i,". saved to: ", paste0("youTubeData/output",i)))
}
}

analyseYoutube <- function(adjConst,adjCoef,title,type){
  load(paste0("youTubeData/output",type))
  colnames(output) <- c("file","date",type)
  library(ggplot2)
  #output2 <- output[output$date<as.Date("2013-03-01"),]

  #tabule the total number of views by video
  tempvar <- table(output$views,output$videoname)

  #sort it
  tempvar <- sort(tempvar,decreasing=T)
  
  #Select the x number you want (here 10):
  tempvarCut <- head(tempvar,10)

  #remove all videos from the original data.frame not matching the names you are left with: (this works by selecting rows where the condition is true, and all the columns) 

  output2 <- output[output$videoname %in% tempvarCut,]

  print(ggplot(output2,aes(x=date,y=get(type),colour=file))+geom_line()+ylab(paste0(type)))
  library(plyr)
  output3 <- ddply(output2,.(date),summarize, totViews=sum(get(type)))

  output3$n <- 1:nrow(output3)
  output2$n <- 1:nrow(output2)
  output2$adj <- output2[,3]/(adjConst+(adjCoef/12)*output2$n)
  output3$adj <- output3$totViews/(adjConst+(adjCoef/12)*output3$n)
	
  print(ggplot(output3,aes(x=date,y=(adj)))+geom_line()+
    ggtitle(paste0(title," - adjusted values")))
  print(ggplot(output3,aes(x=date,y=(totViews)))+geom_line()+
    ylab(paste0("total n ",type))+
    ggtitle(paste0(title," - raw values")))

  b <- ddply(output2,.(file),transform, top=max(adj))
  b <- b[order(b$adj,decreasing=T),]
  b <- b[!duplicated(b[,c(1,6)]),]
  b <- b[order(b$top,decreasing=T),]
 # print(head(b,10))
}
