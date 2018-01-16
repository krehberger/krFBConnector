# Fritz!Box Connector
Windows Powershell module which use the Fritz!Box TR64-Api Webservices. In a first version cmdlets for creating and updating Fritz!Box phonebooks are impleted.
## Installation
_Manually_
The module can be installed manually through downloading the Github Repo file "krFBConnector.zip" to the directory _$HOME\WindowsPowershell\Modules_ and decrompressing the zip file.

_With InstallModuleFromGitHub_
If you have installed the module  ["InstallModuleFromGitHub"](https://dfinke.github.io/2016/Quickly-Install-PowerShell-Modules-from-GitHub/) from Doug Finke you can install the module with the powershell command
_Install-ModuleFromGitHub -GitHubRepo krehberger/krFBConnector -Branch develop -verbose_. Be aware that the branch "develop" has the last beta version of the module!
The module "InstallModuleFromGitHub" can be installed with
 _Install-Module -Name InstallModuleFromGitHub -RequiredVersion 0.3_.

 ## Usage

 Currently the following cmdlets are implemented:
* **Update-FBPhonebook**
 Updates the Fritz!Box phonebook with contacts from Microsoft Outlook.
* **Set-FBPhonebookEntry**
Adds new phonebook entries to a Fritz!Box phonebook.
* **Remove-FBPhonebook**
Removes a phonebook from the Fritz!Box.
* **Get-GBPhonebookList**
Shows all available phonebooks on the Fritz!Box.
* **Get-FBPhonebook**
Exports a Fritz!Box phonebook to an xml file.
* **Get-FBOlContacts**
Reads Microsoft Outlook contacts.
