#Optionally process the YouTube viewing statistics:
  source("rFunctions/youTubeProcessData.R")

  #assign filenames
  output <- "youTubeData/youtubeJozin"
  input1 <- "youTubeData/jozin.txt"
  input2 <- "youTubeData/improved_stats_100_lat.txt"
  
  #This may be very slow if there is a lot of data to process
  #youTubeProcess(output,input1,input2)

  
#Optionally process the YouTube comments
  #This will save four files, one for each language
    #load the function
     # source("rFunctions/youtubeCommentsScrape.R")
  
    #Specify file names
     # input1 <- "youTubeData/jozin.txt"
     # input2 <- "youTubeData/comments_only_100_lat.txt"
    
    #Run the script:
      #youtubeCommentsScrape(input1,input2)
  
  #To reproduce our findings the files will need to be translated using google translate. We reccommend using the google translators toolkit application. This step may be skipped, and out files used instead. These are: english.txt, polish_trans.txt, russian_trans.txt, ukrainian_trans.txt

  
#YouTube statistics, graphs etc:  
  #(the strange double codes are because of ggplot's environment preferences. I'm too tired to come up with a workaround!)
    type <- "view";analyseYoutube(27,7,title="Jožin z Bažin",type="view")
    type <- "comments";analyseYoutube(27,7,title="Jožin z Bažin",type="comments")
    type <- "likes";analyseYoutube(27,7,title="Jožin z Bažin",type="likes")
    type <- "dislikes";analyseYoutube(27,7,title="Jožin z Bažin",type="dislikes")
    type <- "favs";analyseYoutube(27,7,title="Jožin z Bažin",type="favs")

#adjConst   #allow an adjustment for changing internet usage patterns. 
#adjCoef -> #these are the rates of internet use. They may be collected from the world bank. 
            #we used the gradient to estimate a growth coefficient from the value in 2008
            #this assumes linear growth. 

