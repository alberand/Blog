#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals
import ntpath
import uuid
from pygments.formatters import HtmlFormatter
from markdown.extensions.codehilite import CodeHiliteExtension
from markdown.extensions import Extension
from markdown.blockprocessors import BlockProcessor
from markdown.inlinepatterns import LinkInlineProcessor
import re
import xml.etree.ElementTree as etree

# Personal Information
AUTHOR = 'Andrey Albershtein'
SITENAME = 'Andrey Albershtein'
EMAIL = 'andrey.albershteyn@gmail.com'
TWITTER_USERNAME = 'alberand_'
# General configuration
THEME = 'theme'
SITEURL = 'http://127.0.0.1:8000'
SITELOGO = {
    'url': 'images/blog-logo.png',
    'width': "256",
    'height': "256",
}
# SITEURL = 'http://192.168.1.33:8000'
GITHUB_SOURCE_PATH = 'https://github.com/alberand/Blog/blob/master/content/'
PATH = './content'
# Time/Zone settings
TIMEZONE = 'Europe/Prague'
DEFAULT_DATE_FORMAT = ('%d %b %Y')
# Language settings
DEFAULT_LANG = 'en'
LOCALE = 'en_US.UTF-8'
# Setup the RSS/ATOM feeds:
#FEED_DOMAIN = SITEURL
#FEED_MAX_ITEMS = 10
#FEED_RSS = 'feeds/rss.xml'
#FEED_ALL_ATOM = None
#CATEGORY_FEED_ATOM = None
#TRANSLATION_FEED_ATOM = None
#AUTHOR_FEED_ATOM = None
#AUTHOR_FEED_RSS = None

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
DIRECT_TEMPLATES = ('index', 'sitemap')
SITEMAP_SAVE_AS = 'sitemap.xml'
# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

# Copy files from conent folder to output folder
STATIC_PATHS = [
	'images',
	'materials',
	'extra',
	'static'
]

EXTRA_PATH_METADATA = {
    'extra/robots.txt': {'path': 'robots.txt'},
    'extra/favicon.ico': {'path': 'favicon.ico'},  # and this
    'extra/CNAME': {'path': 'CNAME'},  # and this
    'extra/LICENSE': {'path': 'LICENSE'},
    'extra/.htaccess' : { 'path' : '.htaccess'},
    'extra/robots.txt' : { 'path' : 'robots.txt' }
}

# Every new articale will be published as draft. So, nobody can see it.
# To publish article add metadata Status: published
DEFAULT_METADATA = {'status': 'draft'}
DEFAULT_CATEGORY = 'Article'
# PLUGIN_PATHS = ["@pelican_plugins@"]
PLUGINS = [
        #'liquid_tags',
        # 'render_math'
]

# Add following code to your JS file:
# function copy_to_clipboard(element) {
# 	var range = document.createRange();
# 	range.selectNode(element);
# 	window.getSelection().removeAllRanges();
# 	window.getSelection().addRange(range);
# 	document.execCommand("copy");
# 	window.getSelection().removeAllRanges();
# }
# Then in your pelicanconf.py do:
#
# from pygments_local_formatter import CodeCopyButtonHtmlFormatter
#
# MARKDOWN = {
#   ... <snip>...
#   'extension_configs': {
#     'markdown.extensions.codehilite': {
#         'css_class': 'highlight',
#         'pygments_formatter': CodeCopyButtonHtmlFormatter,
#     },
#   },
#   ... <snip>...
# }

class CodeCopyButtonHtmlFormatter(HtmlFormatter):
    def _wrap_div(self, inner):
        style = []
        if (self.noclasses and not self.nobackground and
                self.style.background_color is not None):
            style.append('background: %s' % (self.style.background_color,))
        if self.cssstyles:
            style.append(self.cssstyles)
        style = '; '.join(style)

        uid = uuid.uuid1()
        cssclass = (self.cssclass and ' class="%s"' % self.cssclass)
        cssstyle = (style and (' style="%s"' % style))
        open_div = f'''
            <div {cssclass} {cssstyle} id="code-{uid}">
                <button
                  type="button"
                  class="copy-code-button"
                  onclick="copy_to_clipboard(document.getElementById('code-{uid}').getElementsByTagName('code')[0])">
                    copy
                </button>
        '''

        yield 0, open_div
        yield from inner
        yield 0, '</div>\n'

class ImageInlineProcessor(LinkInlineProcessor):
    """ Return a img element from the given match. """

    def handleMatch(self, m, data):
        text, index, handled = self.getText(data, m.end(0))
        if not handled:
            return None, None, None

        src, title, index, handled = self.getLink(data, index)
        if not handled:
            return None, None, None


        div = etree.Element("figure")
        div.set("class", "article-figure")

        img = etree.SubElement(div, "img")
        img.set("src", src)

        if re.search('\d+x\d+', src):
            width, height = src.split('_')[-1].split('.')[0].split('x')
            img.set("width", width)
            img.set("height", height)
            img.set("style", f'aspect-ratio: {width}/{height};')

        if title is not None:
            img.set("title", title)

        img.set('alt', self.unescape(text))

        return div, m.start(0), index

class Comments(BlockProcessor):
    RE_FENCE_START = r'^\[([a-zA-Z0-9_-]{3,})\]: ' # [alberand]:

    def test(self, parent, block):
        return re.match(self.RE_FENCE_START, block)

    def run(self, parent, blocks):
        blocks[0] = re.sub(self.RE_FENCE_START, '', blocks[0])

        blocks[0] = f'/\* {blocks[0]} \*/'

        e = etree.SubElement(parent, 'div')
        e.set('class', 'comment')
        self.parser.parseChunk(e, blocks[0])
        blocks.pop(0)

        return True

IMAGE_LINK_RE = r'\!\['

class AlberandTagsExtension(Extension):
    def extendMarkdown(self, md):
        md.parser.blockprocessors.register(Comments(md.parser), 'comments', 175)

        # Deregister default image processor and replace it with our custom one
        md.inlinePatterns.deregister('image_link')
        md.inlinePatterns.register(
                ImageInlineProcessor(IMAGE_LINK_RE, md), 'image_link', 150)

MARKDOWN = {
  'extensions': [AlberandTagsExtension()],
  'extension_configs': {
    'markdown.extensions.codehilite': {
        'css_class': 'highlight',
        'pygments_formatter': CodeCopyButtonHtmlFormatter,
    },
    'markdown.extensions.toc': {
      'title': 'Table of contents:'
    },
    'markdown.extensions.extra': {},
    'markdown.extensions.meta': {},
  },
  'output_format': 'html5',
}

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

