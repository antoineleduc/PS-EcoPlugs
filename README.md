# PS-EcoPlugs

I decided to include my PowerShell code for Woods Wion (Eco-Plugs) smart outlet into my tools, why not share it with other people?
## What you will need:
<i>* Note: The outlet can be on the cloud, but the script will only work locally.</i>
<br>
<br>1. Find the outlet's `IP address` and set the `-Endpoint` parameter.
<br>2. Find your `Device ID` (in the APP's settings) and set the `-DeviceId` parameter.
<br>
<br>`Enable-EcoPlug -DeviceId ECO-7801F016 -Endpoint 192.168.2.69`
<br>`Disable-EcoPlug -DeviceId ECO-7801F016 -Endpoint 192.168.2.69`
<br>
<br>If you don't specify the Device ID or Endpoint, you will be asked for it once you run the function.
<br>
<br>You can also run Find-EcoPlug to automatically lookup your whole network (192.168.1-2.1-99) but that takes a bit more time. That being said, it is a great way to find your Device ID and IP address as your Eco-Plug device ID is "ECO-[last 8 characters of its MAC Address]". The function automatically assigns the `$DeviceID` and `$Endpoint` variables based on the results. 
<br>
<br>I haven't tested it with multiples devices yet as I currently only own 1 single outlet from Eco-Plug (Woods Wion).
<br>
<br>![alt text](https://github.com/antoineleduc/PS-EcoPlugs/blob/main/Screenshot%202021-01-17%20213153.png)
<br>
<br><b>ENJOY!</b>
<br>

```powershell
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

function Set-EcoPlugTimer{
    clear
    $TimerHours = Read-Host "Hours [HH]: "
    $TimerMinutes = Read-Host "Minutes [mm]: "
    $TimerSeconds = Read-Host "Seconds [ss]: "
    Write-Host "`nThe device will be ON for $TimerHours Hours, $TimerMinutes minutes, $TimerSeconds seconds"
    pause

    $CurrentTime = Get-Date
    $AlertTime = $CurrentTime.addHours($TimerHours).AddMinutes($TimerMinutes).AddSeconds($TimerSeconds) 

    Enable-EcoPlug

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-WindowStyle Hidden -command "Disable-EcoPlug; Unregister-ScheduledTask -TaskName AutoDisableEcoPlug -Confirm:$false"'
    $trigger =  New-ScheduledTasktrigger -once -at $AlertTime
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AutoDisableEcoPlug" -Description "Scheduled disabling of EcoPlug"
    }

function Set-EcoPlugAlarm{
    clear
    $AlarmHours = Read-Host "Hours [HH]: "
    $AlarmMinutes = Read-Host "Minutes [mm]: "
    $AMPM = Read-Host "AM/PM: "
    Write-Host "`nThe device will be turned ON daily at "$AlarmHours":"$AlarmMinutes
    pause

    $AlarmDate = Get-date -Format MM/dd/yy
    $AlarmTime = ($AlarmHours+":"+$AlarmMinutes+$AMPM)

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-WindowStyle Hidden -command "Enable-EcoPlug"'
    $trigger =  New-ScheduledTasktrigger -daily -At $AlarmTime
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Auto-Enable EcoPlug" -Description "Scheduled enabling of EcoPlug"
    }
```
