
<#
.SYNOPSIS
Convert Umlaute in string

.DESCRIPTION
Converts all Umlaute in a string

.PARAMETER Value
String to be converted

.EXAMPLE
Convert-Umlaut -Value "Möwe"

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-26
    Purpose/Change: Initial script development
#>
function Convert-Umlaut {
    [CmdletBinding()]

    Param(
        #Param Value
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [String]
        $value
    )

    begin {
    }

    process {
        $value = $value -creplace ("$([char]0x00C4)", 'Ae')
        $value = $value -creplace ("$([char]0x00D6)", 'Oe')
        $value = $value -creplace ("$([char]0x00DC)", 'Ue')
        $value = $value -creplace ("$([char]0x1E9E)", 'Ss')
        $value = $value -creplace ("$([char]0x00E4)", 'ae')
        $value = $value -creplace ("$([char]0x00F6)", 'oe')
        $value = $value -creplace ("$([char]0x00FC)", 'ue')
        $value = $value -creplace ("$([char]0x00DF)", 'ss')
        return $value
    }

    end {
    }
}
