function Get-ModuleFunctions {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName
    )

    # Import the specified module
    Import-Module $ModuleName

    # Get all functions from the module
    $functions = Get-Command -Module $ModuleName | Where-Object { $_.CommandType -eq 'Function' }

    # Loop through each function
    foreach ($function in $functions) {
        # Get the help information for the function
        $help = Get-Help $function.Name -Full

        # Write the function name and synopsis to the console
        Write-Host "Function: $($function.Name)"
        Write-Host "Synopsis: $($help.Synopsis)"
        Write-Host ""
    }
}