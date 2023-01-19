Function Create-VM {
    param(
        [string]$csvFile = "C:\VMs\VMs.csv",
        [string]$WIMfile = "C:\VMs\install.wim",
        [string]$autounattend = "C:\VMs\autounattend.xml"
    )
    # Check if the Hyper-V module is installed
    if (!(Get-Module -Name Hyper-V -ListAvailable)) {
        # If not, prompt to install the Hyper-V feature
        $installHyperV = Read-Host "The Hyper-V module is not installed. Do you want to install it now (Y/N)?"
        if ($installHyperV -eq "Y") {
            # Install the Hyper-V feature
            Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
            Import-Module Hyper-V
        } else {
            # Exit the script if the user does not want to install the Hyper-V feature
            Write-Host "The Hyper-V module is required to run this script. Exiting..."
            exit
        }
    }
    # Check if the WindowsImageTools module is installed
    if (!(Get-Module -Name WindowsImageTools -ListAvailable)) {
        # If not, prompt to install the WindowsImageTools module
        $installWindowsImageTools = Read-Host "The WindowsImageTools module is not installed. Do you want to install it now (Y/N)?"
        if ($installWindowsImageTools -eq "Y") {
            # Install the WindowsImageTools module
            Install-Module -Name WindowsImageTools
            Import-Module WindowsImageTools
        } else {
            # Exit the script if the user does not want to install the WindowsImageTools module
            Write-Host "The WindowsImageTools module is required to run this script. Exiting..."
            exit
        }
    }
    # Import the CSV file and loop through each VM
    Import-Csv $csvFile | ForEach-Object {
        # Store the VM information in variables
        $vmName = $_.Name
        $vhdPath = $_.VHDPath
        $memoryStartup = [int64]$_.MemoryStartup.Replace('GB','') * 1GB
        $index = $_.Index
        $Size = [int64]$_.Size.Replace('GB','') * 1GB
        $DiskLayout = $_.DiskLayout
        $switchName = $_.SwitchName
        $generation = $_.Generation
        mkdir $vhdPath\$vmName
        # Create the new VHDX file and integrate the autounattend file
        Convert-Wim2VHD -Path "$vhdPath\$vmName\$vmName.vhdx" -SourcePath $WIMfile -index $index -Size $Size -DiskLayout $DiskLayout -Dynamic -Unattend $autounattend -Verbose -Force -NoRecoveryTools
        # Create the new VM and configure it
        New-VM -Name $vmName -Path $vhdPath -VHDPath "$vhdPath\$vmName\$vmName.vhdx" -MemoryStartupBytes $memoryStartup -SwitchName $switchName -Generation $generation
        # Start the VM and open the VM connection
        Start-VM -Name $vmName
        vmconnect.exe localhost $vmName
    }
}

# Create-VM -csvFile "C:\MyVMs.csv" -WIMfile "C:\Windows\sources\install.wim" -autounattend "C:\unattend.xml"
# or Create-VM