<#
.SYNOPSIS
Delete phonebook from Fritz!Box.

.DESCRIPTION
Deletes the phonebook from Fritz!Box. If selected the phonebook can be saved before deletion.

.PARAMETER phonebookID
Fritz!Box phonebook ID

.PARAMETER backupBefore
If selected the phonebook will be saved before deletion.

.PARAMETER backupPhonebookPath
Filename wit path of the backup phonebook.

.EXAMPLE
Remove-FBPhonebook -phonebookID 1

.EXAMPLE
Remove-FBPhonebook -phonebookID 1 -backupBefore

.EXAMPLE
Remove-FBPhonebook -phonebookID 1 -babckupBefore -backupPhonebookPath "C:\Users\User1\Documents\Backup_FBPhonebook_1.xml"

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-17
    Purpose/Change: Initial script development
#>
function Remove-FBPhonebook {
    [CmdletBinding()]
    Param (
        # Param phonebookID
        [Parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = "ID of the Fritz!Box phonebook, Standard phonebook ID: 0.",
            ValueFromPipeline = $true)]
        [int]
        $phonebookID,

        # Param BackupBefore
        [Parameter(
            ParameterSetName = 'Backup',
            Position = 2,
            HelpMessage = "Backup Fritz!Box phonebook before Deletion?",
            ValueFromPipeline = $true)]
        [switch]
        $backupBefore,

        # Param phonebookpath
        [Parameter(
            ParameterSetName = 'Backup',
            Position = 3,
            HelpMessage = "Filename with path of Fritz!Box phonebook to export.",
            ValueFromPipeline = $true)]
        [ValidateScript( {test-path -path (split-path -Path "$_")})]
        [String]
        $backupPhonebookPath = (Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -childpath "Backup_FBPhonebook_$phonebookID.xml")
    )

    begin {
        if (!$port) {(Get-FBSecurityPort)}

        $w = New-Object System.Net.WebClient
        $w.Encoding = [system.text.encoding]::UTF8

        if ($backupBefore) {
            try {
                $ErrorActionPreference = 'Stop'
                $pbook = get-fbPhonebook -phonebookID $phonebookID -export -phonebookpath $backupPhonebookPath
                Write-Verbose -Message "Fritz!Box Phonebook with ID $phonebookID, name: $pbook.name saved on $backupPhonebookPath."
            }
            catch {
                throw ("Cannot find phonebook with ID $phonebookID. " + ($Error[0].Exception))
            }
        }
    }

    process {
        $w.Headers.set("Content-Type", 'text/xml; charset ="utf-8"')
        $w.headers.set("SOAPACTION", 'urn:dslforum-org:service:X_AVM-DE_OnTel:1#DeletePhonebook')
        $query = @"
        <?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
            s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
            <s:Body>
                <u:DeletePhonebook xmlns:u="urn:dslforum-org:service:X_AVM-DE_OnTel:1">
                <NewPhonebookID>{0}</NewPhonebookID>
                <NewPhonebookExtraID></NewPhonebookExtraID>
                </u:DeletePhonebook>>
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
        write-debug $r
        Write-Verbose  -Message "Fritz!Box Phonebook with ID $phonebookID deleted."
    }

    end {
    }
}

