<#
.SYNOPSIS
    Create Shortcut for Updating the Fritz!Box phonebook
.DESCRIPTION
    Creates a Desktop and Windows Startmenu shortcut for updating the Fritz!Box phonebook

.PARAMETER pbName
    Fritz!Box phonebook name

.PARAMETER category
    Optional parameter Outlook category for filtering selected contacts.
    Calling the commandlet with no parameter, contacts with category "FritzBox" will be selected.

.EXAMPLE
    New-FBPhonebook -pbname MeinTelefonbuch -category Fritzbox
.EXAMPLE
     New-FBPhonebook -pbname MeinTelefonbuch
#>
function New-FBShortcut {
    [CmdletBinding()]
    param(
        # Param pbName
        [Parameter(ParameterSetName = 'pbName',
            Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true,
            HelpMessage = "Name of the Fritz!Box phonebook.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $pbName,

        # Param category
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Select only Outlook contacts which are assigned to this category. Default category is 'FritzBox'",
            ValueFromPipeline = $true)]
        [String]
        $category = 'FritzBox'

    )


    begin {
        $startMenuLocation = ([system.environment]::getfolderpath("StartMenu")) + '\Programs'
        $ShortcutLocation = "$env:USERPROFILE\Desktop\"
        $SourceFileLocation = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
        $lnkName = "UpdateFBPhonebook"
        $IconLocation = "C:\Windows\System32\shell32.dll"
        $IconId = 130
        $RunScript = {
            Set-Location -Path $HOME\Documents\WindowsPowerShell\Modules\krFBConnector
            Update-FBPhonebook -pbname {0} -category {1}
        }
        $RunScript -f $pbname, $category |
            out-file -FilePath "$Home\Documents\WindowsPowerShell\Modules\krFBConnector\_UpdateFBPhonebook.ps1" -force

        $lnkArgument = "-Nop -Executionpolicy bypass -NoExit & ""$HOME\Documents\WindowsPowershell\Modules\krFBConnector\_UpdateFBPhonebook.ps1"" -pbName $pbName -category $category"
    }

    process {
        $ShortcutLocation = $ShortcutLocation.split(",")

        foreach ($dir in $ShortcutLocation) {
            # create the shortcut object
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut("$($dir)$($lnkName).lnk")

            # program the shortcut will open
            $Shortcut.TargetPath = $SourceFileLocation
            # icon location & Id that the shortcut will use
            $Shortcut.IconLocation = "$IconLocation,$IconId"
            # any extra parameters that the shortcut may have
            $Shortcut.Arguments = "$lnkArgument"
            # save the modifications
            $Shortcut.Save()

            # Copy created link to Startmenu
            copy-item "$($dir)$($lnkName).lnk" -destination $startMenuLocation

        }
    }


    end {
        Write-Host "Shortcut $lnkName created on the Desktop and the Startmenu"
    }
}