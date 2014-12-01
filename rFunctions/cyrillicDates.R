
df$date <- as.character(df$date)
df$date <- gsub(" марта ","-03-",df$date)
df$date <- gsub(" января ","-01-",df$date)
df$date <- gsub(" апреля ","-04-",df$date)
df$date <- gsub(" мая ","-05-",df$date)
df$date <- gsub(" июня ","-06-",df$date)
df$date <- gsub(" июля ","-07-",df$date)
df$date <- gsub(" августа ","-08-",df$date)
df$date <- gsub(" сентября ","-09-",df$date)
df$date <- gsub(" октября ","-10-",df$date)
df$date <- gsub(" ноября ","-11-",df$date)
df$date <- gsub(" декабря ","-12-",df$date)
library(lubridate)
dd <- df[grep("ч",df$date),]
dd$date[grep("вчера",dd$date)] <- as.character(as.Date(date-days(1)))
dd$date[grep("ч",dd$date)] <- as.character(date)
dd$date <- as.Date(dd$date)
  
df<- df[grep("ч",df$date,invert=T),]
