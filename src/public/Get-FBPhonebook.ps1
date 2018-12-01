<#
.SYNOPSIS
Export Fritz!Box phonebook.

.DESCRIPTION
Exports Fritz!Box phonebook with the ID <id> to an xml file.

.PARAMETER phonebookID
Fritz!Box phoenbook ID

.PARAMETER Export
Export Fritz!Box phonebook to an xml file.

.PARAMETER phonebookPath
Name with path of the exported Fritz!Box phoenbook.

.EXAMPLE
Get-FBPhonebook

.EXAMPLE
Get-FBPhonebook -phonebookID 1 -Export -phonebookPath 'C:\Users\User1\Documents\FBPhonebook.xml'

.INPUTS
    n/a

.OUTPUTS
    [PSScriptObject] phonebook

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-16
    Purpose/Change: Initial script development
#>
function Get-FBPhonebook {
    [CmdletBinding()]
    Param (
        # Param phonebookID
        [Parameter(
            Position = 1,
            HelpMessage = "ID of the Fritz!Box phonebook, Standard phonebook ID: 0.",
            ValueFromPipeline = $true)]
        [int]
        $phonebookID = 0,

        # Param export
        [Parameter(
            ParameterSetName = 'Export',
            Position = 2,
            HelpMessage = "Filename with path of exported Fritz!Box phonebook",
            ValueFromPipeline = $false)]
        [switch]
        $export,

        # Param phonebookpath
        [Parameter(
            ParameterSetName = 'Export',
            Position = 3,
            HelpMessage = "Filename with path of Fritz!Box phonebook to export.",
            ValueFromPipeline = $false)]
        [ValidateScript( {test-path -path (split-path -Path "$_")})]
        [String]
        # $phonebookPath = (Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -childpath "FBPhonebook_$phonebookID.xml")
        $phonebookPath = (Join-Path -Path $script:appDataDir -childpath "FBPhonebook_$phonebookID.xml")
    )

    begin {
        if (!$port) {(Get-FBSecurityPort)}

        $w = New-Object System.Net.WebClient
        $w.Encoding = [system.text.encoding]::UTF8
    }

    process {
        $w.Headers.set("Content-Type", 'text/xml; charset ="utf-8"')
        $w.headers.set("SOAPACTION", 'urn:dslforum-org:service:X_AVM-DE_OnTel:1#GetPhonebook')
        $query = @"
        <?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
            s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
            <s:Body>
                <u:GetPhonebook xmlns:u="urn:dslforum-org:service:X_AVM-DE_OnTel:1">
                <NewPhonebookID>{0}</NewPhonebookID>
                </u:GetPhonebook>>
            </s:Body>
        </s:Envelope>
"@ -f $phonebookID

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
        $url = $r.Envelope.Body.GetPhonebookResponse.NewPhonebookURL
        #"Phonebookname: " + $r.Envelope.Body.GetPhonebookResponse.NewPhonebookName
        $probs = [ordered]@{pbid = $phonebookID
            Url = $r.Envelope.Body.GetPhonebookResponse.NewPhonebookURL
            Name = $r.Envelope.Body.GetPhonebookResponse.NewPhonebookName
            ExtraId = $r.Envelope.Body.GetPhonebookResponse.NewPhonebookExtraID
        }
        $phonebook = New-Object -TypeName PSObject -Property $probs
        Write-Output $phonebook

        # Export the phonebook to an xml file
        if ($export) {
            $w.Headers.Clear()
            $w.DownloadFile($url, $phonebookPath)
            Write-Host "Fritz!Box phonebook with ID $phonebookID exported to file $phonebookPath"
            Write-Log -message "Fritz!Box phonebook with ID $phonebookID exported to file $phonebookPath"
        }
    }

    end {
    }
}



