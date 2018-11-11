:: This script is used to disable network `interface`. By doing this we can
:: simulate network disconnection. This script can be used to Enable or Disable
:: network interface
::
:: Before running it specify name of your interface. The name can be found at:
::      Control Panel -> Network and Sharing Center -> Change adapter settings
::
:: Note: This script requires administrator privileges. One of the way to run it
:: from the windows command prompt (or python script) is to create a windows
:: task with highest privileges. Then the task can be used to execute this
:: script.
::
:: Task Creation:
:: 0. Set correct name of your Ethernet interface (lower in this script)
:: 1. Open "Task Scheduler"
:: 2. Click "Create Task"
:: 3. Set name of the task to "toggle_connection"
:: 4. Check checkbox "Run with highest privileges"
:: 5. Go to "Triggers" tab and create trigger "At task creation/modification"
:: 6. Go to "Actions" tab and create action "Start a program" with link to this
::    script
::
:: Command to run task is: schtasks /Run /TN toggle_connection 
::
:: Andrey Albershteyn <andrey.albershteyn@gmail.com>

SET interface="Ethernet"

netsh interface show interface name=%interface% | findstr /R /C:"Administrative state:" | findstr /C:"Enabled"

if %errorlevel%==1 (
    echo Disabled
    netsh interface set interface name=%interface% admin=Enabled
) else (
    echo Enabled
    netsh interface set interface name=%interface% admin=Disabled
)
