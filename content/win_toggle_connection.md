Title: Disconnect Windows from the internet
Date: 10.11.2018
Modified: 10.11.2018
Category: scripts
Status: published
Tags: Windows, networking
Slug: toggle-network-on-windows
Authors: Andrey Albershtein
Summary: Enable/Disable internet connection on Windows
lang: en

One time I was testing a JavaScript application with an offline mode. That
application was running in browser and was communicating with a server. 

I wanted to test it in offline mode. By that I mean loading an application and
imitating network break down. In the Google Chrome you can do it easily
from Developer console. However, in Mozilla Firefox and Internet Explorer it is
much harder; at least I didn't find a functionality for this. Moreover, as I
use it in Selenium tests I wanted a solution which is browser independent and
can be fully automatic.

I decide to disable internet connection on the level of the operating system
(Windows) as it definitely would work for everything. The most straightforward
way is to just disable network interface. But, I find out that it requires
administrator privileges which aren't granted when you run it from other program
without privileges. And, of course, it's not a good idea to run your tests as an
administrator.

##### Solution

In Windows you can create system task which in turn runs script to disable
network. As this script is run by system task it has all required privileges.

```
SET interface="Ethernet"

netsh interface show interface name=%interface% | findstr ^
    /R /C:"Administrative state:" | findstr /C:"Enabled"

if %errorlevel%==1 (
    echo Disabled
    netsh interface set interface name=%interface% admin=Enabled
) else (
    echo Enabled
    netsh interface set interface name=%interface% admin=Disabled
)
```

Put it somewhere near your tests and set it up as follows:

0. Set correct name of your Ethernet interface (in script)
1. Open "Task Scheduler"
2. Click "Create Task"
3. Set name of the task to "toggle_connection"
4. Check checkbox "Run with highest privileges"
5. Go to "Triggers" tab and create trigger "At task creation/modification"
6. Go to "Actions" tab and create action "Start a program" with link to script

That's all! Now you can toggle your internet connection from Command prompt by
this command:

    schtasks /Run /TN toggle_connection

Now, you can run this as system command from your program (in my case it is
Python script) to toggle network connection.

<div style="width:300px; text-align:center; margin: 0 auto;">
<a href="{filename}/materials/win_toggle_connection.tar">Download scripts</a>
</div>

##### References

* [Selenium](https://www.seleniumhq.org/)
