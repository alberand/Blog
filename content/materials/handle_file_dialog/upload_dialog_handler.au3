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
; 5. Selenium test runs compiled version of this script (script.exe). This
;    script specifies file and closes the dialog
; 6. Selenium test contunies
;
; Andrey Albershteyn <andrey.albershteyn@gmail.com>

; Name of uploading dialog
;WinActivate("File Upload") ; Mozilla Firefox
;WinActivate("Open") ; Google Chrome
WinActivate("Choose File to Upload") ; Internet Explorer

; Path to the file
send("C:\UserData\Andrew\Documents\42.txt")
Send("{ENTER}")
