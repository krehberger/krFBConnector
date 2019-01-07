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
    Version:        2.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-19
    Last Update:    2019-01-02
    Purpose/Change: 1.0     Initial script development
                    2.0     Refactoring Outlook access
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
        try {
            Add-Type -assembly "Microsoft.Office.Interop.Outlook" -ErrorAction Stop -ErrorVariable "OutlookError"
            Write-Verbose -Message 'Connecting to Outlook session'
            Write-Log -message 'Connecting to Outlook session'

            $comOutlook = New-Object -comobject outlook.application -ErrorAction stop -ErrorVariable "ApplicationError"
            $namespace = $comOutlook.GetNameSpace("MAPI")
            $contactObject = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderContacts)
            $contactList = $contactObject.Items | where-object {$_.categories -like "*$category*"}

            write-host "Found a total of $($contactList.count) contacts from Outlook." -ForegroundColor Cyan
            Write-Log -Message "Found a total of $($contactList.count) contacts from Outlook"
        }

        # Catch all other exceptions thrown by one of those commands
        catch {
            Write-Log -message "Cannot start Outlook" -Severity 3
            $OutlookError
            $ApplicationError
            if ([Environment]::Is64BitProcess) {
                throw ('Powershell must run in 32 bit mode to access Outlook 32 bit')
            }

        }
        # Execute these commands even if there is an exception thrown from the try block
        finally {
        }

    }

    process {
        foreach ( $name in $contactList ) {
            # More contact field details from this link => : http://msdn.microsoft.com/en-us/library/ee160254(v=exchg.80).aspx
            $props = @{
                'Categories'               = $name.Categories;
                'CreationTime'             = $name.CreationTime;
                'LastModificationTime'     = $name.LastModificationTime;
                'FullName'                 = $name.FullName;
                'FileAs'                   = $name.FileAs;
                'BusinessTelephoneNumber'  = $name.BusinessTelephoneNumber;
                'Business2TelephoneNumber' = $name.Business2TelephoneNumber;
                'HomeTelephoneNumber'      = $name.HomeTelephoneNumber;
                'Home2TelephoneNumber'     = $name.Home2TelephoneNumber;
                'MobileTelephoneNumber'    = $name.MobileTelephoneNumber;
                'OtherTelephoneNumber'     = $name.OtherTelephoneNumber;
                'BusinessFaxNumber'        = $name.BusinessFaxNumber;
                'HomeFaxNumber'            = $name.HomeFaxNumber;
                'OtherFaxNumber'           = $name.OtherFaxNumber;
                'Sensitivity'              = $name.Sensitivity
            }
            $contact = New-Object -TypeName PsObject -Property $props
            Write-Output $contact
        }

        if ($createCSV) {
            $ContactList | Export-Csv -path $csvFilePath -Encoding UTF8 -NoTypeInformation
            Write-Verbose "Contacts exported to file $csvFilePath"
            Write-Log -Message "Contacts exported to file $csvFilePath"
        }

    }

    end {

    }
}