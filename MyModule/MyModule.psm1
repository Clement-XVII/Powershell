#It is possible to have two variables Password and username in order to avoid asking for the password and username every time


Function Start-Session()
{
    Param(
        [Parameter(Mandatory = $true)] 
        [string]$CSV,
        [string]$Username,
        [Parameter(Mandatory = $false)] 
        [string]$Name,
        [switch]$Enter

    )
    if ($PSBoundParameters.Keys.Contains("Enter")){
        $ListPCs = Get-Content $CSV -Encoding UTF8 | ConvertFrom-Csv -Delimiter ";" | select Machines, Users
        $Password = Read-Host "Enter Password" -AsSecureString
        $mdp = ConvertFrom-SecureString -SecureString $Password
        foreach ($UnPC in $ListPCs) {
            if ($UnPC -match "$Name") {
                $NomPC = $UnPC.Machines
                $login = "$NomPC\$Username"
                $mycreds = New-Object System.Management.Automation.PSCredential($login, ($mdp | ConvertTo-SecureString))
                $Session = Enter-PSSession -ComputerName $NomPC -Credential $mycreds
            }
        }
    }
    elseif ($PSBoundParameters.Keys.Contains("Name")){
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
function Start-Process-Active
{
    
    param
    (
        [Parameter(Mandatory = $true)] 
        [string]$WorkingDirectory,
        [string]$Executable,

        [Parameter(Mandatory = $false)] 
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [string]$Argument,
        [string]$UserID

    )


    Invoke-Command -Session $Session -ArgumentList $Executable,$Argument,$WorkingDirectory,$UserID -ScriptBlock {
        param(
        [Parameter(Mandatory = $false)]
        $Executable,
        $Argument,
        $WorkingDirectory,
        $UserID
        )
        if ($PSBoundParameters.Keys.Contains("Argument")){
         $action = New-ScheduledTaskAction -Execute $Executable -Argument $Argument -WorkingDirectory $WorkingDirectory
        }
        else {
         $action = New-ScheduledTaskAction -Execute $Executable -WorkingDirectory $WorkingDirectory
        }
        $principal = New-ScheduledTaskPrincipal -userid $UserID
        $task = New-ScheduledTask -Action $action -Principal $principal
        $taskname = "_StartProcessActiveTask"
        try 
        {
            $registeredTask = Get-ScheduledTask $taskname -ErrorAction SilentlyContinue
        } 
        catch 
        {
            $registeredTask = $null
        }
        if ($registeredTask)
        {
            Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false
        }
        $registeredTask = Register-ScheduledTask $taskname -InputObject $task
        Start-ScheduledTask -InputObject $registeredTask
        Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false
    }

}

function Open-Apps
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Executable,
        [string]$WorkingDirectory,
        [string]$CSV,
        [string]$Username,
        [string]$UserID,
        [Parameter(Mandatory = $false)] 
        [string]$Name,
        [string]$Argument
        
    )
    
    if ($PSBoundParameters.Keys.Contains("Name")){
      $Session = (Get-PSSession).Name
      if (($Session -eq $null) -or ($Session.Availability -ne [System.Management.Automation.Runspaces.RunspaceAvailability]::Available))
      {
         $Session.Availability
         Write-Host "Session is not available" -ForegroundColor Red
         Write-Host "Starting Session..." -ForegroundColor Green
         Start-Session -Name $Name -Username $Username -CSV $CSV
      }
      $Session = (Get-PSSession).Name
      foreach ($nam in $Session) {
         if ($nam -match "$Name") {
               $Session = Get-PSSession -Name $nam
               if ($PSBoundParameters.Keys.Contains("Argument")){
                  Start-Process-Active -Session $Session -Executable $Executable -Argument $Argument -WorkingDirectory $WorkingDirectory -UserID $UserID
                  }
                  else {
                     Start-Process-Active -Session $Session -Executable $Executable -WorkingDirectory $WorkingDirectory -UserID $UserID
                  }
               }
         }
    }
    else {
      $Session = Get-PSSession
      if (($Session -eq $null) -or ($Session.Availability -ne [System.Management.Automation.Runspaces.RunspaceAvailability]::Available))
      {
         $Session.Availability
         Write-Host "Session is not available" -ForegroundColor Red
         Write-Host "Starting Sessions..." -ForegroundColor Green
         Start-Session -CSV $CSV -Username $Username
      }
      
      $Session = Get-PSSession
      if ($PSBoundParameters.Keys.Contains("Argument")){
         Start-Process-Active -Session $Session -Executable $Executable -Argument $Argument -WorkingDirectory $WorkingDirectory -UserID $UserID
         }
         else {
               Start-Process-Active -Session $Session -Executable $Executable -WorkingDirectory $WorkingDirectory -UserID $UserID
         }
    }
    Write-Host "Remove all sessions..." -ForegroundColor Green
    Remove-Session -All
}
