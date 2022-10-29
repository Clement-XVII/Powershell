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