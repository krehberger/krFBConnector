<#
.SYNOPSIS
Update Fritz!Box phonebook

.DESCRIPTION
Update Fritz!Box phonebook with contacts from Microsoft Outlook.
The Cmdlet Update-FBPhonebook can be called with the parameter <pbID> or <pbName>.
In case the phonebook with the name <pbName> does not exist in the Fritz!Box a new phonebook
will be created.
If the Cmdlet is called with a non existing <pbID> the Cmdlet stops with an error message.

.PARAMETER category
Select only contacts from Outlook with the category <category>.
Default category is 'FritzBox'

.PARAMETER pbID
Fritz!Box phonebook ID

.PARAMETER pbName
Fritz!Box phonebook Name

.EXAMPLE
Update-FBPhonebook -pbID 1

.EXAMPLE
Update-FBPhonebook -pbName MeinPhonebook

.EXAMPLE
Update-FBPhonebook -category Phonebook -pbID 1

.EXAMPLE
Update-FBPhonebook -category Phonebook -pbName MeinPhonebook

.EXAMPLE
Update-FBPhonebook 1

.EXAMPLE
Update-FBPhonebook 1 'Phonebook'

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-25
    Purpose/Change: Initial script development
#>
function Update-FBPhonebook {
    [CmdletBinding()]
    Param (
        # Param category
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Select only Outlook contacts which are assigned to this category. Default category is 'FritzBox'",
            ValueFromPipeline = $true)]
        [String]
        $category = 'FritzBox',

        # Param pbID
        [Parameter(ParameterSetName = 'pbID',
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "ID of the Fritz!Box phonebook [Standard phonebook ID is 0].")]
        [ValidateNotNullOrEmpty()]
        [int]
        $pbID,

        # Param pbName
        [Parameter(ParameterSetName = 'pbName',
            Mandatory = $true,
            Position = 2,
            ValueFromPipeline = $true,
            HelpMessage = "Name of the Fritz!Box phonebook.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $pbName
    )

    $phonebookID = $pbID
    $phonebookName = $pbName

    $pSet = $PSCmdlet.ParameterSetName
    # Before the phonebook with the ID $pbID will be updated,
    # first the name of the phonebook will be determined,
    # then the existing phonebook will be saved on disk and deleted from the Fritz!Box.
    # Afterwards a new phonebook with identical name will be created and all
    # selected Outlook contacts added.
    if ($pSet -eq 'PbID') {
        try {
            $phonebookName = (Get-FBPhonebook -phonebookID $pbID).name
        }
        catch {
            throw "Phonebook with ID $pbID doesn't exist. Please start the Cmdlet 'Update-FBPhonebook' with the Parameter -pbName."
        }
    }
    else {
        # Find $phonebookID with name $pbName in Fritz!Box phonebooklist
        $phonebookID = Get-FBPhonebookList | ForEach-Object {if ((Get-FBPhonebook -phonebookid $_).name -eq $pbName) {$_; return}
        }
    }
    if ($phonebookID) {
        Remove-FBPhonebook -phonebookID $phonebookID -backupBefore
    }

    Add-FBPhonebook -phonebookName $phonebookName

    if ($pSet -eq 'PbName') {
        # Find $phonebookID with name $pbName in Fritz!Box phonebooklist
        $phonebookID = Get-FBPhonebookList | ForEach-Object {if ((Get-FBPhonebook -phonebookid $_).name -eq $pbName) {$_; return}
        }
    }
    Get-FBOlContacts -category $category | Set-FBPhonebookEntry -phonebookID $phonebookID

}