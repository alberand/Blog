Title: Add custom tags to markdown - python-markdown
Date: 28.03.2023
Modified: 28.03.2023
Status: published
Tags: python, pelican, python-markdown, markdown, tags
Keywords: markdown, python-markdown, pelican
Slug: markdown-custom-tags
Author: Andrey Albershtein
Summary: Wouldn't it be cool to add custom tags to markdown documents?
Lang: en

Wouldn't it be cool to add custom tags to markdown documents? I came across
this idea while reading [this blog][1]. Check out this [example][2]. The source
markdown includes several tags such as `<xeblog-conv` for "conversation" which
adds comments to the article, and `<xeblog-hero` for adding AI-generated Anime
art, which is really cool! Although I haven't investigated how it's done, I'm
excited to try implementing something similar myself.

As this blog is generated with [Pelican][3], I thought that maybe it's also
capable of parsing custom Markdown tags. Under the hood, Pelican uses
[python-markdown][4]. The docs says we can write [custom extensions][5] for Markdown.
Let's try and see how to do. I will show integration with Pelican but this can
be applied for anything using python-markdown.

Since this blog is generated with [Pelican][3], I wondered if it could parse
custom Markdown tags. After researching, I discovered that Pelican uses
[python-markdown][4] under the hood. According to the documentation, we can
write [custom extensions][5] for Markdown parser. I'll demonstrate integration
with Pelican, but this approach can be applied to anything that uses
python-markdown.

<div style="text-align: center; width: 100%">
<a href="#full-code">
Jump to the full code
</a>
</div>

[TOC]

### Block processor

Suppose we want to parse Markdown blocks that begin with the `[nickname]:`
prefix. The block is paragraph of text separated by newlines. Python-markdown
offers 5 different processors, each suited for different purposes. For instance,
if we wanted to censor certain words, we might use [Preprocessors][6].

[alberand]: This is comment I'm talking about. Check out the [source code][7]

Start with adding some imports in the pelicanconf.py:

```python
from markdown.extensions import Extension
from markdown.blockprocessors import BlockProcessor

import re
import xml.etree.ElementTree as etree
```

Then we need a processor which will look onto markdown blocks and decide if the
block need to be changed or not. The processor determines if a block requires
modification by calling the `self.test()` function. This function should return
`True` if block need to be changed by this processor. In this instance, I check
for a regular expression at the beginning of the block.

The second method `self.run()` is executed only if `self.test()` returns
true. This method receives the parent element of the HTML tree (such as a
`<div>` object) and a list of blocks. The list of blocks starts with the block
which matched in the `self.test()`. Therefore, `blocks[0]` will have multi-line
string of the block of interest. The rest of the list contains all the
subsequent blocks from the document.

We receive a list of block as our parser can look for a closing tag which is
placed in another block. As an example: code block can have newlines in it.

The processed block need to be `pop()`ed from the list with `blocks.pop(0)`.
Otherwise, if we failed to process the block, for example due to missing closing
tag, we can return `False`.

```python
class Comments(BlockProcessor):
    RE_FENCE_START = r'^\[([a-zA-Z0-9_-]{3,})\]: ' # [alberand]:

    def test(self, parent, block):
        return re.match(self.RE_FENCE_START, block)

    def run(self, parent, blocks):
        blocks[0] = re.sub(self.RE_FENCE_START, '', blocks[0])

        e = etree.SubElement(parent, 'div')
        e.set('class', 'comment')
        self.parser.parseChunk(e, blocks[0])
        blocks.pop(0)

        return True
```

The next stop is to create an Extension. This will be actually quite empty.
Simply copy this one or, [check the documentation][8] if you use something different
than `BlockProcessor`. In this call the `register()` requires processor instances,
name of this new processor, and priority (can stay 175).

```python
class AlberandTagsExtension(Extension):
    def extendMarkdown(self, md):
        md.parser.blockprocessors.register(Comments(md.parser), 'comments', 175)
```

The final step is to create our extension instance and let python-markdown lib
know about its existence. With a little bit more magic, you can also add
configuration parameters to your extension. These parameters should then be
added `extension_configs` section in `MARKDOWN` dictionary:

```python
MARKDOWN = {
  'extensions': [AlberandTagsExtension()],
  'extension_configs': {
    'markdown.extensions.extra': {},
    'markdown.extensions.meta': {},
  },
  'output_format': 'html5',
}
```

### Clickable images

The other wish I had was to make every image in my Blog clickable (opens
in a new tab). However, the default Pelican doesn't offer this feature. Luckily,
it's easy to achieve with processors.

In the following implementation we first parse markdown block to get
parameters such as text and link. Then, we create a `<div class="image-container">`,
inside this div we add a link `<a>` with an image `<img>` inside. This way, image
is wrapped in the link that opens in a new tab when clicked. The `class` also
allows to apply CSS style on all images uniformly, such as centering them.

```
from markdown.inlinepatterns import LinkInlineProcessor

class ImageInlineProcessor(LinkInlineProcessor):
    """ Return a img element from the given match. """

    def handleMatch(self, m, data):
        text, index, handled = self.getText(data, m.end(0))
        if not handled:
            return None, None, None

        src, title, index, handled = self.getLink(data, index)
        if not handled:
            return None, None, None

        div = etree.Element("div")
        div.set("class", "image-container")

        a = etree.SubElement(div, "a")
        a.set("href", src)

        img = etree.SubElement(a, "img")

        img.set("src", src)

        if title is not None:
            img.set("title", title)

        img.set('alt', self.unescape(text))

        return div, m.start(0), index
```

The difference from the comment processor above is that python-markdown already
has default Image processor. We need to deregister the default one and replace
it with our own implementation.

```python
# The regex is copied from python-markdown source code
IMAGE_LINK_RE = r'\!\['

class AlberandTagsExtension(Extension):
    def extendMarkdown(self, md):
        # Deregister default image processor and replace it with our custom one
        md.inlinePatterns.deregister('image_link')
        md.inlinePatterns.register(
                ImageInlineProcessor(IMAGE_LINK_RE, md), 'image_link', 150)
```

### Full Code

Put this into `pelicanconf.py`:

```python
from markdown.extensions import Extension
from markdown.blockprocessors import BlockProcessor

import re
import xml.etree.ElementTree as etree

class ImageInlineProcessor(LinkInlineProcessor):
    """ Return a img element from the given match. """

    def handleMatch(self, m, data):
        text, index, handled = self.getText(data, m.end(0))
        if not handled:
            return None, None, None

        src, title, index, handled = self.getLink(data, index)
        if not handled:
            return None, None, None

        div = etree.Element("div")
        div.set("class", "image-container")

        a = etree.SubElement(div, "a")
        a.set("href", src)

        img = etree.SubElement(a, "img")

        img.set("src", src)

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
    'markdown.extensions.extra': {},
    'markdown.extensions.meta': {},
  },
  'output_format': 'html5',
}
```

[1]: https://xeiaso.net/blog
[2]: https://raw.githubusercontent.com/Xe/site/main/blog/voice-control-talon.markdown
[3]: https://getpelican.com/
[4]: https://github.com/Python-Markdown/markdown
[5]: https://python-markdown.github.io/extensions/api/#writing-extensions-for-python-markdown
[6]: https://python-markdown.github.io/extensions/api/#preprocessors
[7]: https://raw.githubusercontent.com/alberand/Blog/master/content/markdown-custom-tags.md
[8]: https://python-markdown.github.io/extensions/api/
