Function Send-Script()
{
    $Session = Get-PSSession
    $MyScript = Read-Host -Prompt "Enter the path of the script file ex: C:\test\script.ps1"
    Invoke-Command -FilePath $MyScript -Session $Session
}