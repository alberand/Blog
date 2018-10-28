#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

THEME = 'theme'
AUTHOR = 'Andrey Albershtein'
SITENAME = 'Andrey Albershtein'
SITEURL = 'http://127.0.0.1:8000'

PATH = './content'

TIMEZONE = 'Europe/Prague'

DEFAULT_LANG = 'en'
LOCALE = 'en_US.UTF-8'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (('Pelican', 'http://getpelican.com/'),
         ('You can modify those links in your config file', '#'),)

# Social widget
SOCIAL = (('GitHub', 'https://github.com/alberand'),
        ('Facebook', 'https://www.facebook.com/andrew.albershteyn'),
        ('Email', 'mailto:albershteyn.andrey@gmail.com'),
)

DEFAULT_PAGINATION = False
DISPLAY_PAGES_ON_MENU = True

# Sitemap
DIRECT_TEMPLATES = ('index', 'tags', 'categories', 'archives', 'sitemap')

SITEMAP_SAVE_AS = 'sitemap.xml'

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

# Copy files from conent folder to output folder
STATIC_PATHS = ['images', 'pdfs']

# Every new articale will be published as draft. So, nobody can see it.
# To publish article add metadata Status: published
DEFAULT_METADATA = {
            'status': 'draft',
            }

DEFAULT_CATEGORY = 'Misc'

# Latex
PLUGIN_PATHS = ["plugins", "./plugins"]

# Date
DEFAULT_DATE_FORMAT = '%d.%m.%Y'

# Articles in a right order
ARTICLE_ORDER_BY = 'reversed-date'
