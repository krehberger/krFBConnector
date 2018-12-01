
# -----------------------------------------------------------------------------
# Script: Install.ps1
# Author: Klaus Rehberger
# Date: 01.12.2018
# Version: 1.0.0
# Purpose: Install the latest module release 'krFBConnector' from Github
#          repository https://github.com/krehberger/krFBConnector
# Source:
# Synopsis:
# Usage: Call
#        iex (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/krehberger/krFBConnector/master/Install.ps1')
#        in a terminal.
#
# -----------------------------------------------------------------------------
# Maintenance History
# -------------------
# Name            Date        Version  Description
# ----------------------------------------------------------------------------
# Klaus Rehberger 01.12.2018  1.0.0    Initial Version
#
# -----------------------------------------------------------------------------


$repo = "krehberger/krFBConnector"
$file = "krFBConnector.zip"

$releases = "https://api.github.com/repos/$repo/releases"

Write-Host Determining latest release
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name

$download = "https://github.com/$repo/releases/download/$tag/$file"
$name = $file.Split(".")[0]
$download_path = "$env:USERPROFILE\Downloads\$name-$tag.zip"

Write-Host Dowloading latest release
Invoke-WebRequest $download -Out $download_path

Get-Item $download_path | Unblock-File

$user_module_path = $env:PSModulePath -split ";" -match $env:USERNAME -notmatch "vscode"

if (-not (Test-Path -Path $user_module_path)) {
    New-Item -Path $user_module_path -ItemType Container | Out-Null
}

Write-Host Extracting release files
Expand-Archive $download_path -DestinationPath $user_module_path[0] -Force

# Removing temp files
Remove-Item $download_path -Force

write-host "Module $name installed in the directory $user_module_path[0]"
