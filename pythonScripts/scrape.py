#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Youtube Video Scraper
@author: ghowa
"""

import sys
import urllib2
import datetime
import os


def get_comments(video_id):

    result = ''

    for page in range(1, 1000):
        query_url = 'http://www.youtube.com/all_comments?v=' + \
            video_id + "&page=" + str(page)
        print query_url

        request = urllib2.Request(query_url, None, {'Referer': 'testing'})
        response = urllib2.urlopen(request)

        xml = response.read()
        if xml.split("<title>")[1].split("!")[0] == 'Oops':
            return result

        no_comments = 1
        try:
            xml.split('Video has no comments')[1]
        except IndexError:
            no_comments = 0
        if no_comments == 1:
            print 'No comments found!'
            return result

        for comment in xml.split('span class="author ">')[1:]:
            try:
                author = comment.split("/user/")[1].split('"')[0]
            except IndexError:
                try:
                    author = comment.split("/channel/")[1].split('"')[0]
                except IndexError:
                    return result
            try:
                time = comment.split('<span class="time" dir="ltr">')[1].split(
                    ">")[1].split("</a")[0].strip()
                text = comment.split('<div class="comment-text" dir="ltr">')[1].split("</div>")[0].strip().replace('<p>', '').replace('</p>', '').replace(
                    '\n', '').replace('"', "'").replace('&quot;', "'").replace('&#39;', "'").replace('<wbr>&shy;', '').replace('&quot;', '&')
            except IndexError:
                print 'error: no comment time or comment text found'
                return result

            result = result + '"' + video_id + '";"' + author + \
                '";"' + time + '";"' + text + '"' + os.linesep

    return result


def convert(video_id, value_type, points, max_value, start_date, end_date):

    result = ''

    start_date = datetime.datetime.strptime(start_date, '%m/%d/%y')
    end_date = datetime.datetime.strptime(end_date, '%m/%d/%y')

    difference = end_date - start_date
    day_step = difference.days / 100.0

    previous = 0
    data_date = start_date

    for point in points:
        temp = ((float(point) * float(max_value)) / 100)
        point = temp - previous
        previous = temp
        data_date = data_date + datetime.timedelta(days=day_step)
        result += '"' + video_id + '"; "' + value_type + '"; "' + \
            str(point) + '"; "' + str(data_date) + '"' + os.linesep

    return result


def retrieve_metadata(video_id):

    query_url = 'http://www.youtube.com/insight_ajax?action_get_statistics_and_data=1&v=' + \
        video_id
    print query_url

    request = urllib2.Request(query_url, None, {'Referer': 'testing'})
    response = urllib2.urlopen(request)
    xml = response.read()

    try:
        # TODO: use regex...
        comments = xml.split(
            "stats-box-top")[1].split("chd=t:")[1].split('"')[0].split(',')
        max_comments = int(
            xml.split("stats-box-top")[1].split("<h4>")[1].split("</h4>")[0])

        favs = xml.split(
            "stats-box-top")[2].split("chd=t:")[1].split('"')[0].split(',')
        max_favs = int(
            xml.split("stats-box-top")[2].split("<h4>")[1].split("</h4>")[0])

        likes = xml.split(
            "stats-box-bottom")[1].split("chd=t:")[1].split('"')[0].split(',')
        max_likes = int(
            xml.split("stats-box-bottom")[1].split("<h4>")[1].split("</h4>")[0])

        dislikes = xml.split(
            "stats-box-bottom")[2].split("chd=t:")[1].split('"')[0].split(',')
        max_dislikes = int(
            xml.split("stats-box-bottom")[2].split("<h4>")[1].split("</h4>")[0])

        views = ((xml.split("stats-big-chart-expanded"))
                 [1]).split("&amp;chd=t:")[1].split("&amp;")[0].split(',')
        max_views = int(((xml.split('<div class="stats-views">')))
                        [1].split('<h3>')[1].split('</h3>')[0].replace('.', '')
                        .replace(',', ''))

        dates_array = ((xml.split("stats-big-chart-expanded"))
                       [1]).split('&amp;chxl=1:|')[1].split('&amp;')[0].split('|')
        start_date = dates_array[0]
        end_date = dates_array[len(dates_array) - 1]

    except IndexError:
        print 'No stats found!'
        return

    view_string = convert(
        video_id, 'view', views, max_views, start_date, end_date)
    comment_string = convert(
        video_id, 'comments', comments, max_comments, start_date, end_date)
    fav_string = convert(
        video_id, 'favs', favs, max_favs, start_date, end_date)
    like_string = convert(
        video_id, 'likes', likes, max_likes, start_date, end_date)
    dislike_string = convert(
        video_id, 'dislikes', dislikes, max_dislikes, start_date, end_date)

    return view_string + comment_string + fav_string + like_string \
        + dislike_string


def execute_task(videos, task, output_path):
    result = ''
    for video_id in videos:
        temp = task(video_id)
        if temp:
            result = result + temp

    file_handler = open(output_path, 'w+')
    file_handler.write(result)
    file_handler.close()


def retrieve_videos_from_youtube(query):
    videos = []
    counter = 0
    for page in range(1, 10):
        query_url = 'https://www.youtube.com/results?search_query=' + \
            query + '&page=' + str(page)
        print query_url

        request = urllib2.Request(query_url, None, {'Referer': 'testing'})
        response = urllib2.urlopen(request)

        xml = response.read()

        for video_id in xml.split('yt-uix-sessionlink yt-uix-tile-link yt-uix-contextlink')[1:]:
            try:
                videos.append(
                    video_id.split('/watch?v=')[1].split('"')[0]
                    .split('&amp')[0])
                counter += 1
                if counter > 100:
                    return videos
            except IndexError:
                page += 1

    return videos


def main(argv=None):
    if argv is None:
        argv = sys.argv

    if not argv[1:]:
        print 'Youtube Video Scraper v0.2\n--------------------------' + '\nUsage\n ./scrape.py [-q search_string|-v video_id] [-c output_file |-s output_file]\n\n Options:\n -q: Execute for all videos found by search_string\n -v: Execute for this Youtube video ID \n -c: save comments as csv\n -s: save video statistics as csv\n\n Example:\n ./scrape.py -q stepan+bandera -c comments.txt'
        print '\n\nNOTE: The YouTube website has undergone a change recently, so this scraper needs to be adapted to work again!\n\n'
        sys.exit()

    videos = []

    if argv[1] == '-q':
        videos = retrieve_videos_from_youtube(argv[2])
    elif argv[1] == '-v':
        videos.append(argv[2])

    output = ''
    if argv[3] == "-c":
        task = get_comments
        output = argv[4]
    elif argv[3] == "-s":
        task = retrieve_metadata
        output = argv[4]

    execute_task(videos, task, output)

if __name__ == "__main__":
    sys.exit(main())
