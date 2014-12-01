  #remove references to Andrey Bandrea
  tt2 <- tt2[grep("альбом|песн|клип|андрей|плэйкаст|бесплатн|mp3|рингтон|banderas|а.бандера",tt2$text,invert=T,ignore.case=T),]
  #get rid of unrelated tweets again after filtration
  tt2 <- tt2[grep("[Bb]ander|[Бб]андер",tt2$text),]#keep only tweets mentioning bandera in text
  