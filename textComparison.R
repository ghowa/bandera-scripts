source ("rFunctions/comparisonFunctions.R")
source ("rFunctions/wikipediaEdits.R")
library(Hmisc) #for calculating probability
library(qdap) #for language functions
library(stringr) #for splitting strings

#Importance of genre: crucial for tone, almost insignificant for content
#Strengthen this further by removing unrecognised words



#Remove meta data from wiki pages
	wikiSub("wikiData/Bandera-disc-ru-trans.txt")
	wikiSub("wikiData/Bandera-disc-ukr-trans.txt")
	wikiSub("wikiData/Bandera-disc-pol-trans.txt")
	wikiSub("wikiData/Bandera-disc-en.txt")


#Remove words unrecognised by dictionary: this removes typos, foreign words, some slang, transliterated words, place names, personal names, untranslatable fragments.
	filterTexts()


#Load in texts
	#Calculates the number of negative words in WikiPedia edits
		ruWikiDisc <- calcNegative("wikiData/Bandera-disc-ru-trans.txt_filtered.txt")
		ukrWikiDisc <- calcNegative("wikiData/Bandera-disc-ukr-trans.txt_filtered.txt")
		polWikiDisc <- calcNegative("wikiData/Bandera-disc-pol-trans.txt_filtered.txt")
		enWikiDisc <- calcNegative("wikiData/Bandera-disc-en.txt_filtered.txt")

	#Calculates the number of negative words in WikiPedia articles
		ruWikiArticle <- calcNegative("wikiData/Bandera-article-ru-trans.txt_filtered.txt")
		ukrWikiArticle <- calcNegative("wikiData/Bandera-article-ukr-trans.txt_filtered.txt")
		polWikiArticle <- calcNegative("wikiData/Bandera-article-pol-trans.txt_filtered.txt")
		enWikiArticle <- calcNegative("wikiData/Bandera-article-en.txt_filtered.txt")


	#Calculates the number of negative words in YouTube comments
		polYoutube <- calcNegative("youtubeData/polish_trans.txt_filtered.txt")
		enYoutube <- calcNegative("youtubeData/english.txt_filtered.txt")
		ukrYoutube <- calcNegative("youtubeData/ukrainian_trans.txt_filtered.txt")
		ruYoutube <- calcNegative("youtubeData/russian_trans.txt_filtered.txt")

	#Calculates the number of negative words in Tweets
		ukrTweets <- calcNegative("tweetData/tweets_ukrainian_trans.txt_filtered.txt")
		ruTweets <- calcNegative("tweetData/tweets_russian_trans.txt_filtered.txt")


#Test results
	#No difference within wikipedia texts - largest difference between Polish (most neutral) and Russian (most negative)
	#Varies betwen 2.3 and 2.5% negativity
		calcProb(ruWikiDisc,ukrWikiDisc) #returns probability of detecting a difference
		calcProb(ukrWikiDisc,polWikiDisc) #returns probability of detecting a difference
		calcProb(polWikiDisc,ruWikiDisc) #returns probability of detecting a difference
		calcProb(enWikiDisc,ukrWikiDisc) #returns probability of detecting a difference
		calcProb(enWikiDisc,polWikiDisc) #returns probability of detecting a difference
		calcProb(enWikiDisc,ruWikiDisc) #returns probability of detecting a difference



	#for wikipedia articles:
	#Polish most negative, but insignificant difference
		calcProb(ruWikiArticle,ukrWikiArticle) #returns probability of detecting a difference
		calcProb(ukrWikiArticle,polWikiArticle) #returns probability of detecting a difference
		calcProb(polWikiArticle,ruWikiArticle) #returns probability of detecting a difference
		calcProb(enWikiArticle,ukrWikiArticle) #returns probability of detecting a difference
		calcProb(enWikiArticle,polWikiArticle) #returns probability of detecting a difference
		calcProb(enWikiArticle,ruWikiArticle) #returns probability of detecting a difference

	#Compare wiki to edits:
	#Generally higher, but not significantly so. Polish comes closest at 88% probability. Indicates the subject matter is gruesome, but not really contested.



	#25% chance of difference betwen Russian and Polish youtube comments. But still insignificant
	#English youtube comments are different. Here the negativity is from 5-15% higher, which is likely significiant. (e.g. for Russian v english 97%). Shows clashes
		calcProb(ruYoutube,ukrYoutube) #returns probability of detecting a difference
		calcProb(ruYoutube,polYoutube) #returns probability of detecting a difference
		calcProb(ruYoutube,enYoutube) #returns probability of detecting a difference
		calcProb(ukrYoutube,polYoutube) #returns probability of detecting a difference
		calcProb(ukrYoutube,enYoutube) #returns probability of detecting a difference
		calcProb(polYoutube,enYoutube) #returns probability of detecting a difference

	#as above for twitter
	#But here there are also language differences - RU 20% higher negativity in translatable words. 
		calcProb(ruTweets,ukrTweets) #returns probability of detecting a difference


	#difference between youtube and wiki edits:100 certainty that there is a difference in all three cases. 
	#On average the difference is 
		calcProb(ruYoutube,ruWikiArticle) #returns probability of detecting a difference
		calcProb(polYoutube,polWikiArticle) #returns probability of detecting a difference
		calcProb(ukrYoutube,ukrWikiArticle) #returns probability of detecting a difference
		#Consistently the youtube comments are more than twice as negative. 


		calcProb(ruYoutube,ruWiki) #returns probability of detecting a difference


	#Overall accross genres:
		overallWikiDisc <- ((as.numeric(ruWikiDisc[3])+as.numeric(enWikiDisc[3])+as.numeric(ukrWikiDisc[3])+as.numeric(polWikiDisc[3])))/(as.numeric(ruWikiDisc[2])+as.numeric(enWikiDisc[2])+as.numeric(ukrWikiDisc[2])+as.numeric(polWikiDisc[2]))
		overallWikiArticle <- ((as.numeric(ruWikiArticle[3])+as.numeric(enWikiArticle[3])+as.numeric(ukrWikiArticle[3])+as.numeric(polWikiArticle[3])))/(as.numeric(ruWikiArticle[2])+as.numeric(enWikiArticle[2])+as.numeric(ukrWikiArticle[2])+as.numeric(polWikiArticle[2]))
		overallYoutube <- ((as.numeric(ruYoutube[3])+as.numeric(enYoutube[3])+as.numeric(ukrYoutube[3])+as.numeric(polYoutube[3])))/(as.numeric(ruYoutube[2])+as.numeric(enYoutube[2])+as.numeric(ukrYoutube[2])+as.numeric(polYoutube[2]))
		overallTwitter <- ((as.numeric(ukrTweets[3])+as.numeric(ruTweets[3]))/(as.numeric(ukrTweets[2])+as.numeric(ruTweets[2])))



