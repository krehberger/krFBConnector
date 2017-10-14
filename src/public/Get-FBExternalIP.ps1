<#
.SYNOPSIS
Get external IP address

.DESCRIPTION
Get's the external IP address

.EXAMPLE
Get-ExternalIP

.NOTES
Version:        1.0
Author:         Klaus Rehberger
Creation Date:  2017-09-16
Purpose/Change: Initial script development
#>
function Get-FBExternalIP {
    [CmdletBinding()]
    Param ()

    begin {
        if (!$port) {(Get-FBSecurityPort)}

        $w = New-Object System.Net.WebClient
        $w.Encoding = [system.text.encoding]::UTF8
    }

    process {
        $w.Headers.set("Content-Type", 'text/xml; charset ="utf-8"')
        $w.headers.set("SOAPACTION", 'urn:dslforum-org:service:WANPPPConnection:1#GetExternalIPAddress')
        $query = @"
        <?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
            s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
            <s:Body>
                <u:GetExternalIPAddress xmlns:u="urn:dslforum-org:service:WANPPPConnection:1">
                </u:GetExternalIPAddress>>
            </s:Body>
        </s:Envelope>
"@

        # Logon to Fritz!Box necessary
        # If no password file for Fritz!Box exist, ask for password and save it in an encrypted file
        if (!(Test-Path -path "pwFritz!Box.cred")) {
            Read-Host -prompt "Enter your Fritz!Box Logon password" -AsSecureString |
                ConvertFrom-SecureString | Out-File "pwFritz!Box.cred"
        }
        $password = Get-Content -path "pwFritz!Box.cred" | ConvertTo-SecureString
        $w.Credentials = New-Object System.Net.NetworkCredential("dslf-config", $password)

        # Deactivate certificate check of Webclient. Necessary because Fritz!Box has a selfsigned certificate.
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

        $r = [xml]$w.UploadString("https://fritz.box:" + $port + "/upnp/control/wanpppconn1", $query)
        "External IP address: " + $r.envelope.body.GetExternalIPAddressResponse.NewExternalIPAddress
    }

    end {
    }

}