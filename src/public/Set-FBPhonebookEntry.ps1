<#
.SYNOPSIS
Add new phonebook entries to the Fritz!Box phonebook

.DESCRIPTION
Add new contacts with their phonenumbers to an exisiting Fritz!Box phonebook.

.PARAMETER Contact
Contact with phonenumbers for the Fritz!Book phonebook

.PARAMETER phonebookID
ID of the phonebook

.PARAMETER phonebookEntryID
ID of the Fritz!Box phonebook entry (contact).
If the parameter is "" (empty) a new contact will be created in the phonebook, otherwise updated.

.EXAMPLE
Set-FBPhonebookEntry -phonebookID 1

.EXAMPLE
Set-FBPhonebookEntry -phonebookID 1 -phonebookEntryID '4711'

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-19
    Purpose/Change: Initial script development
    2017-10-17      Settings for parameter phonebookID and phonebookEntryID changed because
                    of initialization issues when using the function in a command pipeline.
    2017-10-18      Phonenumber types for 'fax' changed to 'fax_work' for Fritz!Box.

#>
function Set-FBPhonebookEntry {
    [CmdletBinding()]
    Param (
        # Param contact
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [object]
        $contact,

        # Param phonebookID
        [Parameter(Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $false,
            HelpMessage = "ID of the Fritz!Box phonebook Fritz!Box - Standard phonebook ID is 0.")]
        [ValidateNotNullOrEmpty()]
        [int]
        $phonebookID,

        # Param phonebookEntryID
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Fritz!Box phonebook Entry ID",
            ValueFromPipeline = $false)]
        [String]
        $phonebookEntryID
    )

    begin {
        # phonenumber types
        enum numberType {
            home
            work
            mobile
            other
            fax_work
        }

        if (!$port) {(Get-FBSecurityPort)}

        $w = New-Object System.Net.WebClient
        $w.Encoding = [system.text.encoding]::UTF8

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
    }

    process {
        $w.Headers.set("Content-Type", "text/xml; charset=UTF-8")
        $w.headers.set("SOAPACTION", 'urn:dslforum-org:service:X_AVM-DE_OnTel:1#SetPhonebookEntry')

        # XML query for a contact in the Fritz!box Phonebook
        [XML]$query = @"
<?xml version="1.0" encoding="UTF-8"?>
    <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
        s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        <s:Body>
            <u:SetPhonebookEntry xmlns:u="urn:dslforum-org:service:X_AVM-DE_OnTel:1">
                <NewPhonebookID>{0}</NewPhonebookID>
                <NewPhonebookEntryID>{1}</NewPhonebookEntryID>
                <NewPhonebookEntryData>
                    <contact>
                        <category>0</category>
                        <person>
                            <realName>Test</realName>
                        </person>
                        <telephony nid="1">
                        </telephony>
                    </contact>
                </NewPhonebookEntryData>
            </u:SetPhonebookEntry>>
        </s:Body>
    </s:Envelope>
"@ -f $phonebookID, $phonebookEntryID

        #$query.OuterXml | out-file "C:\Users\klaus\Documents\query_1.xml"

        # Collection of phonenumbers for an contact
        $phoneNumbers = @()

        if ($contact.BusinessTelephoneNumber) {
            $props = @{
                numberType = 'work'
                number     = $contact.BusinessTelephoneNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.Business2TelephoneNumber) {
            $props = @{
                numberType = 'work'
                number     = $contact.Business2TelephoneNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.HomeTelephoneNumber) {
            $props = @{
                numberType = 'home'
                number     = $contact.HomeTelephoneNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.Home2TelephoneNumber) {
            $props = @{
                numberType = 'home'
                number     = $contact.Home2TelephoneNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.MobileTelephoneNumber) {
            $props = @{
                numberType = 'mobile'
                number     = $contact.MobileTelephoneNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.OtherTelephoneNumber) {
            $props = @{
                numberType = 'other'
                number     = $contact.OtherTelephoneNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.BusinessFaxNumber) {
            $props = @{
                numberType = 'fax_work'
                number     = $contact.BusinessFaxNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.HomeFaxNumber) {
            $props = @{
                numberType = 'fax_work'
                number     = $contact.HomeFaxNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }
        if ($contact.OtherFaxNumber) {
            $props = @{
                numberType = 'fax_work'
                number     = $contact.OtherFaxNumber
            }
            $phoneNumber = New-Object -TypeName PSObject -Property $props
            $phoneNumbers += $phoneNumber
        }

        # Convert Umlaute
        # Currently Umlaute are not right converted to Fritz!Box phonebook via SetPhonebookEntry action
        $FileAsConv = Convert-Umlaut -value $Contact.FileAs
        $query.Envelope.Body.SetPhonebookEntry.NewPhonebookEntryData.contact.person.realName = $FileAsConv

        for ($i = 0; $i -lt $phoneNumbers.length; $i++) {
            Write-Output $phoneNumbers[$i].numberType
            Write-Output $phoneNumbers[$i].number
            $number = $query.Envelope.Body.SetPhonebookEntry.NewPhonebookEntryData.contact.telephony
            $xmlEntry = '<number type="{0}" quickdial="" vanity="" prio="1" >{1}</number>' -f $phoneNumbers[$i].numberType, $phoneNumbers[$i].number
            $newNumber = [XML] $xmlEntry
            $newNode = $query.ImportNode($newNumber.number, $true)
            [void] $number.AppendChild($newNode)

            $query.Envelope.Body.SetPhonebookEntry.NewPhonebookEntryData.contact.telephony.nid = "$($i+1)"
        }

        #$query.OuterXml | out-file "C:\Users\klaus\Documents\query_2.xml"

        $r = [xml]$w.UploadString("https://fritz.box:" + $port + "/upnp/control/x_contact", $query.OuterXml)
        write-debug $r
        Write-Verbose -Message "Contact $($contact.FileAs) uploaded to Fritz!Box phonebook."
    }

    end {
    }
}