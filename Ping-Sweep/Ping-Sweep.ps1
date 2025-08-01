function Ping-Sweep {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Target,

        [Parameter(Position = 1, Mandatory = $false)]
        [int[]]$Ports = @(22),  # Default ports: 22

        [Parameter(Position = 2, Mandatory = $false)]
        [int]$Timeout = 1, # Reduced connection timeout (in seconds)

        [Parameter(Position = 3, Mandatory = $false)]
        [string]$HostnameFilter  # Filter for hostname
    )

    process {
        $startTime = Get-Date  # Mark the start of execution
        $totalIterations = 254  # 192.168.1.1 to 192.168.1.254

        $results = 1..$totalIterations | ForEach-Object -Parallel {
            $ip = "$using:Target.$_"

            try {
                # Check if the machine responds to ping
                if (Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds $using:Timeout) {
                    $portResults = @{}

                    # Test each specified port
                    foreach ($port in $using:Ports) {
                        $portOpen = $false
                        try {
                            $tcpClient = [System.Net.Sockets.TcpClient]::new()
                            $asyncResult = $tcpClient.BeginConnect($ip, $port, $null, $null)
                            $wait = $asyncResult.AsyncWaitHandle.WaitOne(100, $false)  # Reduced connection time
                            if ($wait -and $tcpClient.Connected) {
                                $portOpen = $true
                            }
                        } catch {} finally {
                            $tcpClient.Close()
                        }

                        if ($portOpen) {
                            $portResults["Port `e[38;5;87m$port`e[0m"] = "`e[38;5;93mOpen`e[0m"
                        }
                    }


                    $hostname = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { "N/A" }

                    [PSCustomObject]@{
                        IPAddress = $ip
                        Hostname = $hostname
                        Ports = $portResults
                        Responding = "Yes"
                    }
                }
            } catch {
                # Ignore offline hosts
            }
        } -ThrottleLimit 254  # Increased for more speed

        # Separate results into two groups
        $respondingResults = $results | Where-Object { $_ -ne $null } | Sort-Object { [version]$_.IPAddress }

        if ($HostnameFilter) {
            $respondingResults = $respondingResults | Where-Object { $_.Hostname -match $HostnameFilter }
        }

        # Calculate elapsed time
        $endTime = Get-Date
        $elapsedTime = $endTime - $startTime
        $elapsedSeconds = [math]::Round($elapsedTime.TotalSeconds, 2)

        # Display results
        Write-Output "Machines UP:"

        # Format results for each port
        $formattedResults = $respondingResults | ForEach-Object {
            $portsString = ($_.Ports.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }) -join ", "

            [PSCustomObject]@{
                IPAddress  = $_.IPAddress
                Hostname   = $_.Hostname
                Ports      = $portsString
            }
        }

        $formattedResults #| Format-Table IPAddress, Hostname, Ports -AutoSize

        # Display elapsed time
        Write-Output "`nTotal execution time: $elapsedSeconds seconds"
    }
}
