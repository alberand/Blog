Title: Handling file dialog in Selenium tests (Windows & Linux)
Date: 22.10.2018
Modified: 22.10.2018
Status: published
Tags: Selenium, testing, AutoIt, xdotool
Keywords: Selenium, testing, AutoIt, xdotool
Slug: selenium-file-dialog
Author: Andrey Albershtein
Summary: How to handle file dialog in any browser with Selenium framework.
Lang: en

Selenium is awesome automation tool for testing your website and simulating
user's actions. I used it for a few times and found one important feature which
is missing - as far as I know it is impossible to handle "Open File" or "Save
File" dialog:

<a href="{static}/images/firefox_file_upload_dialog_small.png">
	<img alt="Browser File Dialog" 
		src="{static}/images/firefox_file_upload_dialog_small.png" 
		width="90%" style="margin: 0 auto; display: block;">
</a>

Selenium uses JavaScript to simulate clicks, typing and many other manipulation
with a web-page. Unfortunately, when user clicks on the button to save a file
the browser opens an operating system's file dialog. This dialog is not part of
the site or even a browser. As JavaScript is "jailed" by the browser it can't
get access to the external window. There comes the problem. How a test can save
the file (press the save button)?

[TOC]

#### Existing Solutions

The first solution came to my mind was to get control over the HTML's `input`
tag and set path to the file as I want. When you choose a file the _value_
attribute changes to the address of the file. Unfortunately (or not), we can't
just change this attribute from JavaScript. It's forbidden due to security
reasons. If it were possible sites could steal user's private data by setting the
attribute to some sensitive files (for example, passwords, logs). So, it is not
the way. 

The other way around is to use some UI automation tool, in addition to Selenium.
There are some approaches with [pywuiauto][1] but this library is Windows
specific.

Then I turned to Sikuli - quite a nice library for automation of graphical
interfaces. Its main advantage is that it use image processing to find similar
elements (you need to defined via prepared screenshots of the elements). However,
Sikuli is quite big and has its own Pythonic language with dedicated IDE. That's
too complex solution for such a simple task.

#### Windows Solution - AutoIt

After some further search I came across AutoIt - also an automation tool for
graphical user interfaces. What catch my attention was that scripts written for
AutoIt could be simply compiled into standalone executables. That's super
convenient! In result all you get in addition to your test is a `.exe` file. The
following listing shows my script for handling file dialog for the most
popular browsers:

```
...
#include <MsgBoxConstants.au3>

If $CmdLine[1] == "chrome" Then
    $sTitle = "Open"
ElseIf $CmdLine[1] == "edge" Then
    $sTitle = "Open"
ElseIf $CmdLine[1] == "firefox" Then
    $sTitle = "File Upload"
ElseIf $CmdLine[1] == "ie" Then
    $sTitle = "Choose File to Upload"
Else 
    MsgBox($MB_SYSTEMMODAL, "", "Unknown browser")
    Exit
EndIf

; Find window
WinActivate($sTitle) 

; Path to the file
Send("{ALTDOWN}n{ALTUP}")
send($CmdLine[2])
Send("{ALTDOWN}O{ALTUP}")
```

Run it with two arguments: `handler.exe firefox C:/path/to/file.txt`

#### Linux Solution - xdotool

For Linux there exist a tool called __xdotool__. It is similar to AutoIt but it
only simulate keyboard input, mouse movements and windows manipulation.
However, it is enough to open a file. The following script looks for open file
dialog for Firefox or Chromium browser, switches to that window, types path to
the file and press "Open" button (can be done by a shortcut: ALT+O). 

```
...

file="/home/andrew/42.png"

browser="firefox"
# browser="chromium"

if [ "$browser" = "firefox" ]; then
    win_name="File Upload"
fi

if [ "$browser" = "chromium" ]; then
    win_name="Open File"
fi

echo "Looking for the window of the '$browser' browser with name '$win_name'"

# Find window PID
WIN=$(for pid in $(xdotool search --class "$browser"); do \
    if [[ $(xdotool getwindowname $pid) == "$win_name" ]]; \
    then echo $pid; fi; done)

# Switch to the window
xdotool windowactivate $WIN

# Send file path
xdotool type --window $WIN "$file"

# Press "Open" button
xdotool key --window $WIN alt+o
```

These are the most elegant solution which I found. Even though it need
additional software it showed itself as simple and reliable way to approach file
dialogs. All the script can be downloaded from the following link:

<div style="width:300px; text-align:center; margin: 0 auto;">
<a href="{static}/materials/handle_file_dialog.tar">Download scripts</a>
</div>

##### References

* [xdotool webpage](https://www.semicomplete.com/projects/xdotool/)
* [AutoIt website](https://www.autoitscript.com/site/autoit/)
* [Selenium website](https://www.seleniumhq.org/)

[1]: https://github.com/pywinauto/pywinauto

<style>
    h5 {
        font-weight: bold;
    }
</style>
