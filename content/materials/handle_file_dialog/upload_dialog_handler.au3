; It is 'AutoIt' script for handling file uploading dialog
;
; AutoIt can be downloaded from:
;   https://www.autoitscript.com/site/autoit/
;
; Use-case:
; 1. Selenium run some browser test
; 2. The test requires file uploading 
; 3. Selenium press 'Choose file' button which calls 'File Upload' dialog
; 4. It is operation system's dialog and can not be controled via Selenium 
;    (JavaScript)
; 5. Selenium test run compiled version of this script (script.exe). This
;    script specifies file and closes the dialog
; 6. Selenium test contunies
;
; Run:
;   handler.exe firefox "path/to/file/file.txt"
;
; Andrey Albershteyn <andrey.albershteyn@gmail.com>

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
