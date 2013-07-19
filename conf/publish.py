#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import os.path
import sys

sys.path = [os.path.dirname(__file__)] + sys.path

from defaults import *

SITEURL = "https://caremad.io"
RELATIVE_URLS = False

FEED_DOMAIN = SITEURL
FEED_ALL_ATOM = "feeds/all.atom.xml"
CATEGORY_FEED_ATOM = "feeds/%s.atom.xml"

DELETE_OUTPUT_DIRECTORY = True
