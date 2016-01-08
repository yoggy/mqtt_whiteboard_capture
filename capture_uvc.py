#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# capture_uvc.py - simple still image capture tool for UVC camera.
#
# Setup:
#   $ sudo usermod -aG video username
#   $ sudo apt-get install v4l-utils python-opencv python-dev
#   $ wget https://raw.githubusercontent.com/yoggy/capture_uvc.py/master/capture_uvc.py
#   $ chmod +x capture_uvc.py
#
# How to use:
#   $ v4l2-ctl --device=/dev/video0 --list-formats-ext
#   $ v4l2-ctl --device=/dev/video0 -c exposure_auto=1,exposure_auto_priority=0,exposure_absolute=160
#   $ ./capture_uvc.py -w 1920 -h 1080 -o capture.png
#
# License:
#   Copyright (c) 2016 yoggy <yoggy0@gmail.com>
#   Released under the MIT license
#   http://opensource.org/licenses/mit-license.php;
#
import cv2
import sys
from argparse import ArgumentParser

if len(sys.argv) != 3:
  print 'Usage: %s resolution filename.png' % sys.argv[0]
  print ''
  print '    example:'
  print '        $ %s 1920x1080 capture.png' % sys.argv[0]
  print ''
  quit()

res = sys.argv[1].split('x')
capture_width  = int(res[0])
capture_height = int(res[1])
filename       = sys.argv[2]

cap = cv2.VideoCapture(0)
cap.set(3, capture_width)
cap.set(4, capture_height)

for i in range(10):
  cap.read()

ret, img = cap.read()
cv2.imwrite(filename, img)
cap.release()

