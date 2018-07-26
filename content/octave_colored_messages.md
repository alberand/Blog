Title: Octave - colored prompt messages
Date: 24.10.2016
Author: Andrew Albershteyn
Status: published
Tags: Octave, colored messages, colored prompt

![Octave Prompt Colored Messages]({filename}/images/octave_messages.png)

In Unix terminal we can use colorful output for emphasizing important
information. I'm currently studying at University and have a lot of problems to
solve using Octave. Its prompt is similar to classic Unix terminal. To make
output more readable I tried to implement information colored messages for my 
scripts.

In the beginning of the article you can see screenshot of messages
that I write for myself to make output of my scripts a little bit fancier.

Function are consist of **fprintf** function which draw obtained text to the 
standard output (first argument is the output stream). Second argument is  
specific construction where message text is wrapped by special symbols. Those 
symbols tells prompt to display text with some styling such as color, 
underline, background color etc.

```matlab
% The set of function to print fancy messages in octave prompt. To use it just 
% call function name and as argument send a message you want to show.
% To test it use following commands:
% infom("Information message"); error("Error message"); 
% success("Success message"); head("This is head message");

% Prevent octave to run it immediately.
1;

function infom(msg)
    fprintf(1, [char(27), ...
        '[94m' msg, ...
        char(27), ...
        '[0m\n']
    );
endfunction

function error(msg)
    fprintf(1, [char(27), ...
        '[91m' msg, ...
        char(27), ...
        '[0m\n']
    );
endfunction

function success(msg)
    fprintf(1, [char(27), ...
        '[32m' msg, ...
        char(27), ...
        '[0m\n']
    );
endfunction

function head(msg)
    fprintf(1, 
        [char(27), ...
        '[90m', ...
        '==============================================================', ...
        '========\n', ...
        msg '\n', ...
        '==============================================================', ...
        '========\n',...
        char(27), ...
        '[0m']
    );
endfunction
```

Background and foreground colors can be changed in construction shown below. It
is consist of escape character `^` (or `\e`, `\033`, `\x1B`) and format
code surrounded by **[** and **m** characters. First number is responsible for 
text formatting (normal, bold, dim, underlined...), second for background color
 and third one for foreground color. 

<div style="width: 150px; margin: 0 auto; font-size: 22px; padding: 0px 0px 5px
0px; letter-spacing: 2px;">
    ^[0;49;30m
</div>

Codes of those colors can be found in the next table or google it for "bash
terminal colors".

<style>
/* DivTable.com */
.divTable{
    display: table;
    margin: 0 auto;
    border-top: 1px #DEDEDE solid;
    border-bottom: 1px #DEDEDE solid;
    margin-top: 10px;
    margin-bottom: 10px;
}

.divTableRow {
    display: table-row;
}
.divTableHeading {
    display: table-header-group;
    background-color: #EEE;
    font-weight: bold;
}

.divTableCell, .divTableHead {
    display: table-cell;
    padding: 3px 10px;
}

.divTableHead {
    border-bottom: 1px #DEDEDE solid
}

.divTableBody {
    display: table-row-group;
};
</style>

<div class="divTable">
<div class="divTableBody">
<div class="divTableRow">
<div class="divTableHead">Code</div>
<div class="divTableHead">Color</div>
<div class="divTableHead">Preview</div>
</div>
<div class="divTableRow">
<div class="divTableCell">39</div>
<div class="divTableCell">Default</div>
<div class="divTableCell">
  <img src="./images/bash_colors/39.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">30</div>
<div class="divTableCell">Black</div>
<div class="divTableCell">
  <img src="./images/bash_colors/30.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">31</div>
<div class="divTableCell">Red</div>
<div class="divTableCell">
  <img src="./images/bash_colors/31.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">32</div>
<div class="divTableCell">Green</div>
<div class="divTableCell">
  <img src="./images/bash_colors/32.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">33</div>
<div class="divTableCell">Yellow</div>
<div class="divTableCell">
  <img src="./images/bash_colors/33.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">34</div>
<div class="divTableCell">Blue</div>
<div class="divTableCell">
  <img src="./images/bash_colors/34.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">35</div>
<div class="divTableCell">Magenta</div>
<div class="divTableCell">
  <img src="./images/bash_colors/35.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">36</div>
<div class="divTableCell">Cyan</div>
<div class="divTableCell">
  <img src="./images/bash_colors/36.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">37</div>
<div class="divTableCell">Light Gray</div>
<div class="divTableCell">
  <img src="./images/bash_colors/37.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">90</div>
<div class="divTableCell">Dark Gray</div>
<div class="divTableCell">
  <img src="./images/bash_colors/90.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">91</div>
<div class="divTableCell">Light Red</div>
<div class="divTableCell">
  <img src="./images/bash_colors/91.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">92</div>
<div class="divTableCell">Light Green</div>
<div class="divTableCell">
  <img src="./images/bash_colors/92.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">93</div>
<div class="divTableCell">Light Yellow</div>
<div class="divTableCell">
  <img src="./images/bash_colors/93.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">94</div>
<div class="divTableCell">Light Blue</div>
<div class="divTableCell">
  <img src="./images/bash_colors/94.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">95</div>
<div class="divTableCell">Light Magenta</div>
<div class="divTableCell">
  <img src="./images/bash_colors/95.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">96</div>
<div class="divTableCell">Light Cyan</div>
<div class="divTableCell">
  <img src="./images/bash_colors/96.png" />
</div>
</div>
<div class="divTableRow">
<div class="divTableCell">97</div>
<div class="divTableCell">White</div>
<div class="divTableCell">
  <img src="./images/bash_colors/97.png" />
</div>
</div>
</div>
</div>

How to use it? It's easy enough, all you need to do are few follow steps:

1. Download the script
2. Create catalog where you will store this script for further usage
3. Than in your Octave's config (by default it should be `~/.octaverc`) add
and don't forgot to change next commands:

```bash
# Change to address where your script is
addpath("/home/andrew/Documents/Octave/")
messages
PAGER_FLAGS("-r")
```

First line adds your catalog to global search. So when you want to run
this script you can just type in the Octave prompt `messages` and this script 
will be run.
Second line runs this script. Because this configuration file (`.octaverc`) is 
run at the startup of the Octave this script will be automatically executed.
Last command add parameter to `less` program which is used when output of your
code isn't suitable for one screen of the display. This parameter needed to
correctly display colors while you see output over the less program.

#### References: ####

- [Octave Documentation](https://www.gnu.org/software/octave/doc/v4.0.0/index.html)
- [Bash colors and
  formatting](http://misc.flogisoft.com/bash/tip_colors_and_formatting)


