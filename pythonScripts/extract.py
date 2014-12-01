#!/usr/bin/python

"""
Feature extraction from images using tesseract and opencv
@author: ghowa
"""

import sys
import os
import cv2


def compute_frame_likeness(path):
    file_list = os.listdir(path)
    file_list.sort()
    previous_image = cv2.imread(path + os.sep + file_list[0])
    current_label = file_list[0].partition('.')[0]

    output = ""
    likenesses = []

    # for each extracted frame: compute difference to previous frame
    for img_name in file_list[1:]:
        # frame might be first frame of next video
        if not img_name.partition('.')[0] == current_label:
                # output now holds all frame differences for this vid
            output += current_label + ";" + \
                ";".join(map(str, likenesses)) + "\r\n"
            print current_label + " done"
            current_label = img_name.partition('.')[0]
            likenesses = []

        # compute frame differences
        full_path = path + os.sep + img_name
        image = cv2.imread(full_path)
        try:
            result = cv2.matchTemplate(
                image, previous_image, cv2.TM_CCORR_NORMED)
        except cv2.error:
            continue

        previous_image = image
        minVal, maxVal, minLoc, maxLoc = cv2.minMaxLoc(result)
        likenesses.append(maxVal)

    return output


def main(argv=None):
    if argv is None:
        argv = sys.argv

    if not argv[1:]:
        print 'Usage: ./extract.py $image_folder $output_file\nCreates a csv file with Youtube video ID and frame differences'
        sys.exit()

    if os.path.exists(argv[1]):
        result = compute_frame_likeness(argv[1])
        text_file = open(argv[2], "w")
        text_file.write(result)
        text_file.close()

if __name__ == "__main__":
    sys.exit(main())
