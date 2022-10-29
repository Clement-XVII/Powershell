Function Open-Session()
{
    Param(
        [Parameter(Mandatory = $true)] 
        [string]$Username,
        [string]$CSV,
        [string]$Name
    )
    
    $ListPCs = Get-Content $CSV -Encoding UTF8 | ConvertFrom-Csv -Delimiter ";" | select Machines, Users
    $Password = Read-Host "Enter Password" -AsSecureString
    $mdp = ConvertFrom-SecureString -SecureString $Password
    foreach ($UnPC in $ListPCs) {
        if ($UnPC -match "$Name") {
            echo $UnPC
            $NomPC = $UnPC.Machines
            $login = "$NomPC\$Username"
            $mycreds = New-Object System.Management.Automation.PSCredential($login, ($mdp | ConvertTo-SecureString))
            $Session = Enter-PSSession -ComputerName $NomPC -Credential $mycreds
        }
    }
}

<#
Function Start-Session()
{
    Param(
        [Parameter(Mandatory = $true)] 
        [string]$Username,
        [string]$CSV,
        [string]$Name
    )
    
    $ListPCs = Get-Content "G:\My PS Script\WinRM\list.csv" -Encoding UTF8 | ConvertFrom-Csv -Delimiter ";" | select Machines, Users
    $Password = Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File "$env:homepath\Password.txt" 
    $File = "$env:homepath\Password.txt" 
    #$mdp = ConvertTo-SecureString $Password -AsPlainText -Force | ConvertFrom-SecureString
    foreach ($UnPC in $ListPCs) {
        if ($UnPC -match "$Name") {
            echo $UnPC
            $NomPC = $UnPC.Machines
            $login = "$NomPC\$Username"
            $mycreds = New-Object System.Management.Automation.PSCredential($login, (Get-Content $File | ConvertTo-SecureString))
            $Session = Enter-PSSession -ComputerName $NomPC -Credential $mycreds
        }
    }
}
#>