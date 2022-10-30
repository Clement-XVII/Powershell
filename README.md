# Powershell

Here are several powershell scripts. MyModule and PSModule group these scripts together.
They can be installed with the command
```pwsh
Copy-Item "Location-Of-Module\PSModule\*" -Destination 'C:\Program Files\WindowsPowerShell\Modules\PSModule' -Recurse -Force
Import-Module PSModule -Verbose -Force
```
