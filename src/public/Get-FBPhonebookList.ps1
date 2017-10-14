<#
.SYNOPSIS
Get list of Fritz!Box phonebook id's.

.DESCRIPTION
Get a list of Fritz!Box phonebook id's

.EXAMPLE
Get-FBPhonebookList

.INPUTS
    n/a

.OUTPUTS
    ArrayList of Fritz!Box phonebook id's

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-17
    Purpose/Change: Initial script development
#>
function Get-FBPhonebookList {
    [CmdletBinding()]
    Param ()

    begin {
        if (!$port) {(Get-FBSecurityPort)}

        $w = New-Object System.Net.WebClient
        $w.Encoding = [system.text.encoding]::UTF8
    }

    process {
        $w.Headers.set("Content-Type", 'text/xml; charset ="utf-8"')
        $w.headers.set("SOAPACTION", 'urn:dslforum-org:service:X_AVM-DE_OnTel:1#GetPhonebookList')
        $query = @"
        <?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
            s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
            <s:Body>
                <u:GetPhonebookList xmlns:u="urn:dslforum-org:service:X_AVM-DE_OnTel:1">
                </u:GetPhonebookList>>
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

        $r = [xml]$w.UploadString("https://fritz.box:" + $port + "/upnp/control/x_contact", $query)

        # Return List of phonebook id's
        ($r.envelope.body.GetPhonebookListResponse.NewPhonebookList).split(',')
    }

    end {
    }

}

