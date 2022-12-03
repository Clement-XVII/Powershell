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
## Send-Commands
## Send-Script
## Add-Music
## Add-Play-Music
## Play-Music
## Eject-ALLCD
## Wol
## Start-Process-Active
## Open-Apps
