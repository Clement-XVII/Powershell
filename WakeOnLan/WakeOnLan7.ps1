
function Wol {
param( [Parameter(Mandatory=$true, HelpMessage="MAC address of target machine to wake up")]
       [string] $MacAddress )
 
 
Set-StrictMode -Version Latest
 
function Send-Packet([string]$MacAddress)
{
    try
    {
        $Broadcast = ([System.Net.IPAddress]::Broadcast)
 
        ## Create UDP client instance
        $UdpClient = New-Object Net.Sockets.UdpClient
 
        ## Create IP endpoints for each port
        $IPEndPoint = New-Object Net.IPEndPoint $Broadcast, 9
 
        ## Construct physical address instance for the MAC address of the machine (string to byte array)
        $MAC = [Net.NetworkInformation.PhysicalAddress]::Parse($MacAddress.ToUpper())
 
        ## Construct the Magic Packet frame
        $Packet =  [Byte[]](,0xFF*6)+($MAC.GetAddressBytes()*16)
 
        ## Broadcast UDP packets to the IP endpoint of the machine
        $UdpClient.Send($Packet, $Packet.Length, $IPEndPoint) | Out-Null
        $UdpClient.Close()
    }
    catch
    {
        $UdpClient.Dispose()
        $Error | Write-Error;
        #Write-Warning "Unable to send ${MacAddress}: $_"
    }
}

## Send magic packet to wake machine
Write-host "Sending magic packet to $MacAddress"
Send-Packet $MacAddress
}