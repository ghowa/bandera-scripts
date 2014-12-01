source ("comparisonFunctions.R")


#Strengthen this further by removing unrecognised words

#Remove meta data from wiki pages
wikiSub("wikiData/Bandera-disc-ru-trans.txt")
wikiSub("wikiData/Bandera-disc-ukr-trans.txt")
wikiSub("wikiData/Bandera-disc-pol-trans.txt")

#Calculates the number of negative sentences in WikiPedia data
ruWiki <- calcNegative("wikiData/Bandera-disc-ru-trans.txt")
ukrWiki <- calcNegative("wikiData/Bandera-disc-ukr-trans.txt")
polWiki <- calcNegative("wikiData/Bandera-disc-pol-trans.txt")

#Calculates the number of negative sentences in YouTube comments
polYoutube <- calcNegative1("youtubeData/polishComments.txt")
enYoutube <- calcNegative1("youtubeData/englishComments.txt")
ukrYoutube <- calcNegative1("youtubeData/ukrainianComments.txt")
ruYoutube <- calcNegative1("youtubeData/russianComments.txt")

#No difference within wikipedia texts - largest difference between Polish (most neutral) and Russian (most negative)
calcProb(ruWiki,ukrWiki) #returns probability of detecting a difference
calcProb(ukrWiki,polWiki) #returns probability of detecting a difference
calcProb(polWiki,ruWiki) #returns probability of detecting a difference

#65% change in difference betwen Russian and English youtube comments. But still insignificant
calcProb(ruYoutube,ukrYoutube) #returns probability of detecting a difference
calcProb(ruYoutube,polYoutube) #returns probability of detecting a difference
calcProb(ruYoutube,enYoutube) #returns probability of detecting a difference
calcProb(ukrYoutube,polYoutube) #returns probability of detecting a difference
calcProb(ukrYoutube,enYoutube) #returns probability of detecting a difference
calcProb(polYoutube,enYoutube) #returns probability of detecting a difference


#difference between youtube and wiki edits:100 certainty that there is a difference in all three cases. 
#On average the difference is 
calcProb(ruYoutube,ruWiki) #returns probability of detecting a difference
calcProb(polYoutube,polWiki) #returns probability of detecting a difference
calcProb(ukrYoutube,ukrWiki) #returns probability of detecting a difference





