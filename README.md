This zip archive includes everything needed to recreate the calculations and visualisations referred to in our article about Bandera:

**Rolf Fredheim, Gernot Howanitz, Mykola Makhortykh: "Scraping the Monumental: Stepan Bandera through the Lens of Quantitative Memory Studies". In Digital Icons 12 (2014), 25-53. Available online:** [Link hidden until publication]

All data was collected between 10-03-2013 and 30-03-2013. Additional YouTube data was collected in September 2013.

## Content
*Folders*
- [pythonScripts] Folder containing the python scripts for processing YouTube videos
- [rFunctions] Folder containing required scripts (these are run in the background)
- [TextViz images] Folder containing images obtained by visualising significant differences between aggregate texts
- [tweetData] Folder containing raw and processed tweets data, and texts of tweets divided by language
- [wikiData] Folder containing translated documents of Wikipedia discussions about Bandera
- [youtubeData] Folder containing raw and processed data from YouTube about videos featuring Bandera
- [youtubePlots] Folder containing the resulting plots from the python scripts

*files*
- README.txt - this file
- textComparison.R - R script to process wikipedia data
- tweetsData.R -  R script to process the twitter data
- tweetsStats.R - R script to visualise the twitter data
- youTube.R - R script to process and visualise the youtube data

++++++++++++++++

Processing the data is optional. We include both raw data and processed data, so the files above need not be run in order. They are set up in such a way as to require minimal changes. To use the scripts unzip the data into a new folder, keeping the structure of the zip archive. Open R, and set the working directory to the unzipped folder. Make sure you have an internet connection to download required packages, as well as to get data from Google and Twitter.

## Python scripts

The python scripts need the following packages to work: cv2, scipy, pylab, guess_language, urllib2. If you don't have them, install them with "sudo pip install $PACKAGE_NAME". Moreover, download.py needs the linux package 'youtube-dl', and the shell script xtractFrames.sh needs the linux pacakge 'ffmpeg'.

Execute python scripts in the following order:
- scrape.py to get video statistics as csv file. NOTE: The YouTube website has undergone a change recently, so this scraper needs to be adapted to work again!
- download.py to download the videos (uses csv file produced by scrape.py)
- xtractFrames.sh to extract frames from the downloaded videos
- extract.py to compute frame differences

The results from these steps can be found in the youTubeData directory, so you don't have to do everything again.

In order to recreate the plots from the youTubePlots directory, use the following:
- plot_video_labels.py to plot frame differences and print the YouTube ID of the videos
- plot_video_languages.py to plot frame differences and highlight video languages
- plot_video_types.py to plot frame differences and highlight video types
- plot_views_and_uploads.py to plot view counts and uploads of the videos
