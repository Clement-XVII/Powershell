# Commands
## Start-Session
To open a Session instantly use -Enter :
```pwsh
Start-Session -Enter -CSV "G:\list.csv" -Name Orion -Username orion
```

To start a Session just use -Name :
```pwsh
Start-Session -CSV "G:\list.csv" -Name Orion -Username orion
```

To open all sessions :
```pwsh
Start-Session -CSV "G:\list.csv" -Username orion
```
## Remove-Session
To close a session use -Name :
```pwsh
Remove-Session -Name Orion
```

To close all sessions use -All :
```pwsh
Remove-Session -All
```

## Send-Command
```pwsh
Send-Command
```

## Send-Commands
```pwsh
Send-Commands
```
## Send-Script
```pwsh
Send-Script
```
## Add-Music
```pwsh
Add-Music
```
## Add-Play-Music
```pwsh
Add-Play-Music
```
## Play-Music
```pwsh
Play-Music
```
## Eject-ALLCD
```pwsh
Eject-ALLCD
```
## Wol
```pwsh
Wol -MacAddress 12:34:56:78:9A:BC
```
## Start-Process-Active
To launch an application via PSSession by setting up a task. For this you can use the following command (the UserID is the account login) :
```pwsh
Start-Process-Active -Session $Session -Executable powershell.exe -Argument "start-process ipconfig" -WorkingDirectory "C:\" -UserID orion
```
You can also use this command to not add an argument :
```pwsh
Start-Process-Active -Session $Session -Executable powershell.exe -WorkingDirectory "C:\"  -UserID orion
```
