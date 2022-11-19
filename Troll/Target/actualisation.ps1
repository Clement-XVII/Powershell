$CSV = "E:\test.csv"
$ListPCs = Get-Content $CSV -Encoding UTF8 | ConvertFrom-Csv -Delimiter ";" | select Machines, Noms, Ip

foreach ($UnPC in $ListPCs) {
    if ($UnPC -match "$Name") {
        $NomPC = $UnPC.Machines
        $NomUser = $UnPC.Noms
        $IP = $UnPC.Ip
        $NewIP = ((Test-Connection -ComputerName $NomPC -Count 1 -Delay 1).IPV4Address).IPAddressToString
        echo $NomPC, $NomUser, $IP, $NewIP
        $ListPCs | foreach
        {
            if($_.Noms -eq "$NomUser")
            {
                $_.Ip = "$NewIP"
            }
        }
    }
}

$ListPCs | export-csv $CSV -Delimiter ";" -NoTypeInformation


#Get-NetAdapter -Name * | Enable-NetAdapter -Confirm:$false
Function Disable-Network {
$localIpAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.DefaultIPGateway -ne $null}).IPAddress | select-object -first 1;
$iface = Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress, ifIndex;
$iface | foreach{if($_.IPAddress -eq $localIpAddress){$test = $_.IfIndex;echo $_.IPAddress;Get-NetAdapter -ifIndex $test | Disable-NetAdapter -Confirm:$false}}
}

Function Enable-Network{
    Get-NetAdapter -ifIndex $test | Enable-NetAdapter -Confirm:$false
}
