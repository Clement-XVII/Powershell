
Function Start-AllSession()
{
    Param(
        [Parameter(Mandatory = $true)] 
        [string]$Username,
        [string]$CSV
    )
    
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