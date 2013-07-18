#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import os
import os.path

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))

AUTHOR = "Donald Stufft"
SITENAME = "Caremad"
SITEURL = ""

TIMEZONE = "America/New_York"

DEFAULT_LANG = "en"

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None

# Blogroll
LINKS = [
    ("Pelican", "http://getpelican.com/"),
    ("Python.org", "http://python.org/"),
    ("Jinja2", "http://jinja.pocoo.org/"),
    ("You can modify those links in your config file", "#"),
]

# Social widget
SOCIAL = [
    ("You can add links in your config file", "#"),
    ("Another social link", "#"),
]

DEFAULT_PAGINATION = False

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

DIRECT_TEMPLATES = ["index"]

ARTICLE_URL = "blog/{slug}/"
ARTICLE_SAVE_AS = "blog/{slug}/index.html"

AUTHOR_SAVE_AS = False
CATEGORY_SAVE_AS = False
TAG_SAVE_AS = False

FILENAME_METADATA = "(?P<date>\d{4}-\d{2}-\d{2})-(?P<slug>.*)"

THEME = "themes/caremad"

PLUGIN_PATH = "plugins"
PLUGINS = [
    "assets",
]

ASSET_CONFIG = [
    ("COMPASS_BIN", os.path.join(ROOT_DIR, "bin", "compass")),
    ("COMPASS_PLUGINS", [
        "compass-normalize",
    ]),
    ("COMPASS_CONFIG", {
        "http_path": "/theme/",
    }),
]
