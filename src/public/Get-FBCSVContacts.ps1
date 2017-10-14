<#
.SYNOPSIS
Read contacts from a CSV file

.DESCRIPTION
Reads contacts from an CSV file.
The CSV file must have the following fields:
    Categories, CreationTime, LastModificationTime, FullName, FileAs,
    BusinessTelephoneNumber, Business2TelephoneNumber, HomeTelephoneNumber, Home2TelephoneNumber,
    MobileTelephoneNumber, OtherTelephoneNumber, BusinessFaxNumber, HomeFaxNumber, OtherFaxNumber,
    Sensitivity

.PARAMETER CSVFilePath
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-FBCSVContacts {
    Param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "CSV File with contacts.")]
        [ValidateScript ( {(test-path $_)})]
        [string]
        $CSVFilePath
    )

    begin {
        $contacts = Import-Csv -Path $CSVFilePath -Encoding UTF8
    }

    process {
        Write-Output $contacts
    }

    end {

    }

}