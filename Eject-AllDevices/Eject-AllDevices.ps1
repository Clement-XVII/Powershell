Function Eject-ALLDevices()
{
    $lettre = Get-WmiObject -Class Win32_logicaldisk | Where { $_.DriveType -eq "5" } | ForEach-Object {$_.DeviceID}
    $nombre = $lettre.count
    foreach ($UnPC in $lettre) {
        (new-object -COM Shell.Application).NameSpace(17).ParseName("$UnPC").InvokeVerb("Eject")
        }
}