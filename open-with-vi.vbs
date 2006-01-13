' $Id$
Set WshShell = WScript.CreateObject("WScript.Shell")

if WScript.Arguments.Count <> 1 then
	WScript.Echo "Usage: test.vbs <argument>"
	WScript.Quit 1
end if

WshShell.CurrentDirectory = "C:\cygwin\bin"
WshShell.Run("C:\cygwin\usr\X11R6\bin\run.exe /bin/bash /home/ach/bin/cygterm vi """ & WScript.Arguments.Item(0) & """")
