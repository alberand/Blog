Title: Latex - Bootstrap-like code emphasizing
Date: 08.11.2016
Author: Andrew Albershtein
Status: published
tags: Latex, Bootstrap, code snippet
slug: latex-bootstrap-code
lang: en

Do you like those little highlighting for commands, files, codes and other stuff 
on sites with Bootstrap framework? I think it's really good for emphasizing key 
points in your text (for tech stuff).

![Screenshot of some pdf document with Bootstrap
highlighting]({filename}/images/latex_pdf_bcode_example.png)

In latex you are usually using bold or italic text styling. Those two methods
attract less attention than Bootstrap highlighting. Try to look at some article
while scrolling, you will see that you will immediately see those red boxes.

I wrote a function for Latex, which implements this type of highlighting. All you
need to do is just add following code to your Latex document.

```tex
% Include package for drawing color boxes
\usepackage{tcolorbox}

% Define colors
\definecolor{codeBg}{rgb}{0.976, 0.949, 0.956}
\definecolor{codeColor}{rgb}{0.780, 0.145, 0.305}

% Define new command
\newtcbox{\bCode}{
    nobeforeafter,
    fontupper=\color{codeColor},
    colframe=codeBg,
    colback=codeBg,
    boxrule=0.1pt,
    arc=3pt,
    boxsep=0pt,
    left=3pt,
    right=3pt,
    top=3pt,
    bottom=4pt,
    tcbox raise base}
```

Depending on your document settings, sometimes, you will need to change paddings 
of the box (left/right/top/bottom) to make it symmetric.

This function can be easily used by `\bCode{your code}` command.

#### References: ####

- [Bootstrap?](http://getbootstrap.com/)
- [Latex?](https://www.latex-project.org/)


