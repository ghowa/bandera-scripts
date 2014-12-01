wikiSub <- function(filename){
  #Filename -> writes to file
  #takes a file of translated text and removes Wikipedia specific meta fields
  lines <- readLines(filename)
  lines2 <- gsub("- [():,[:alnum:] ].*)$","",lines)
  lines2 <- gsub(". [():,[:alnum:] ].*)$","",lines2)
  lines2 <- gsub("\\(Talk\\) [():,[:alnum:] ].*)","",lines2)
  lines2 <- gsub("\\[[Ee]dit\\]","",lines2)
  lines2 <- gsub("[[:digit:]]","",lines2)
  lines2 <- gsub("\\[\\]","",lines2)
  lines2 <- gsub("http[[:alnum:]:/.-].*","",lines2)
  writeLines(lines2,filename)
}
