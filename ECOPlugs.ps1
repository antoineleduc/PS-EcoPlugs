function Find-EcoPlug {
    $IPaddress =  nmap 192.168.1-2.1-99
    $ResultList = $IPaddress | Select-String -Pattern "(38:2B:78)" -AllMatches -Context 1,0 | % {
        $IPResult = $_.Context.PreContext[0]
        $MACaddress = $ipaddress | Select-string -Pattern "(38:2B:78)"
        $MACResult = ($Macaddress -split(" ") | Select-String '.*:.*:.*:.*:.*:.*').Line
        $Mac2DeviceID = $MACResult.Replace(":","")
        $ECOID = $Mac2DeviceID.Substring($mac2.Length -8)
        $regex = [regex] "\b(?:(?:25[0r-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
        
        $global:endpoint = $regex.Matches($IPResult) | %{ $_.value }
        $global:deviceid = "ECO-$ECOID"

        }

    if($Endpoint -match "192.168"){clear;Write-Host "Found EcoPlug Device $deviceid on IP: $EcoPlugIP`n";pause}
    elseif($Endpoint -notmatch "192.168"){clear;Write-Host "No EcoPlug Device found`n";pause}
    }

function Enable-EcoPlug {
    Param(
        [parameter(Mandatory=$false)]
        [string]$DeviceID = $DeviceID,
        [parameter(Mandatory=$false)]
        [string]$Endpoint = $Endpoint,
        [parameter(Mandatory=$false)]
        [string]$Port = 80
    )

    # code to turn on light

    if($DeviceID -notmatch "ECO-"){$global:DeviceID = Read-Host "Enter your Device ID: "}
    if($Endpoint -notmatch "192.168"){$global:Endpoint = Read-Host "Enter your Device IP Address: "}

    $enc = [system.Text.Encoding]::UTF8
    $id = $enc.GetBytes($deviceid)

    [Byte[]] $powerOn = 0x16, 0x00, 0x05, 0x00, 0x00, 0x00, 0xe6, 0x62, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, `
    $id[0], $id[1], $id[2], $id[3], $id[4], $id[5], $id[6], $id[7], $id[8], $id[9], $id[10], $id[11], 0x00, 0x00, 0x00, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4b, 0x65, `
    0x65, 0x7a, 0x65, 0x72, 0x20, 0x4c, 0x69, 0x67, 0x68, 0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x38, 0x30, 0x41, 0x39, 0x45, 0x42, 0x33, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x25, 0x2f, 0x60, 0x5d, 0x00, 0x00, 0x00, 0x00, 0x6b, 0x20, `
    0x0b, 0x42, 0x01, 0x01 

    $IP = [System.Net.Dns]::GetHostAddresses($EndPoint) 
    $Address = [System.Net.IPAddress]::Parse($IP) 
    $EndPoints = New-Object System.Net.IPEndPoint($Address, $Port) 
    $Socket = New-Object System.Net.Sockets.UDPClient 
    $SendMessage = $Socket.Send($powerOn, $powerOn.count, $EndPoints)
    
    $Reply = $Socket.Receive([ref]$EndPoints)
    ## Note that the line above is for debugging the response from the Endpoint
    
    $Socket.Close()
}

function Disable-EcoPlug {
    Param(
        [parameter(Mandatory=$false)]
        [string]$DeviceID = $DeviceID,
        [parameter(Mandatory=$false)]
        [string]$Endpoint = $Endpoint,
        [parameter(Mandatory=$false)]
        [string]$Port = 80
    )

    # code to turn on light

    if($DeviceID -notmatch "ECO-"){$global:DeviceID = Read-Host "Enter your Device ID: "}
    if($Endpoint -notmatch "192.168"){$global:Endpoint = Read-Host "Enter your Device IP Address: "}

    $enc = [system.Text.Encoding]::UTF8
    $id = $enc.GetBytes($deviceid) 

    [Byte[]] $powerOff = 0x16, 0x00, 0x05, 0x00, 0x00, 0x00, 0xff, 0x07, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, `
    $id[0], $id[1], $id[2], $id[3], $id[4], $id[5], $id[6], $id[7], $id[8], $id[9], $id[10], $id[11], 0x00, 0x00, 0x00, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4b, 0x65, `
    0x65, 0x7a, 0x65, 0x72, 0x20, 0x4c, 0x69, 0x67, 0x68, 0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x37, 0x38, 0x30, 0x41, 0x39, 0x45, 0x42, 0x33, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, `
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x25, 0x2f, 0x60, 0x5d, 0x00, 0x00, 0x00, 0x00, 0x6b, 0x20, `
    0x0b, 0x42, 0x01, 0x00

    $IP = [System.Net.Dns]::GetHostAddresses($EndPoint) 
    $Address = [System.Net.IPAddress]::Parse($IP) 
    $EndPoints = New-Object System.Net.IPEndPoint($Address, $Port) 
    $Socket = New-Object System.Net.Sockets.UDPClient 
    $SendMessage = $Socket.Send($powerOff, $powerOff.count, $EndPoints)
    
    $Reply = $Socket.Receive([ref]$EndPoints)
    ## Note that the line above is for debugging the response from the Endpoint
    
    $Socket.Close()
}
