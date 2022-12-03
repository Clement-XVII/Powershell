function Start-Process-Active
{
    param
    (
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [string]$Executable,
        [string]$Argument,
        [string]$WorkingDirectory,
        [string]$UserID,
        [string]$Name

    )

    if (($Session -eq $null) -or ($Session.Availability -ne [System.Management.Automation.Runspaces.RunspaceAvailability]::Available))
    {
        $Session.Availability
        throw [System.Exception] "Session is not available"
    }

    Invoke-Command -Session $Session -ArgumentList $Executable,$Argument,$WorkingDirectory,$UserID -ScriptBlock {
        param($Executable, $Argument, $WorkingDirectory, $UserID)
        $action = New-ScheduledTaskAction -Execute $Executable -Argument $Argument -WorkingDirectory $WorkingDirectory
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