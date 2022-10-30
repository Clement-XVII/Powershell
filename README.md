# Powershell

Here are several powershell scripts. MyModule and PSModule group these scripts together.
They can be installed with the command
```pwsh
Copy-Item "Location-Of-Module\PSModule\*" -Destination 'C:\Program Files\WindowsPowerShell\Modules\PSModule' -Recurse -Force
Import-Module PSModule -Verbose -Force
```
## Trolling coworkers

First of all, you need to know the password and user name of your computer. After that you have to install the PSModule on their computer (it is possible to do this with a rubber ducky and USB stick that retrieves the CSV file) then you have to arrange your CSV file in the following way.
```
Machines;Users
192.168.1.21;john
```
You must use the separator ";". After that you need to import MyModule. Then you just have to start all the Sessions in the CSV file with the command 
```
Start-Session -Username John -CSV "Location of CSV file
```
To start a single session
```
Start-Session -Username John -CSV "Location of CSV file" -Name john
```

Translated with www.DeepL.com/Translator (free version)
