#It is possible to have two variables Password and username in order to avoid asking for the password and username every time
#$Username = "Admin"
#$Password = "Admin123"

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

Function Remove-Session()
{
    Param(
        [Parameter(Mandatory = $false)] 
        [string]$Name,
        [switch]$All
    )
    if ($PSBoundParameters.Keys.Contains("Name")){
        Remove-PSSession -Name $Name
    }
    elseif ($PSBoundParameters.Keys.Contains("All")){
        $s = Get-PSSession
        Remove-PSSession -Session $s
    }
    else {
    Get-PSSession
    $Name = Read-Host -Prompt "Enter the name of Session"
    Remove-PSSession -Name $Name
    }
}

Function Send-Command()
{
    $Session = Get-PSSession
    $command = Read-Host -Prompt "Enter command to run"
    Invoke-Command -Session $Session -ScriptBlock {
       powershell.exe $Using:command
    }
}

Function Send-Commands()
{
    while($true){
        $Session = Get-PSSession
        $command = Read-Host -Prompt "Enter command to run"
        Invoke-Command -Session $Session -ScriptBlock {
        powershell.exe $Using:command
        }
    }
}

Function Send-Script()
{
    $Session = Get-PSSession
    $MyScript = Read-Host -Prompt "Enter the path of the script file ex: C:\test\script.ps1"
    Invoke-Command -FilePath $MyScript -Session $Session
}

Function Add-Music()
{
    $Session = Get-PSSession
    $cheminaudio = "C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\"

    $audio = Read-Host -Prompt "Enter the path of the WAV file ex: C:\test\meme.wav"
    Write-Host "Configured path: $audio `n" -ForegroundColor Green

    Copy-Item -Path $audio -Destination $cheminaudio -ToSession $Session
}

Function Add-Play-Music
{
    $Session = Get-PSSession
    $cheminaudio = "C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\"

    $audio = Read-Host -Prompt "Enter the path of the WAV file ex: C:\test\meme.wav"
    Write-Host "Configured path: $audio `n" -ForegroundColor Green

    Copy-Item -Path $audio -Destination $cheminaudio -ToSession $Session

    $audiofile = Get-Item $audio
    $nomfile = $audiofile.Basename + $audiofile.Extension

    Invoke-Command -Session $Session -ScriptBlock { 
		$sound = new-Object System.Media.SoundPlayer;
		$sound.SoundLocation="C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\$Using:nomfile";
		$sound.Play();
    }
}

Function Play-Music()
{
    $Session = Get-PSSession
    $audio = Read-Host -Prompt "Enter the name of the WAV file ex: meme.wav"
    Write-Host "Configured path: $audio `n" -ForegroundColor Green
    Invoke-Command -Session $Session -ScriptBlock { 
        

        $sound = new-Object System.Media.SoundPlayer;
        $sound.SoundLocation="C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\$Using:audio";
        $sound.Play();
    }
}

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

Function touch {
    param (
        [string]$file
    )

    $dir = Split-Path $file

    if (Test-Path $file) {
        Get-Item $file
    } elseif ($dir -and !(Test-Path -LiteralPath $dir)) {
        $null = mkdir $dir
        $null = New-Item $file -ItemType File
    } else {
        $null = New-Item $file -ItemType File
    }
}

Function KillProcess {
$listapps = Get-Process | Select-Object ProcessName
echo $listapps | Format-Wide -Column 6
$Application = Read-Host -Prompt "Entrer le nom de l'application"
    if (-not($Application)) {
        Write-Host "$Application `n" -ForegroundColor Green
    }
    elseif ($Application) {
        Write-Host "Nom de l'application: $Application `n" -ForegroundColor Green
    }
  foreach($App in $listapps)
  {
     if($App -match $Application)
        {
        $name = $App
        
        }
  }
echo $name.ProcessName
Stop-process -Name $name.ProcessName -Force   
}

Function Sleep-Mode
{
    C:/Windows/System32/rundll32.exe powrprof.dll,SetSuspendState Sleep
}

Function boucle {
    foreach ($application in $Software) {

            if ($application -match $Name) {
                $DName = $Application.DisplayName
                $Uninstall = $Application.UnInstallString
                $NameOrganisation = $Application.Publisher
                $Version = $Application.DisplayVersion
                $Date = $Application.InstallDate
                Write-Host -ForegroundColor Green "Application name: " -NoNewline
                Write-Host -ForegroundColor White "$DName"
                Write-Host -ForegroundColor Green "Version: " -NoNewline
                Write-Host -ForegroundColor White "$Version"
                Write-Host -ForegroundColor Green "Installation date: " -NoNewline
                Write-Host -ForegroundColor White "$Date"
                Write-Host -ForegroundColor Green "Uninstall string: " -NoNewline
                Write-Host -ForegroundColor White "$Uninstall"
                Write-Host -ForegroundColor Green "Organization name: " -NoNewline
                Write-Host -ForegroundColor White "$NameOrganisation`n"
                $i = $i + 1
            }
        }
        if ($i -eq 0) {
            Write-Host "$Name has not been found or is not installed !`n" -ForegroundColor Red
        }
}

Function search {
   
    [CmdletBinding()]
    Param([Parameter(Mandatory=$false)]
    [string]$Name = '')
    $Software = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | select DisplayName, UninstallString, Publisher, DisplayVersion, InstallDate
    $i = 0
    
    if ($PSBoundParameters.Keys.Contains("Name"))
    {
        boucle
    }
    else {
        $Name = Read-Host -Prompt "Enter the application name"
        if (-not($Name)) {
            Write-Host "Please enter the application name " -ForegroundColor Red
            Write-Host "All applications :`n " -ForegroundColor Green
            sleep 1
        }
        elseif ($Name) {
            Write-Host "The results for $Name are:`n" -ForegroundColor Green
        }
        boucle
    }
}

Function Wol {
  param
  (
    # one or more MACAddresses
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    # mac address must be a following this regex pattern:
    [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
    [string[]]
    $MacAddress 
  )
 
  begin
  {
    # instantiate a UDP client:
    $UDPclient = [System.Net.Sockets.UdpClient]::new()
  }
  process
  {
    foreach($_ in $MacAddress)
    {
      try {
        $currentMacAddress = $_
        
        # get byte array from mac address:
        $mac = $currentMacAddress -split '[:-]' |
          # convert the hex number into byte:
          ForEach-Object {
            [System.Convert]::ToByte($_, 16)
          }
 
        #region compose the "magic packet"
        
        # create a byte array with 102 bytes initialized to 255 each:
        $packet = [byte[]](,0xFF * 102)
        
        # leave the first 6 bytes untouched, and
        # repeat the target mac address bytes in bytes 7 through 102:
        6..101 | Foreach-Object { 
          # $_ is indexing in the byte array,
          # $_ % 6 produces repeating indices between 0 and 5
          # (modulo operator)
          $packet[$_] = $mac[($_ % 6)]
        }
        
        #endregion
        
        # connect to port 400 on broadcast address:
        $UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
        
        # send the magic packet to the broadcast address:
        $null = $UDPclient.Send($packet, $packet.Length)
        Write-Verbose "sent magic packet to $currentMacAddress..."
      }
      catch 
      {
        Write-Warning "Unable to send ${mac}: $_"
      }
    }
  }
  end
  {
    # release the UDF client and free its memory:
    $UDPclient.Close()
    $UDPclient.Dispose()
  }
}
