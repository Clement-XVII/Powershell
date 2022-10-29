Function Start-Session()
{
    Param(
        [Parameter(Mandatory = $true)] 
        [string]$Username,
        [string]$CSV,
        [Parameter(Mandatory = $false)] 
        [string]$Name
    )
    if ($PSBoundParameters.Keys.Contains("Name")){
        $ListPCs = Get-Content $CSV -Encoding UTF8 | ConvertFrom-Csv -Delimiter ";" | select Machines, Users
        $Password = Read-Host "Enter Password" -AsSecureString
        $mdp = ConvertFrom-SecureString -SecureString $Password

        foreach ($UnPC in $ListPCs) {
            if ($UnPC -match "$Name") {
                $NomPC = $UnPC.Machines
                $NomUser = $UnPC.Users
                $login = "$NomPC\$Username"
                $mycreds = New-Object System.Management.Automation.PSCredential($login, ($mdp | ConvertTo-SecureString))
                $Session = New-PSSession -ComputerName $NomPC -Name $NomUser -Credential $mycreds
            }
        }
    }
    else {
        $ListPCs = Get-Content $CSV -Encoding UTF8 | ConvertFrom-Csv -Delimiter ";" | select Machines
        $Password = Read-Host "Enter Password" -AsSecureString
        $mdp = ConvertFrom-SecureString -SecureString $Password
        foreach ($UnPC in $ListPCs) {
            $NomPC = $UnPC.Machines
            $NomUser = $UnPC.Users
            $login = "$NomPC\$Username"
            $mycreds = New-Object System.Management.Automation.PSCredential($login, ($mdp | ConvertTo-SecureString))
            $Session = New-PSSession -ComputerName $NomPC -Name $NomUser -Credential $mycreds
        }
    }
}