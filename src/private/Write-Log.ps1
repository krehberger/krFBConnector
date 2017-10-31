<#
.SYNOPSIS
Write log messages

.DESCRIPTION
Writes log messages to a log file

.PARAMETER Message
log file message

.PARAMETER Severity
Severity of log message

.EXAMPLE
Write-log -message "This is a log message"

.EXAMPLE
Write-log -message "This is a log message with very high severity" -Severity 3

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-10-27
    Purpose/Change: Initial script development

#>
function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('1', '2', '3')]
        [int]$Severity = 1 ## Default to a low severity. Otherwise, override
    )

    $line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'Message'  = $Message
        'Severity' = $Severity
    }

    # Ensure that $appDataDir and $LogFilePath is set to a global variable at the top of script
    # Create "appDataDir path if not exist"
    if (!(test-path -Path $appDataDir)) {
        new-item -ItemType Directory -path $appDataDir
    }
    $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation
}