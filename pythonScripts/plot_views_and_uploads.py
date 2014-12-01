#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Plot views and uploads using CSV data
@author: ghowa
"""

import sys
import pylab
import dateutil.parser as parser
import datetime


def main(argv=None):
    dates = []

    slots = [''] * 100
    uploads = [0] * 100

    # get 100 dates from vid_counts file
    file = open('../youTubeData/bandera_lat.txt', "r")
    count = 0
    while count < 100:
        line = file.readline()
        slots[count] = parser.parse(
            line.split(";")[3].replace('"', '').strip())
        count += 1
    file.close()

    slots.sort()

    # get video upload dates
    file = open('../youTubeData/upload_dates', "r")
    line = file.readline()
    while not line == "":
        try:
            d = int(line.split(";")[1].split(".")[0].strip())
            m = int(line.split(";")[1].split(".")[1].strip())
            y = int(line.split(";")[1].split(".")[2].strip())
        except ValueError:
            line = file.readline()
            continue
        dates.append(datetime.datetime(year=y, month=m, day=d))
        line = file.readline()
    file.close()

    dates.sort()

    count = 0

    date_counter = 0
    done = False

    # convert upload dates to 100 slots
    for date in dates:
        slot_counter = 0
        date_counter += 1
        for slot in slots:
            slot_counter += 1
            if slot >= date:
                try:
                    uploads[slot_counter] += 1
                except IndexError:
                    uploads[len(uploads) - 1] += (len(dates) - date_counter)
                    done = True
                break
        if done:
            break

    count = 0
    while count < len(slots):
        print '"' + "fake_id" + '";"view";"' + str(uploads[count]) + '";"' + str(slots[count]) + '"'
        count += 1

    # smooth values and plot them
    smooth_uploads = [0] * 200
    smooth_slots = [date.now()] * 200

    counter = 1
    while counter <= 100:
        smooth_uploads[counter * 2 - 2] = uploads[counter - 1]
        smooth_uploads[counter * 2 - 1] = uploads[counter - 1]
        smooth_slots[counter * 2 - 2] = slots[counter - 2]
        smooth_slots[counter * 2 - 1] = slots[counter - 1] - \
            datetime.timedelta(seconds=1)
        counter += 1

    pylab.plot(smooth_slots, smooth_uploads)
    figure = pylab.gcf()
    figure.set_size_inches(
        figure.get_size_inches()[0], figure.get_size_inches()[1])
    figure.savefig('uploads_per_100.png', bbox_inches='tight')

    # plot vid views for both cyrillic and latin videos

    view_counts = [0] * 100
    file = open('../youTubeData/bandera_views.txt', "r")
    line = file.readline()
    while not line == "":
        line_date = parser.parse(line.split(";")[3].replace('"', '').strip())
        counter = 0
        for slot in slots:
            if line_date == slot:
                view_counts[
                    counter] += float(line.split(";")[2].replace('"', ''
                                                                 ).strip())
                break
            counter += 1
        line = file.readline()

    smooth_view_counts = [0] * 200

    counter = 1
    while counter <= 100:
        smooth_view_counts[counter * 2 - 2] = view_counts[counter - 1]
        smooth_view_counts[counter * 2 - 1] = view_counts[counter - 1]
        counter += 1

    pylab.plot(smooth_slots, smooth_view_counts)
    figure = pylab.gcf()
    figure.set_size_inches(
        figure.get_size_inches()[0], figure.get_size_inches()[1])
    figure.savefig('view_counts.png', bbox_inches='tight')

if __name__ == "__main__":
    sys.exit(main())
