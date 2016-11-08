Title: Latex - Bootstrap-like code emphasizing
Date: 08.11.2016
Author: Andrew Albershteyn
Status: published

SCREENSHOT

Do you like those little higlightning of some commands, files, codes on sites
which are using Bootstrap? I like it a lot. It's really good for emphasazing key 
points in your text (I mean only tech stuff).

In latex often you are using bold text. But those ones I think is attracte more
attention and you can find required information more quicker.

So, I write function which implement this type of highlitning for latex
documents.

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

Sometimes you need to change paddings of the border to do it symmetric. It can
be easily used by `\bCode{your code}` command. Of course you can change theme a
little bit, but I no a designer so I use colors from Bootstrap.

#### References: ####

- [Bootstrap?](http://getbootstrap.com/)
- [Latex?](https://www.latex-project.org/)


