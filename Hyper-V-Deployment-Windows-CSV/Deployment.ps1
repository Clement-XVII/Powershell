#Default value of the variables
$CSV = "G:\My PS Script\Hyper-V-Deployment-Windows-CSV\list.csv"
$Unattend = "G:\My PS Script\Hyper-V-Deployment-Windows-CSV\autounattend.xml"
$WIM = "D:\ISO\sources\install.wim"
$ListVMs = Import-Csv -Path $CSVfile -Delimiter ";"
$cheminvm='D:\VM\'
#$cheminiso= 'D:\ISO\SW_DVD9_Win_Pro_10_21H2_64BIT_French_Pro_Ent_EDU_N_MLF_X22-83630.ISO'



Write-Host "Creation of virtual machines `n" -ForegroundColor Green

#Verification of the presence of the Hyper-V module and suggestion of its installation
if (Get-Module -ListAvailable -Name Hyper-V) {
    Write-Host "Module Hyper-V exists " -ForegroundColor Green
} else {
    Write-Host "Module does not exist " -ForegroundColor Yellow
    $Confirmation = Read-Host -Prompt "Do you want to install the Hyper-V module ? `n  [Y] Yes [N] No"
    if ($Confirmation -ne 'N') {
	    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
	    Write-Host "Hyper-V installation finished!" -ForegroundColor Green
    }
}

#Verification of the presence of the WindowsImageTools module and suggestion of its installation
if (Get-Module -ListAvailable -Name WindowsImageTools) {
    Write-Host "Module WindowsImageTools exists `n " -ForegroundColor Green
} else {
    Write-Host "Module does not exist `n " -ForegroundColor Yellow
    $Confirmation = Read-Host -Prompt "Do you want to install the WindowsImageTools module ? [Y] Yes [N] No"
    if ($Confirmation -ne 'N') {
         Install-Module -Name WindowsImageTools -force
        Import-Module WindowsImageTools
        Write-Host "Installation of the WindowsImageTools module finished !" -ForegroundColor Green
    }
 
}

$CSVfile = Read-Host -Prompt "Enter the path of the CSV file ex: C:\test\T04.csv or press Enter for the default value ($CSV)"
    if (-not($CSVfile)) {
        $CSVfile = $CSV
        Write-Host "$CSVfile `n" -ForegroundColor Green
    }
    elseif ($CSVfile) {
        Write-Host "Configured path: $CSVfile `n" -ForegroundColor Green
    }

$Unattendfile = Read-Host -Prompt "Enter the path of the file Unattend.xml ex: C:\test\AutoUnattend.xml or press Enter for the default value ($Unattend)"
    if (-not($Unattendfile)) {
        $Unattendfile = $Unattend
        Write-Host "$Unattendfile `n" -ForegroundColor Green
    }
    elseif ($Unattendfile) {
        Write-Host "Configured path: $Unattendfile `n" -ForegroundColor Green
    }

$WIMfile = Read-Host -Prompt "Enter the path of the install.wim file ex: C:\test\install.wim or press Enter for the default value ($WIM)"
    if (-not($WIMfile)) {
        $WIMfile = $WIM
        Write-Host "$WIMfile `n" -ForegroundColor Green
    }
    elseif ($WIMfile) {
        Write-Host "Configured path: $WIMfile `n" -ForegroundColor Green
    }





foreach ($UneVM in $ListVMs)
{ 

    $NomVm = $UneVM.Machines
        
			if ((get-VMSwitch -Name 'Local Switch' -ErrorAction SilentlyContinue).count -EQ 0) {

			New-VMSwitch -Name 'Local Switch' -SwitchType Private;

	}

	mkdir $cheminvm\$NomVM
	Convert-Wim2VHD -Path "$cheminvm\$NomVm\$NomVm.vhdx" -SourcePath $WIMfile -index 3 -Size 40GB -DiskLayout UEFI -Dynamic -Unattend $Unattendfile -Verbose -Force -NoRecoveryTools

	New-VM -Name $NomVm -MemoryStartupBytes 4GB -SwitchName 'local switch' -Path $cheminvm -VHDPath "$cheminvm\$NomVm\$NomVm.vhdx" -Generation 2;
	Start-VM -Name $NomVm
	vmconnect.exe localhost $NomVm;

}
<#
function Get-SessionInstance() {
    Param(
        [Parameter(Mandatory = $false)] [int]$Timeout = 2
    )
    
    Write-Debug "Ouverture d'une session PowershellDirect. Timeout fixé à $Timeout minutes."
    if ((Get-PSSession -VMName $NomVM -Name 'Script').Length -lt 1) { 
        $username = "$NomVm\Utilisateur"
        $password = ConvertTo-SecureString "Admin123" -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential("$username", $password)
        $startTime = Get-Date
            do {
                $timeElapsed = $(Get-Date) - $startTime
                # TODO: Progress bar
                #Write-Progress -Activity “Ouverture d'une session PowershellDirect” -Status “Tentative de connexion” -PercentComplete ($($timeElapsed).TotalMinutes / $Timeout*100)
                if ($($timeElapsed).TotalMinutes -ge $Timeout) {
                    Write-Error "Could not connect to PS Direct after $Timeout minutes"
                    throw "Could not connect to PS Direct after $Timeout minutes"
                } 
                Start-Sleep -sec 1
                $Session = New-PSSession -ComputerName $NomVm -Credential $cred -Name "Script" -ErrorAction SilentlyContinue
            }
            until ($Session)
    }
    return $Session  
}
$Session2 = Get-SessionInstance -Timeout 15
# On créé le répertoire de travail  sur la VM s'il n'existe pas
Invoke-Command -Session $Session2 -ScriptBlock `
{ 
    ipconfig
}



Enter-PSSession -ComputerName BTS1 -Credential Utilisateur

BTS1 or IP (192.168.1.21)

Enter-PSSession -ComputerName 192.168.1.21 -Credential Utilisateur
#>