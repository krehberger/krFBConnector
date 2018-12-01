<#
.SYNOPSIS
Get TCP port for a secure communication with Fritz!Box.

.DESCRIPTION
Get the TCP security port number of the Fritz!Box for a secure communication.

.EXAMPLE
Get-SecurityPort

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-15
    Purpose/Change: Initial script development
#>
function Get-FBSecurityPort {
    [CmdletBinding()]

    $w = New-Object System.Net.WebClient
    $w.Encoding = [system.text.encoding]::UTF8
    $w.Headers.set("Content-Type", 'text/xml; charset ="utf-8"')
    $w.headers.set("SOAPACTION",
        'urn:dslforum-org:service:DeviceInfo:1#GetSecurityPort')

    $query = @"
<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
            s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <s:Body>
        <u:GetSecurityPort xmlns:u="urn:dslforum-org:service:DeviceInfo:1">
        </u:GetSecurityPort>>
    </s:Body>
</s:Envelope>
"@

    $r = [xml]$w.UploadString("http://fritz.box:49000/upnp/control/deviceinfo", $query)
    # Save TCP security port number in script level variable $port
    $script:port = $r.envelope.body.GetSecurityPortResponse.NewSecurityPort

    Write-Log -message "Fritz!Box security port is: $script:port"

}



