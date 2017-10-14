<#
.SYNOPSIS
Read Microsoft Outlook contacts

.DESCRIPTION
Read contacts from Microsoft Outlook default contacts folder.
The Outlook contacts can be filtered Outlook category. Default filter is 'FritzBox'
The contacts can be saved in a CSV file.

.PARAMETER category
Optional parameter Outlook category for filtering selected contacts.
Calling the commandlet with no parameter contacts with category "FritzBox" will be selected.

.PARAMETER createCSV
If 'true' a CSV file with the selected Outlook contacts will be created.

.PARAMETER csvFilePath
Path where the CSV file will be saved

.EXAMPLE
Get-FBOlContacts

.EXAMPLE
Get-FBOlContacts -CreateCSV -csvFilePath "c:\temp"

.EXAMPLE
Get-FBOlContacts -category "Phonebook" -CreateCSV -csvFilePath "c:\temp"

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-19
    Purpose/Change: Initial script development
#>

function Get-FBOlContacts {
    [CmdletBinding()]
    Param (
        # Param1 help description
        [Parameter(Position = 0,
            HelpMessage = "Category of the Outlook contacts.",
            ValueFromPipeline = $true)]
        [string]
        $category = 'FritzBox',

        # Param2 help description
        [Parameter(ParameterSetName = 'CreateCSV',
            Position = 1,
            HelpMessage = "Create CSV file.",
            ValueFromPipeline = $true)]
        [switch]
        $createCSV,

        # Param3 help description
        [Parameter(ParameterSetName = 'CreateCSV',
            Position = 2,
            HelpMessage = "CSV file with path of the extracted Outlook contacts for the Fritz!Box addressbook.",
            ValueFromPipeline = $true)]
        [ValidateScript( {test-path -path (split-path -Path "$_")})]
        [string]
        $csvFilePath = (Join-Path -Path $env:temp -ChildPath 'krFBPhonebook.csv')
    )

    begin {
    }

    process {
        # create new Outlook object
        try {
            Write-Verbose -Message 'Connecting to Outlook session'
            $comOutlook = new-object -comobject outlook.application
            if ($comOutlook) {Write-Verbose -Message 'Connected successfully.'}
        }
        catch {
            throw ('Outlook not running. Try running Start-Outlook and then repeat command. ' + ($Error[0].Exception))
        }

        # Set Outlook folder (contacts)
        $objContacts = $comOutlook.Session.GetDefaultFolder(10)


        $Contacts = $objContacts.Items | where-object {$_.categories -like "*$category*"} |
            select-object Categories, CreationTime, LastModificationTime, FullName, FileAs,
        BusinessTelephoneNumber, Business2TelephoneNumber, HomeTelephoneNumber, Home2TelephoneNumber,
        MobileTelephoneNumber, OtherTelephoneNumber, BusinessFaxNumber, HomeFaxNumber, OtherFaxNumber,
        Sensitivity

        if ($createCSV) {
            $Contacts | Export-Csv -path $csvFilePath -Encoding UTF8 -NoTypeInformation
            Write-Verbose "Contacts exported to file $csvFilePath"
            return
        }

        Write-Output $Contacts

    }
    end {
    }
}