Title: Add custom tags to markdown - python-markdown
Date: 28.03.2023
Modified: 28.03.2023
Status: draft
Tags: python, pelican, python-markdown, markdown, tags
Keywords: markdown, python-markdown, pelican
Slug: markdown-custom-tags
Author: Andrey Albershtein
Summary: Wouldn't it be cool to add custom tags to markdown documents?
Lang: en

Wouldn't it be cool to add custom tags to markdown documents? I come up with
this idea when saw that in [this blog][1]. Here is [example][2]. In source
markdown has a few different tags such as `<xeblog-conv` and `<xeblog-hero`. The
first one is for "conversation", which adds some kind of comments into the
article. The second one is really cool - this adds AI generated Anime art. I
haven't investigated how it's done but surely I will try to implement similar
thing.

As this blog is generated with [Pelican][3], I thought that maybe it's also
capable of parsing custom Markdown tags. Under the hood, Pelican uses
[python-markdown][4]. The docs says we can write [custom extensions][5] for Markdown.
Let's try and see how to do. I will show integration with Pelican but this can
be applied for anything using python-markdown.

<div style="text-align: center; width: 100%">
<a href="#full-code">
Jump to the full code
</a>
</div>

[TOC]

### Block processor

Let's say we want to parse Markdown blocks which starts with `[nickname]: `
prefix. The block is paragraph of text separated by newlines. Python-markdown
can 5 different processors. Each of them should be used depending on what you
want to achieve. For example, for censorship of words I would probably go with
[Preprocessors][6].

[alberand]: this is comment I'm talking about. Check out the [source code][7]

Add some imports in the pelicanconf.py:

```python
from markdown.extensions import Extension
from markdown.blockprocessors import BlockProcessor

import re
import xml.etree.ElementTree as etree
```

Then we need a processor which will look onto markdown blocks and decide if it
should change it or not. The way it decides if the block needs to be changed is
by calling `self.test()` function. This function should return `True` if block
need to be changed by this processor. In this particular case I just check for
regular expression in the beginning of the block.

The second method `self.run()` is executed only in case `self.test()` returned
true. This method gets parent element of the HTML tree (for example `<div>`
object) and list of blocks. The list of blocks starts with the block which
matched in the `self.test()`. Therefore, `blocks[0]` will have multi-line string
of the block of interest. The rest of the list contains all the following blocks
from the document.

We get a list of block as our parser can look for a closing tag which is placed
in another block. As an example code block can have newlines in it.

To let python-markdown know that we processed the block we need to `pop()` it
from the list with `blocks.pop(0)`. Otherwise, if we failed to process the block
we can return `None` or `False`.

```python
class Comments(BlockProcessor):
    RE_FENCE_START = r'^\[([a-zA-Z0-9_-]+)\]:' # For example [alberand]:

    def test(self, parent, block):
        return re.match(self.RE_FENCE_START, block)

    def run(self, parent, blocks):
        original_block = blocks[0]
        blocks[0] = re.sub(self.RE_FENCE_START, '', blocks[0])

        # Find block with ending fence
        for block_num, block in enumerate(blocks):
            # render fenced area inside a new div
            e = etree.SubElement(parent, 'div')
            e.set('style', 'display: inline-block; color: blue; border: 1px solid red;')
            self.parser.parseBlocks(e, blocks[0:block_num + 1])
            # remove used blocks
            for i in range(0, block_num + 1):
                blocks.pop(0)
            return True  # or could have had no return statement
        # No closing marker!  Restore and do nothing
        blocks[0] = original_block
        return False  # equivalent to our test() routine returning False
```

Next we need to create an Extension. This will be actually quite empty. Just
copy this one or if you use something different than `BlockProcessor` check
documentation for exact arguments. In this call the `register()` needs instances
of the processor, name of this new processor and priority (can stay 175).

```python
class AlberandTagsExtension(Extension):
    def extendMarkdown(self, md):
        md.parser.blockprocessors.register(Comments(md.parser), 'comments', 175)
```

The last step is to create our extension instance and let python-markdown lib
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

The other wish which I had was to make every image in my Blog clickable (opens
in a new tab). By default Pelican doesn't have such feature. It is easy
achievable with processors.

In the following implementation we initially parse markdown block to get
parameters such as text and link. Then, we create a `<div class="image-container">`,
inside this div we add link `<a>` and `<img>`. This way image is wrapped into
the link which opens this image. The `class` also allows to apply style on all
images in the article - for example center them.

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
it with our implementation.

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

class Comments(BlockProcessor):
    RE_FENCE_START = r'^\[([a-zA-Z0-9_-]+)\]:' # For example [alberand]:

    def test(self, parent, block):
        return re.match(self.RE_FENCE_START, block)

    def run(self, parent, blocks):
        original_block = blocks[0]
        blocks[0] = re.sub(self.RE_FENCE_START, '', blocks[0])

        # Find block with ending fence
        for block_num, block in enumerate(blocks):
            # render fenced area inside a new div
            e = etree.SubElement(parent, 'div')
            e.set('style', 'display: inline-block; color: blue; border: 1px solid red;')
            self.parser.parseBlocks(e, blocks[0:block_num + 1])
            # remove used blocks
            for i in range(0, block_num + 1):
                blocks.pop(0)
            return True  # or could have had no return statement
        # No closing marker!  Restore and do nothing
        blocks[0] = original_block
        return False  # equivalent to our test() routine returning False

class AlberandTagsExtension(Extension):
    def extendMarkdown(self, md):
        md.parser.blockprocessors.register(Comments(md.parser), 'comments', 175)

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
[7]:
