#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals
import ntpath

# Personal Information
AUTHOR = 'Andrey Albershtein'
SITENAME = 'Andrey Albershtein'
EMAIL = 'andrey.albershteyn@gmail.com'
# General configuration
THEME = 'theme'
# SITEURL = 'http://127.0.0.1:8000'
SITEURL = 'http://192.168.1.33:8000'
GITHUB_SOURCE_PATH = 'https://github.com/alberand/Blog/blob/master/content/'
PATH = './content'
# Time/Zone settings
TIMEZONE = 'Europe/Prague'
DEFAULT_DATE_FORMAT = ('%d %b %Y')
# Language settings
DEFAULT_LANG = 'en'
LOCALE = 'en_US.UTF-8'
# Setup the RSS/ATOM feeds:
FEED_DOMAIN = SITEURL
FEED_MAX_ITEMS = 10
FEED_RSS = 'feeds/rss.xml'
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (
    ('Pelican', 'http://getpelican.com/'),
)

# Social widget
SOCIAL = (
    ('GitHub', 'https://github.com/alberand'),
    ('Email', 'mailto:{}'.format(EMAIL)),
)

DEFAULT_PAGINATION = False
DISPLAY_PAGES_ON_MENU = True
DISPLAY_CATEGORIES_ON_MENU = True

# Sitemap
DIRECT_TEMPLATES = ('index', 'tags', 'categories', 'archives', 'sitemap')
SITEMAP_SAVE_AS = 'sitemap.xml'
# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

# Copy files from conent folder to output folder
STATIC_PATHS = [
	'images', 
	'pdfs', 
	'materials',
    	'extra'
]

EXTRA_PATH_METADATA = {
    'extra/robots.txt': {'path': 'robots.txt'},
    'extra/favicon.ico': {'path': 'favicon.ico'},  # and this
    'extra/LICENSE': {'path': 'LICENSE'},
    'extra/.htaccess' : { 'path' : '.htaccess'},
    'extra/robots.txt' : { 'path' : 'robots.txt' }
}

# Every new articale will be published as draft. So, nobody can see it.
# To publish article add metadata Status: published
DEFAULT_METADATA = {'status': 'draft'}
DEFAULT_CATEGORY = 'Article'
PLUGIN_PATHS = ["plugins", "/home/andrew/.local/share/pelican-plugins"]
PLUGINS = [
    'liquid_tags.include_code',
    'render_math'
]

# Liquid tag
CODE_DIR = 'materials'
# Date
DEFAULT_DATE_FORMAT = '%d.%m.%Y'
# Articles in a right order
ARTICLE_ORDER_BY = 'reversed-date'

def getGitHubPage(source_file):
    filename = ntpath.basename(source_file)
    return '{0}/{1}'.format(GITHUB_SOURCE_PATH, filename)

JINJA_FILTERS = {
    'asGitHubPage' : getGitHubPage
}
