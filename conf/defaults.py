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

# Projects
PROJECTS = [
    (
        "Warehouse", "https://github.com/dstufft/warehouse",
        "Next Generation Python Package Index",
    ),
    (
        "PyNaCl", "https://github.com/dstufft/pynacl",
        "Python binding to the Networking and Cryptography (NaCl) library",
    ),
    (
        "bcrypt", "https://github.com/dstufft/bcrypt",
        "Modern password hashing for your software and your servers",
    ),
    (
        "xmlrpc2", "https://github.com/dstufft/xmlrpc2",
        "xmlrpc library for Python built on requests",
    ),
    (
        "Slumber", "https://github.com/dstufft/slumber",
        "A library that makes consuming a RESTful API easier and more "
            "convenient",
    )
]

DEFAULT_PAGINATION = False

DIRECT_TEMPLATES = ["index"]

ARTICLE_URL = "blog/{slug}/"
ARTICLE_SAVE_AS = "blog/{slug}/index.html"

PAGE_URL = "{slug}/"
PAGE_SAVE_AS = "{slug}/index.html"

AUTHOR_SAVE_AS = False
CATEGORY_SAVE_AS = False
TAG_SAVE_AS = False

FILENAME_METADATA = "(?P<date>\d{4}-\d{2}-\d{2})-(?P<slug>.*)"

THEME = "themes/caremad"

PLUGIN_PATH = "plugins"
PLUGINS = [
    "assets",
    "gzip_cache",
    "optimize_images",
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
