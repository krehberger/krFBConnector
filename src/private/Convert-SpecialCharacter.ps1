
<#
.SYNOPSIS
Convert special characters in string

.DESCRIPTION
Converts all special characters in a string

.PARAMETER Value
String to be converted

.EXAMPLE
Convert-SpecialCharacter -Value "Möwe"

.NOTES
    Version:        1.0
    Author:         Klaus Rehberger
    Creation Date:  2017-09-26
    Purpose/Change: Initial script development
    2017-10-18      Rename function from 'Convert-Umlaute' to 'Convert-SpecialCharacter'
#>
function Convert-SpecialCharacter {
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
        $value = $value -creplace ("$([char]0x0026)", '&amp;')
        $value = $value -creplace ("$([char]0x0027)", '&apos;')
        $value = $value -creplace ("$([char]0x003C)", '&lt;')
        $value = $value -creplace ("$([char]0x003E)", '&gt;')
        $value = $value -creplace ("$([char]0x0022)", '&quot;')

        return $value
    }

    end {
    }
}
