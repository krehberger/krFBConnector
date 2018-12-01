<#
    .SYNOPSIS
       Download the module files from GitHub.

    .DESCRIPTION
        Download the module files from GitHub to the local client in the module folder.

    .Parameter ParameterName
        Description for a parameter in param definition section.
        Each parameter requires a separate description.
        The name in the description and the parameter section must match.

    .Parameter ModuleName
        Specifies the name of the module

    .Parameter InstallDirectory
        Specifies the directory where the module should be installed.
        In case no InstallDirectory will be provided the module will be installed in the default Windows Powershell
        module path $env:PSModulePath.

    .Parameter GitPath
        HyperLink to the Github repository of the module.

    .NOTES
        Version:        1.0
        Author:         Klaus Rehberger
        Creation Date:  2018-03-10
        Purpose/Change: Initial script development

#>

[CmdLetBinding()]
Param (
    [ValidateNotNullOrEmpty()]
    [String]$ModuleName = 'krFBConnector',
    [String]$InstallDirectory,
    [ValidateNotNullOrEmpty()]
    [String]$GitPath = 'https://raw.githubusercontent.com/krehberger/krFBConnector'
)

$Pre = $VerbosePreference
$VerbosePreference = 'continue'


Write-Verbose "$ModuleName module installation started"

$Files = @(
    'krFBConnector.psd1',
    'krFBConnector.psm1',
    'ExampleUpdateFBPhonebook.ps1',
    'ExamplePhonebook.csv',
    'LICENSE.txt',
    'src/public/Add-FBPhonebook.ps1',
    'src/public/Get-FBCSVContacts.ps1',
    'src/public/Get-FBExternalIP.ps1',
    'src/public/Get-FBOlContacts.ps1',
    'src/public/Get-FBPhonebook.ps1',
    'src/public/Get-FBPhonebokkList.ps1',
    'src/public/Remove-FBPhonebook.ps1',
    'src/public/Set-FBPhoenbookEntry.ps1',
    'src/public/Update-FBPhonebook.ps1',
    'src/private/Convert-SpecialCharacter.ps1',
    'src/private/Get-FBSecurityPort.ps1',
    'src/private/Write-Log.ps1'
)

Try {
    if (-not $InstallDirectory) {
        Write-Verbose "$ModuleName no installation directory provided"

        $PersonalModules = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath WindowsPowerShell\Modules

        if (($env:PSModulePath -split ';') -notcontains $PersonalModules) {
            Write-Warning "$ModuleName personal module path '$PersonalModules' not found in '`$env:PSModulePath'"
        }

        if (-not (Test-Path $PersonalModules)) {
            Write-Error "$ModuleName path '$PersonalModules' does not exist"
        }

        $InstallDirectory = Join-Path -Path $PersonalModules -ChildPath $ModuleName
        Write-Verbose "$ModuleName default installation directory is '$InstallDirectory'"
    }

    if (-not (Test-Path $InstallDirectory)) {
        New-Item -Path $InstallDirectory -ItemType Directory -EA Stop -Verbose | Out-Null
        New-Item -Path $InstallDirectory\src\private -ItemType Directory -EA Stop -Verbose | Out-Null
        New-Item -Path $InstallDirectory\src\Public -ItemType Directory -EA Stop -Verbose | Out-Null
        Write-Verbose "$ModuleName created module folder '$InstallDirectory'"
    }

    $WebClient = New-Object System.Net.WebClient

    $Files | ForEach-Object {
        $File = $installDirectory, '\', $($_ -replace '/', '\') -join ''
        $URL = $GitPath, '/', $_ -join ''
        "$URL $File"

        $WebClient.DownloadFile($URL, $File)
        Write-Verbose "$ModuleName installed module file '$_'"
    }

    Write-Verbose "$ModuleName module installation successful"
}
Catch {
    throw "Failed installing the module in the install directory '$InstallDirectory': $_"
}
$VerbosePreference = $Pre