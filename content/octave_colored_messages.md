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
I always like to see readable and clear output of my scripts. With appropriate
formatting and fancy colors. It's take some time to write all this unnecessary
stuff but in result you get metal satisfaction of seeing that your script is not
only working but also you can show it somebody and it will look decent.

Currently I'm studing at University and get a lot of engeeniring problems to
solve. Even that I have free Matlab licence it's not an option for me. I trying
to be in open-source community. So I'm using Octave

Octave's prompt is similar to a classic unix terminal. So, we want to get
colored output and if unix can do it so Octave prompt is also.

In the beggining of the article you can see screenshot of information messages
that I write for myself to make output of my scripts a little bit fancier.

Let's look at them closer. Every function is consist only of fprintf function
which draw sent text to the standard output (first argument is the output
stream). In this function we create construction where message text is wrap by
special symbols which tells prompt to display this text with some styling as
color, underline, background color etc.

```matlab
% The set of function to print fancy messages in octave promt. To use it just 
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

% Trying to change warning color, but for now fail
function warn(varargin)
    
    fprintf(2, [char(27), ...
        '[93m']);
    warning(varargin);
    fprintf(2, [char(27), ...
        '[0m\n']
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

<!-- 
# TABLE Table with colors codes
-->

How to use it? It's easy enough, all you need to do is follow next steps:

1. Download the script
2. Create some catalog where you will store this script for further usage
3. Than in your Octave's config (by default it should be ~/.octaverc) add
and also don't forgot to change next commands:

```
# Change to address for your catalog
addpath("/home/andrew/Documents/Octave/")
messages
PAGER_FLAGS("-r")
```

First line adds your catalog to global search. So when you want to run
this script you can just type in the prompt "messages" and this script will run.
Second line run this script. Because this configuration file (.octaverc) is run
at the startup of the Octave this script will be automaticly executed.
Last command add parameter to "less" program which is used when output of you
code isn't suitable for one screen of the display. This parameter just needed to
correctly display colors while you see output over the less program

That all! Now you can use this function to get fancy output. For example:

<!-- 
# IMAGE Image with commands and corresponding messages.
-->

This is bash terminal we can use here bash rules.

Some explanation of code.

Table of colors

Add to .octaverc:

 - Path to your files
 - Running of your script
 - more off if you would like
 - Or PAGER_FLAGS("-r") to set argument to 'less' command

Some examples of cool prompts and messages

#### References: ####

- [Octave Documentation](https://www.gnu.org/software/octave/doc/v4.0.0/index.html)
- [Bash colors and
  formatting](http://misc.flogisoft.com/bash/tip_colors_and_formatting)


