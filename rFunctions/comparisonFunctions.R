calcNegative <- function(filename){
  text <- readLines(filename)
  prep <- function(some_txt){
  # remove punctuation
  some_txt = gsub("[[:punct:]]", " ", some_txt)
  some_txt = gsub("  ", " ", some_txt)
  some_txt = gsub("  ", " ", some_txt)
  some_txt = gsub("  ", " ", some_txt)
  
  # remove numbers
  some_txt = gsub("[[:digit:]]", "", some_txt)
  # remove html links
  some_txt = gsub("http\\w+", "", some_txt)
  # remove unnecessary spaces
  
  some_txt <- tolower(some_txt)
  
  }
  text <- prep(text)
  txt <- unlist(strsplit(text," "))
  x <- summary(txt %in% negative.words) #English: 5% of words in negative wordlist
return(x)
}



calcProb <- function(p,p2){
  n1=sum((as.numeric(p[2]))+(as.numeric(p[3])))
  n2=sum((as.numeric(p2[2]))+(as.numeric(p2[3])))
  prop1=as.numeric(p[3])/n1
  prop2=as.numeric(p2[3])/n2
  print(prop1*100)
  print(prop2*100)
  bpower(p1=prop1,p2=prop2,n1=n1,n2=n2) 
}



dictionaryWord <- function(filename){
  require(qdap)
  sentence <- readLines(filename)  
  dict <- unique(c(negative.words,positive.words,DICTIONARY$word,labMT$word))
  sentence <- readLines(filename)
  sentence = gsub('[[:punct:]]', '', sentence)
  sentence = gsub('[[:cntrl:]]', '', sentence)
  sentence = gsub('[[:digit:]]', '', sentence)  
  sentence = tolower(sentence)
  word.list = str_split(sentence, '\\s+')
  words = unlist(word.list)
  matches = pmatch(words, dict,duplicates.ok=T)
  list <- words[!is.na(matches)]

  print(paste0("is the word in the dictionary? Filename: ",filename))
  print(table(!is.na(matches)))
  writeLines(list,paste0(filename,"_filtered.txt"))
}

filterTexts <- function(){
  dictionaryWord("youtubeData/english.txt")
  dictionaryWord("youtubeData/polish_trans.txt")
  dictionaryWord("youtubeData/russian_trans.txt")
  dictionaryWord("youtubeData/ukrainian_trans.txt")

  dictionaryWord("wikiData/Bandera-disc-en.txt")
  dictionaryWord("wikiData/Bandera-disc-ru-trans.txt")
  dictionaryWord("wikiData/Bandera-disc-ukr-trans.txt")
  dictionaryWord("wikiData/Bandera-disc-pol-trans.txt")

  dictionaryWord("wikiData/Bandera-article-en.txt")
  dictionaryWord("wikiData/Bandera-article-ukr-trans.txt")
  dictionaryWord("wikiData/Bandera-article-pol-trans.txt")
  dictionaryWord("wikiData/Bandera-article-ru-trans.txt")

  dictionaryWord("tweetData/tweets_russian_trans.txt")
  dictionaryWord("tweetData/tweets_ukrainian_trans.txt")
}