Title: Octave - colored prompt messages
Date: 24.10.2016
Author: Andrew Albershteyn
Status: published

<!-- 
Maybe it's too much unnecessary text for such small note. There is need to be
more concrete and write only technical stuff. Nobody is intrested in reading
about me
-->

Screenshot
Intro.
In Unix terminal we can use colorful output for emphasazing important
information. I'm currently studing in the Unversity and have a lot of task to
solve using Octave. Its prompt is similar to classic Unix terminal, so I decided
to try implement colored output information messages for my scripts.

In the beggining of the article you can see screenshot of messages
that I write for myself to make output of my scripts a little bit fancier.

Let's look at them closer. Every function is consist only of fprintf function
which draw sent text to the standard output (first argument is the output
stream). In those functions we create construction where message text is wrap by
special symbols which tells prompt to display this text with some styling as
color, underline, background color etc.

```matlab
% The set of function to print fancy messages in octave prompt. To use it just 
% call function name and as argument send a message you want to show.

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

% To test it use the next commands:
% infom("Information message"); error("Error message"); 
% success("Success message"); head("This is head message");

```

You can change color of message by changing only one number in this contruction:

<!-- 
# IMAGE Showing which number user should change
-->

Codes of those colors you can find in the next table or google it for "bash
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
<div class="divTableCell">Default foreground color</div>
<div class="divTableCell">Default</div>
</div>
<div class="divTableRow">
<div class="divTableCell">30</div>
<div class="divTableCell">Black</div>
<div class="divTableCell">Black</div>
</div>
<div class="divTableRow">
<div class="divTableCell">31</div>
<div class="divTableCell">Red</div>
<div class="divTableCell">Red</div>
</div>
<div class="divTableRow">
<div class="divTableCell">32</div>
<div class="divTableCell">Green</div>
<div class="divTableCell">Green</div>
</div>
<div class="divTableRow">
<div class="divTableCell">33</div>
<div class="divTableCell">Yellow</div>
<div class="divTableCell">Yellow</div>
</div>
<div class="divTableRow">
<div class="divTableCell">34</div>
<div class="divTableCell">Blue</div>
<div class="divTableCell">Blue</div>
</div>
<div class="divTableRow">
<div class="divTableCell">35</div>
<div class="divTableCell">Magenta</div>
<div class="divTableCell">Magenta</div>
</div>
<div class="divTableRow">
<div class="divTableCell">36</div>
<div class="divTableCell">Cyan</div>
<div class="divTableCell">Cyan</div>
</div>
<div class="divTableRow">
<div class="divTableCell">37</div>
<div class="divTableCell">Light Gray</div>
<div class="divTableCell">Light Gray</div>
</div>
<div class="divTableRow">
<div class="divTableCell">90</div>
<div class="divTableCell">Dark Gray</div>
<div class="divTableCell">Dark Gray</div>
</div>
<div class="divTableRow">
<div class="divTableCell">91</div>
<div class="divTableCell">Light Red</div>
<div class="divTableCell">Light Red</div>
</div>
<div class="divTableRow">
<div class="divTableCell">92</div>
<div class="divTableCell">Light Green</div>
<div class="divTableCell">Light Green</div>
</div>
<div class="divTableRow">
<div class="divTableCell">93</div>
<div class="divTableCell">Light Yellow</div>
<div class="divTableCell">Light Yellow</div>
</div>
<div class="divTableRow">
<div class="divTableCell">94</div>
<div class="divTableCell">Light Blue</div>
<div class="divTableCell">Light Blue</div>
</div>
<div class="divTableRow">
<div class="divTableCell">95</div>
<div class="divTableCell">Light Magenta</div>
<div class="divTableCell">Light Magenta</div>
</div>
<div class="divTableRow">
<div class="divTableCell">96</div>
<div class="divTableCell">Light Cyan</div>
<div class="divTableCell">Light Cyan</div>
</div>
<div class="divTableRow">
<div class="divTableCell">97</div>
<div class="divTableCell">White</div>
<div class="divTableCell">White</div>
</div>
</div>
</div>

How to use it? It's easy enough, all you need to do are few follow steps:

1. Download the script
2. Create some catalog where you will store this script for further usage
3. Than in your Octave's config (by default it should be `~/.octaverc`) add
and also don't forgot to change next commands:

```bash
# Change to address for your catalog
addpath("/home/andrew/Documents/Octave/")
messages
PAGER_FLAGS("-r")
```

First line adds your catalog to global search. So when you want to run
this script you can just type in the prompt `messages` and this script will run.
Second line runs this script. Because this configuration file (`.octaverc`) is 
run at the startup of the Octave this script will be automaticly executed.
Last command add parameter to `less` program which is used when output of your
code isn't suitable for one screen of the display. This parameter needed to
correctly display colors while you see output over the less program.

That all! Now you can use this function to get fancy output. For example:

<!-- 
# IMAGE Image with commands and corresponding messages.
-->

#### References: ####

- [Octave Documentation](https://www.gnu.org/software/octave/doc/v4.0.0/index.html)
- [Bash colors and
  formatting](http://misc.flogisoft.com/bash/tip_colors_and_formatting)


