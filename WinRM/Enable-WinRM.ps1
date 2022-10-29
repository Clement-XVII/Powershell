Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;


#Active WinRM
Enable-PSRemoting -SkipNetworkProfileCheck –force
Set-Service WinRM -StartMode Automatic
Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}
#Trustedhosts you can enter your IP 
Set-Item WSMan:localhost\client\trustedhosts -value * -force

Get-Item WSMan:\localhost\Client\TrustedHosts