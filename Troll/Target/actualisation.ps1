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
