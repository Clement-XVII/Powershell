Function Send-Command()
{
    $Session = Get-PSSession
    $command = Read-Host -Prompt "Enter command to run"
    Invoke-Command -Session $Session -ScriptBlock {
       powershell.exe $Using:command
    }
}