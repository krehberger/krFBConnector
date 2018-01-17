<#
Example script for creating/updating the Fritz!Box phonebook with name "MeinTelefonbuch"
and Outlook conatacts with category "FritzBox".

For calling the script a desktop shortcut can be created with the following Target field value:
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noexit & "$HOME\Documents\WindowsPowershell\Modules\krFBConnector\ExampleUpdateFBPhonebook.ps1"
#>
import-module .\krFBConnector.psm1 -Force
Update-FBPhonebook -pbname MeinTelefonbuch -category FritzBox
