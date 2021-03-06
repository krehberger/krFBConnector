#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\src\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\src\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules

# Set variables visible to the module and its functions only
$script:port   # Security Port number of Fritz!Box
$script:appDataDir = "$env:LOCALAPPDATA\Rehberger\krFBConnector"
# Create "appDataDir if not exist"
if (-not(test-path -Path $script:appDataDir)) {
    $Null = new-item -path $script:appDataDir -ItemType Directory
}
$script:logFilePath = (Join-Path -path $script:appDataDir -childpath "krFBConnector.log")

#Export-ModuleMember -Function $Public.Basename
Export-ModuleMember -Function   'Add-FBPhonebook',
                                'Get-FBCSVContacts',
                                'Get-FBExternalIP',
                                'Get-FBOlContacts',
                                'Get-FBPhonebook',
                                'Get-FBPhonebookList',
                                'Remove-FBPhonebook',
                                'Set-FBPhonebookEntry',
                                'Update-FBPhonebook',
                                'New-FBShortcut'
