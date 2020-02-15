Title: Latex - Выделение в стиле Bootstrap
Date: 08.11.2016
Author: Aндрей Альберштейн
Status: published
tags: Latex, Bootstrap, code snippet
slug: latex-bootstrap-code
lang: ru

Если вам как и мне нравится эта красивая Bootstrap подсветка команд, файлов,
кода, да чего угодно то это довольно легко можно реализовать для документов
написанных с помощью Latex. Как по мне это куда более контрастное выделение
информации нежели с помощью курсива или жирного шрифта.

![Screenshot of some pdf document with Bootstrap
highlighting]({static}/images/latex_pdf_bcode_example.png)

Я написал функцию для Latex, которая предоставляет подобную подсветку. Её очень
легко использовать, единственное что нужно это добавить следующий кусок кода в
свой документ:

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

В зависимости от параметров вашего документа цветная обводка может быть
чуть-чуть не симметрична с одной из сторон. Но это легко можно подкорректировать с
помощью параметров `left`, `right`, `top` и `bottom`.

Выделить текст можно следующим образом `\bCode{ваш код\текст}`.

#### Источники: ####

- [Bootstrap?](http://getbootstrap.com/)
- [Latex?](https://www.latex-project.org/)


