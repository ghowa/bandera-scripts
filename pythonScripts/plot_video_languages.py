#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Plot frame differences and highlight
video languages
@author: ghowa
"""

import sys
import scipy.stats
import pylab
import guess_language

from HTMLParser import HTMLParser


class MLStripper(HTMLParser):

    def __init__(self):
        self.reset()
        self.fed = []

    def handle_data(self, d):
        self.fed.append(d)

    def get_data(self):
        return ''.join(self.fed)


def strip_tags(html):
    s = MLStripper()
    s.feed(html)
    return s.get_data()


def main(argv=None):
    """ Main function """
    if argv is None:
        argv = sys.argv

    points = []
    labels = []
    ru = []
    en = []
    uk = []
    pl = []
    ru_labels = []
    en_labels = []
    uk_labels = []
    pl_labels = []
    points_labels = []
    title_labels = dict()
    lang_labels = dict()
    type_labels = dict()

    type_file = open('../youTubeData/video_type', "r")
    type_line = type_file.readline()
    while not type_line == "":
        type_labels[type_line.split(";")[0]] = type_line.split(";")[1].strip()
        type_line = type_file.readline()

    lang_file = open('../youTubeData/manually_recognized', "r")
    lang_line = lang_file.readline()
    while not lang_line == "":
        lang_labels[lang_line.split(";")[0]] = lang_line.split(";")[1].strip()
        lang_line = lang_file.readline()

    title_file = open("../youTubeData/all_frames_stats_title", "r")
    line = " "
    manual = 0
    while not line == "":
        line = title_file.readline()
        lbl = line.strip()
        # .lower().replace("stepan bandera","en")
        title = title_file.readline()
        title_labels[lbl] = title
        title_lang = guess_language.guessLanguage(strip_tags(title))
        desc = title_file.readline()

        try:
            desc.split("No description available")[1]
            desc = ""
        except IndexError:
            pass
        desc_lang = guess_language.guessLanguage(strip_tags(desc))
        line = title_file.readline()
        lang = guess_language.guessLanguage(
            strip_tags(title) + strip_tags(desc))

        if lbl in lang_labels:
            print lbl, " found"
            continue

        print lbl, " not found"
        if lang in ['uk', 'ru', 'pl', 'en']:
            lang_labels[lbl] = lang
        else:
            manual += 1
            print "------------------------------------------------------------"
            print title_lang, desc_lang
            print title
            print desc
            print "------------------------------------------------------------"
            l = raw_input("which language? ")
            lang_labels[lbl] = l

        print manual, " manually recognized"

    lang_file.close()
    lang_file_content = ""
    print lang_labels
    for key in lang_labels.keys():
        lang_file_content += key + ";" + lang_labels[key] + "\r\n"

    print lang_file_content
    lang_file = open('../youTubeData/manually_recognized', "w")
    lang_file.write(lang_file_content)
    lang_file.close()

    text_file = open('../youTubeData/all_frames_stats', "r")
    line = " "
    counter = 0
    while not line == "":
        line = text_file.readline()
        counter = counter + 1
        try:
            values = map(float, line.split('\r\n')[0].split(';')[1:])
            label = line.split(';')[0]
            labels.append(label)
            size, min_max, mean, variance, skew, kurt = scipy.stats.describe(
                values)
            # throw out vids under 20 seconds
            if size < 20:
                print "video too short: ", label
                continue

            # cut min variance at 0.001, otherwise the plot gets quite
            # distorted
            if variance < 0.001:
                variance = 0.001

        except ValueError:
            print "error calculating stats for ", label
            continue

        point = [mean, variance]

        try:
            if lang_labels[label] == "uk":
                uk.append(point)
                uk_labels.append(label)
            elif lang_labels[label] == "ru":
                ru.append(point)
                ru_labels.append(label)
            elif lang_labels[label] == "en":
                en.append(point)
                en_labels.append(label)
            elif lang_labels[label] == "pl":
                pl.append(point)
                pl_labels.append(label)
            else:
                points.append(point)
                points_labels.append(label)
        except:
            points.append(point)
            points_labels.append(label)

    print counter, " lines read."
    print "number of labels ", str(len(labels))
    print "number of labels ", str(len(lang))

    pylab.show()
    pylab.xlabel('Mean')
    pylab.ylabel('Variance')
    # pylab.yscale("log")
    pylab.title("Frame Likenesses of Bandera Youtube Clips")

    pylab.plot(*zip(*points), marker='o', color='w', ls='')
    pylab.plot(*zip(*uk), marker='o', color='#ff8000', ls='')
    pylab.plot(*zip(*ru), marker='o', color='#b40404', ls='')
    pylab.plot(*zip(*pl),  marker='o', color='#66FF00', ls='')
    pylab.plot(*zip(*en),  marker='o', color='#819FF7', ls='')

    figure = pylab.gcf()
    figure.set_size_inches(
        figure.get_size_inches()[0] * 2, figure.get_size_inches()[1] * 2)
    figure.savefig('video_langs.png', bbox_inches='tight')

if __name__ == "__main__":
    sys.exit(main())
