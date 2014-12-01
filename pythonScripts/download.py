#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Youtube Video Downloader using youtube-dl
@author: ghowa
"""

import sys
import subprocess
import csv
from sets import Set


def download(video_id):
    # Needs youtube-dl installed -- might not work on Windows boxes...
    youtube_dl = subprocess.Popen((['youtube-dl', video_id]))
    youtube_dl.wait()


def execute_task(videos, task, output_path):
    result = ''
    for video_id in videos:
        temp = task(video_id)
        if temp:
            result = result + temp

    file_handler = open(output_path, 'w+')
    file_handler.write(result)
    file_handler.close()


def main(argv=None):
    if argv is None:
        argv = sys.argv

    if not argv[1:]:
        print 'Youtube Video Quick Downloader v0.1\n Usage: ./download.py $STATSCSV $OUTPUTDIR'
        sys.exit()

    task = download
    videos = Set([])

    with open(argv[1], 'rb') as csvfile:
        rdr = csv.reader(csvfile, delimiter=';', quotechar='"')
        for row in rdr:
            videos.add(row[0])

    print str(len(videos)) + ' videos found.'
    #videos = retrieve_videos_from_youtube(argv[2])

    execute_task(videos, task, argv[2])

if __name__ == "__main__":
    sys.exit(main())
