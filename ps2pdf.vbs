Dim GSPATH
GSPATH = "C:\Program Files\gs\gs8.50"

Set WshShell = WScript.CreateObject("WScript.Shell")

if WScript.Arguments.Count <> 1 then
	WScript.Echo "Usage: ps2pdf.vbs <argument>"
	WScript.Quit 1
end if

WshShell.Environment.item("PATH") = WshShell.Environment.item("PATH") & _
	";" & GSPATH & "\bin"
WshShell.CurrentDirectory = GSPATH & "\lib"
WshShell.Run("ps2pdf.bat """ & WScript.Arguments.Item(0) & """")
