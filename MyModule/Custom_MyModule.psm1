$Username = "admin"
$Password = "admin123"
$lettre = Get-WmiObject -Class Win32_logicaldisk | Where { $_.VolumeName -eq "Activation" } | ForEach-Object { $_.DeviceID }
$CSV = "$lettre\list.csv"

# This function starts a new PowerShell session on a remote computer
# The session can be entered interactively or not
# The remote computer name is obtained from a CSV file

Function Start-Session() {

    # Define the parameters for the function
    Param(
        # The name(s) of the remote session(s)
        [Parameter(Mandatory = $false)] 
        [string[]]$Name,
        # Switch parameter to specify if the session should be entered interactively
        [switch]$Enter,
        [switch]$All
    )

    # Read the CSV file and select the columns Machines and Users
    $ListPCs = Get-Content $CSV -Encoding UTF8 | ConvertFrom-Csv -Delimiter ";" | select Machines, Noms

    # Convert the password to a secure string
    $mdp = ConvertTo-SecureString $Password -AsPlainText -Force

    # Loop through each computer in the list
    foreach ($UnPC in $ListPCs) {
        # Check if the computer name matches the specified name(s)
        if (($All) -or ($Name -contains $UnPC.Noms)) {
            # Get the computer name and user name
            $NomPC = $UnPC.Machines
            $NomUser = $UnPC.Noms
            # Define the login credentials using the computer name and username
            $login = "$NomPC\$Username"
            # Create a new PSCredential object with the login credentials and password
            $mycreds = New-Object System.Management.Automation.PSCredential($login, $mdp)
            # If the switch parameter Enter is specified, enter the session interactively
            if ($Enter) {
                # Enter a PowerShell session on the remote computer using the credentials and user name
                Enter-PSSession -ComputerName $NomPC -Credential $mycreds
            }
            # If the switch parameter Enter is not specified, create a new session
            else {
                # Create a new PowerShell session on the remote computer using the credentials and user name
                New-PSSession -ComputerName $NomPC -Name $NomUser -Credential $mycreds
            }
        }
    }
}

# Function to remove a PowerShell session
Function Remove-Session() {
    # Define parameters for the function
    Param(
        # A string parameter, not mandatory
        [Parameter(Mandatory = $false)] 
        [string]$Name,
        # A switch parameter
        [switch]$All
    )
    # Check if the Name parameter was passed
    if ($Name)) {
        # If so, remove the session with the specified name
        Remove-PSSession -Name $Name
    }
    # Check if the All switch was passed
    elseif ($All) {
        # If so, get all the sessions and remove them
        $s = Get-PSSession
        Remove-PSSession -Session $s
    }
    # If neither Name nor All were passed
    else {
        # Display all the sessions
        Get-PSSession
        # Prompt the user to enter the name of the session to remove
        $Name = Read-Host -Prompt "Enter the name of Session"
        # Remove the specified session
        Remove-PSSession -Name $Name
    }
}

# Function to send a single command to a PowerShell session
Function Send-Command() {
    # Get all the sessions
    $Session = Get-PSSession
    # Prompt the user to enter the command to run
    $command = Read-Host -Prompt "Enter command to run"
    # Invoke the command on the specified session
    Invoke-Command -Session $Session -ScriptBlock {
        powershell.exe $Using:command
    }
}

# Function to send multiple commands to a PowerShell session
Function Send-Commands() {
    # Loop until the user stops the script
    while ($true) {
        # Get all the sessions
        $Session = Get-PSSession
        # Prompt the user to enter the command to run
        $command = Read-Host -Prompt "Enter command to run"
        # Invoke the command on the specified session
        Invoke-Command -Session $Session -ScriptBlock {
            powershell.exe $Using:command
        }
    }
}


# Function to send a script
Function Send-Script() {
    # Get current PS session
    $Session = Get-PSSession

    # Read the script file path from user input
    $MyScript = Read-Host -Prompt "Enter the path of the script file ex: C:\test\script.ps1"

    # Invoke the command with the specified file path and session
    Invoke-Command -FilePath $MyScript -Session $Session
}

# Function to add a music file
Function Add-Music() {
    # Get current PS session
    $Session = Get-PSSession

    # Set the audio file path
    $cheminaudio = "C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\"

    # Read the audio file path from user input
    $audio = Read-Host -Prompt "Enter the path of the WAV file ex: C:\test\meme.wav"

    # Write a message with the configured path in green color
    Write-Host "Configured path: $audio `n" -ForegroundColor Green

    # Copy the item (audio file) to the destination path
    Copy-Item -Path $audio -Destination $cheminaudio -ToSession $Session
}

# Function to add and play a music file
Function Add-Play-Music {
    # Get current PS session
    $Session = Get-PSSession

    # Set the audio file path
    $cheminaudio = "C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\"

    # Read the audio file path from user input
    $audio = Read-Host -Prompt "Enter the path of the WAV file ex: C:\test\meme.wav"

    # Write a message with the configured path in green color
    Write-Host "Configured path: $audio `n" -ForegroundColor Green

    # Copy the item (audio file) to the destination path
    Copy-Item -Path $audio -Destination $cheminaudio -ToSession $Session

    # Get the audio file information
    $audiofile = Get-Item $audio

    # Store the audio file name
    $nomfile = $audiofile.Basename + $audiofile.Extension

    # Invoke the command to play the audio file
    Invoke-Command -Session $Session -ScriptBlock { 
        # Create a new sound player object
        $sound = new-Object System.Media.SoundPlayer;

        # Set the sound location to the audio file path
        $sound.SoundLocation = "C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\$Using:nomfile";

        # Play the audio file
        $sound.Play();
    }
}


# Function to play music using PowerShell
Function Play-Music() {
    # Get the PowerShell session
    $Session = Get-PSSession

    # Prompt the user to enter the name of the WAV file
    $audio = Read-Host -Prompt "Enter the name of the WAV file ex: meme.wav"

    # Write a message to the console confirming the configured path
    Write-Host "Configured path: $audio `n" -ForegroundColor Green

    # Invoke the command on the session
    Invoke-Command -Session $Session -ScriptBlock { 
        # Create a new SoundPlayer object
        $sound = new-Object System.Media.SoundPlayer;

        # Set the SoundLocation property to the path of the WAV file
        $sound.SoundLocation = "C:\Program Files\WindowsPowerShell\Modules\PSModule\AudioFiles\$Using:audio";

        # Play the audio
        $sound.Play();
    }
}

# Function to eject all CD drives on remote computers
Function Eject-ALLCD() {
    # Get all PS sessions
    $Session = Get-PSSession

    # Write the list of Drive Types and their corresponding numbers
    Write-Host "CDRom                       5`nFixed(External/Fixed Disk)  3`nNetwork                     4`nNoRootDirectory             1`nRam                         6`nRemovable(USB Drive)        2`nUnknown                     0`n"

    # Prompt user to enter the desired Drive Type
    $type = Read-Host -Prompt "Enter the Drive Type"

    # Use Invoke-Command to run the script block on the remote computers
    Invoke-Command -Session $Session -ScriptBlock {
        # Get the letter of the logical disk where drive type is equal to user's input
        $lettre = Get-WmiObject -Class Win32_logicaldisk | Where { $_.DriveType -eq "$Using:type" } | ForEach-Object { $_.DeviceID }

        # Loop through each computer and eject the CD drive
        foreach ($UnPC in $lettre) {
            # Use the Shell.Application COM object to eject the CD drive
(new-object -COM Shell.Application).NameSpace(17).ParseName("$UnPC").InvokeVerb("Eject")
        }
    }
}

# Define the Wol function
Function Wol {
    # Define the parameters for the function
    param
    (
        # The MacAddress parameter is mandatory, its value will be taken from the pipeline and from the property name of the pipeline object
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        # Validate the MacAddress parameter to match the pattern of a MAC address
        [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
        [string[]]
        $MacAddress 
    )

    # Start of the function
    begin {
        # Create a new instance of a UdpClient object
        $UDPclient = [System.Net.Sockets.UdpClient]::new()
    }
    # Main process of the function
    process {
        # Loop through each MacAddress in the pipeline
        foreach ($_ in $MacAddress) {
            try {
                # Assign the current MacAddress to a variable
                $currentMacAddress = $_
                # Split the current MacAddress into separate bytes and convert each byte to hexadecimal
                $mac = $currentMacAddress -split '[:-]' |
                ForEach-Object {
                    [System.Convert]::ToByte($_, 16)
                }
                # Create the magic packet as a byte array
                $packet = [byte[]](, 0xFF * 102)
                6..101 | Foreach-Object { 
                    $packet[$_] = $mac[($_ % 6)]
                }
                # Connect the UdpClient to the broadcast address on port 4000
                $UDPclient.Connect(([System.Net.IPAddress]::Broadcast), 4000)
                # Send the magic packet using the UdpClient
                $null = $UDPclient.Send($packet, $packet.Length)
                # Output a verbose message indicating that the magic packet has been sent
                Write-Verbose "sent magic packet to $currentMacAddress..."
            }
            catch {
                # Output a warning message if there was an error sending the magic packet
                Write-Warning "Unable to send ${mac}: $_"
            }
        }
    }
    # End of the function
    end {
        # Close and dispose of the UdpClient object
        $UDPclient.Close()
        $UDPclient.Dispose()
    }
}


# This function adds a script to the remote session and runs it.
Function AddExec-Script {
    # Define the parameters for the function.
    param
    (
        [Parameter(Mandatory = $false)] 
        [string]$Name, # The name of the remote session.
        [string]$script # The path of the script to be added and run.
    )
    # Set the path of the script.
    $cheminascript = "$Env:TMP\Script\"

    # Check if the "Name" parameter is present.
    if ($PSBoundParameters.Keys.Contains("Name")) {
        # Get the remote session name.
        $Session = (Get-PSSession).Name
        # Check if the remote session is not available or not active.
        if (($Session -eq $null) -or ($Session.Availability -ne [System.Management.Automation.Runspaces.RunspaceAvailability]::Available)) {
            # Display the availability of the session.
            $Session.Availability
            Write-Host "Session is not available" -ForegroundColor Red
            Write-Host "Starting Session..." -ForegroundColor Green
            # Start the remote session with the specified name.
            Start-Session -Name $Name
        }
        # Get the remote session name again.
        $Session = (Get-PSSession).Name
        # Loop through each session name.
        foreach ($nam in $Session) {
            # Check if the session name matches the specified name.
            if ($nam -match "$Name") {
                # Get the remote session with the specified name.
                $Session = Get-PSSession -Name $nam
                # Execute the script block on the remote session.
                Invoke-Command -Session $Session -ScriptBlock {
                    # Check if the script path exists.
                    if ((Test-Path $using:cheminascript) -eq $True) {
                        Write-Host "Present"
                    }
                    else {
                        Write-Host "Absent" ;
                        # Create the script path if it doesn't exist.
                        New-Item $using:cheminascript -ItemType Directory -Force | Out-null
                    }
                }
                # Get the script file name and extension.
                $scriptfile = Get-Item $script
                $nomfile = $scriptfile.Basename + $scriptfile.Extension
                # Set the path of the copied script.
                $ncs = $cheminascript + $nomfile 
                # Copy the script to the remote session.
                Copy-Item -Path $script -Destination $cheminascript -ToSession $Session

                # Start the copied script in the remote session.
                Execute-RemoteCommand -Command "-WindowStyle hidden -File $ncs" -Name $Session 
            }
        }
    }
}


# This function will execute a remote command on a remote machine.
# The function accepts the command, application, working directory and name as parameters.
# If the name of the machine is specified, it will check if a session is available with that name. 
# If the session is not available, it will start a new session. 
# If the name is not specified, it will get all the available PSSession.
# If no PSSession is available, it will return an error message.
# If a PSSession is available, it will loop through the sessions and execute the command or application in a scheduled task.
# The scheduled task will be started and then immediately unregistered.

function Execute-RemoteCommand {
    param(
        [string]$Command,
        [string]$Application,
        [string]$WorkingDirectory,
        [string]$Name
    )
    # Check if the name of the machine is specified
    if ($PSBoundParameters.Keys.Contains("Name")) {
        # Get all available sessions with the specified name
        $sessions = (Get-PSSession).Name
        # Check if the session is not available
        if (($sessions -eq $null) -or ($sessions.Availability -ne [System.Management.Automation.Runspaces.RunspaceAvailability]::Available)) {
            $sessions.Availability
            Write-Host "Session is not available" -ForegroundColor Red
            Write-Host "Starting Session..." -ForegroundColor Green
            Start-Session -Name $Name
            
        }
        $sessions = Get-PSSession -Name ((Get-PSSession).Name)
    }
    else {
        # Get all available PSSession
        $sessions = Get-PSSession
    }
    # Check if no PSSession is available
    if ($sessions -eq $null) {
        Write-Error "No PSSession is available."
        return
    }
    else {
        Write-Host $sessions
    }
    # Loop through the available sessions
    foreach ($session in $sessions) {
        # Execute the command or application in a scheduled task
        Invoke-Command -Session $session -ArgumentList $Command, $Application, $WorkingDirectory -ScriptBlock {
            # Define parameters for the script block
            param(
                [Parameter(Mandatory = $false)]
                [string]$Command,
                [string]$Application,
                [string]$WorkingDirectory
            )
            # Check if a command is specified
            if ($Command -ne $null -and $Command -ne "") {
                # Create a scheduled task action to execute the PowerShell command
                $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "$Command" -WorkingDirectory "C:\Windows\System32\WindowsPowerShell\v1.0"
            }
            # Check if an application is specified
            elseif ($Application -ne $null -and $Application -ne "") {
                # Create a scheduled task action to execute the specified application
                $action = New-ScheduledTaskAction -Execute "$Application" -WorkingDirectory "$WorkingDirectory"
            }
            # If neither command nor application is specified
            else {
                # Write an error message
                Write-Error "No command or application specified."
                # Exit the script
                return
            }
            # Define the task name
            $taskname = "Remote Execution"
            # Create a scheduled task with the specified action
            $task = New-ScheduledTask -Action $action 
            # Try to get the registered task with the same name
            try {
                $registeredTask = Get-ScheduledTask $taskname -ErrorAction SilentlyContinue
            } 
            # If there is an error getting the task
            catch {
                # Set the task to null
                $registeredTask = $null
            } 
            # If the task with the same name already exists
            if ($registeredTask) {
                # Unregister the task
                Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false
            }
            # Register the new task with the specified name
            $registeredTask = Register-ScheduledTask -TaskName "Remote Execution" -InputObject $task 
            # Start the scheduled task
            Start-ScheduledTask -InputObject $registeredTask
            # Unregister the task after it has been started
            Unregister-ScheduledTask -TaskName "Remote Execution" -Confirm:$false 
        }
    }
    Remove-Session -All
}

function Get-HelpModule {

    Write-Host ""
    Write-Host "----------MyModule----------"
    Write-Host ""
    # Get all functions from the module
    $functions = Get-Command -Module "MyModule" | Where-Object { $_.CommandType -eq 'Function' }

    # Loop through each function
    foreach ($function in $functions) {
        # Get the help information for the function
        $help = Get-Help $function.Name -Full

        # Write the function name and synopsis to the console
        Write-Host "Function: $($function.Name)"
    }
    Write-Host ""
    Write-Host "----------PSModule----------"
    Write-Host ""

    $functions = Get-Command -Module "PSModule" | Where-Object { $_.CommandType -eq 'Function' }

    # Loop through each function
    foreach ($function in $functions) {
        # Get the help information for the function
        $help = Get-Help $function.Name -Full

        # Write the function name and synopsis to the console
        Write-Host "Function: $($function.Name)"
    }
    Write-Host ""
}
