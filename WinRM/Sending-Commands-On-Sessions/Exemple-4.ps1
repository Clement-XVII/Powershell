Function Eject-ALLCD()
{
    $Session = Get-PSSession
    Write-Host "CDRom                       5`nFixed(External/Fixed Disk)  3`nNetwork                     4`nNoRootDirectory             1`nRam                         6`nRemovable(USB Drive)        2`nUnknown                     0`n"
    $type = Read-Host -Prompt "Enter the Drive Type"
    
    Invoke-Command -Session $Session -ScriptBlock {
        $lettre = Get-WmiObject -Class Win32_logicaldisk | Where { $_.DriveType -eq "$Using:type" } | ForEach-Object {$_.DeviceID}
        foreach ($UnPC in $lettre) {
            (new-object -COM Shell.Application).NameSpace(17).ParseName("$UnPC").InvokeVerb("Eject")
        }
    }
}