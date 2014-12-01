youtubeCommentsScrape <- function(input1,input2){
  #outputs three files, one for each language
  
  #Load required libraries
    require(cldr)
    require(stringr)
  
  #Set system locale
    Sys.setlocale("LC_CTYPE","russian")
  
  #Read cyrillic files
    cyrillic <- readLines(input1,encoding ="UTF-8")
    lang <- detectLanguage(cyrillic,pickSummaryLanguage=T)
  
    p <- cyrillic[lang$detectedLanguage=="ENGLISH"|lang$detectedLanguage=="RUSSIAN"|lang$detectedLanguage=="UKRAINIAN"|lang$detectedLanguage=="POLISH"]
    lang <- lang[lang$detectedLanguage=="ENGLISH"|lang$detectedLanguage=="RUSSIAN"|lang$detectedLanguage=="UKRAINIAN"|lang$detectedLanguage=="POLISH",]
  
  #Repeat for latin files
    latin <- readLines(input2,encoding ="UTF-8")  
    lang2 <- detectLanguage(latin,pickSummaryLanguage=T)  
  
    p2 <- latin[lang2$detectedLanguage=="ENGLISH"|lang2$detectedLanguage=="RUSSIAN"|lang2$detectedLanguage=="UKRAINIAN"|lang2$detectedLanguage=="POLISH"]
    lang2 <- lang2[lang2$detectedLanguage=="ENGLISH"|lang2$detectedLanguage=="RUSSIAN"|lang2$detectedLanguage=="UKRAINIAN"|lang2$detectedLanguage=="POLISH",]
  
  #Merge two sets of data
    combined <- c(p,p2)
    langcom <- rbind(lang,lang2)

    #we remove duplicates - some videos are duplicated, and some comments might be pasted in many tmies
      combined <- gsub("\uFEFF","",combined)
      combined <- gsub("&#39;","'",combined)
  
  #Print output files where each language is grouped
    c <- unique(combined[langcom$detectedLanguage=="ENGLISH"])
    writeLines(c,"youtubeData/english.txt")
    print("English YouTube comments extracted to: youtubeData/english.txt")
    c <- unique(combined[langcom$detectedLanguage=="RUSSIAN"])
    writeLines(c,"youtubeData/russian.txt")
    print("Russian YouTube comments extracted to: youtubeData/russian.txt")
    c <- unique(combined[langcom$detectedLanguage=="POLISH"])
    writeLines(c,"youtubeData/polish.txt")
    print("Polish YouTube comments extracted to: youtubeData/polish.txt")
    c <- unique(combined[langcom$detectedLanguage=="UKRAINIAN"])
    writeLines(c,"youtubeData/ukraine.txt")
    print("Ukrainian YouTube comments extracted to: youtubeData/ukrainian.txt")
}
