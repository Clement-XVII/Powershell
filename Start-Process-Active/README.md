```
$s = New-PSSession -ComputerName 192.168.1.34 -Credential orion
Start-Process-Active -Session $s -Executable notepad.exe -UserID orion -Argument "coucou" -WorkingDirectory %windir%
```
