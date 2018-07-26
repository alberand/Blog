Title: Test some Pelican functionality
Date: 22.07.2016
Author: Andrew Albershteyn
Status: published

Let's test some links. [This is link to first post]({filename}Life/first_post.md).

[Another link to contact page]({filename}pages/contact.md)

Let's link to my backalor thesis [PDF]({filename}/pdfs/BP_Albershteyn_2016.pdf)

Now let's try to insert some image: ![PI]({filename}/images/pi.jpg)

There are two ways to specify the identifier:

    :::python
    print("The triple-colon syntax will *not* show line numbers.")

To display line numbers, use a path-less shebang instead of colons:

    #!python
    print("The path-less shebang syntax *will* show line numbers.")

And now let's test some Latex formula:
$$\dfrac{exp(3)sin(3\pi)}{34\dot cos(34)}$$

<p style="text-align:center">
<iframe width="560" height="315" src="https://www.youtube.com/embed/H5NqIsnyTG8" frameborder="0" allowfullscreen></iframe>
</p>

Testing new git submodule setup
