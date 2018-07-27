# Fritz!Box Connector
Windows Powershell module which use the Fritz!Box TR64-Api Webservices. In a first version cmdlets for creating and updating Fritz!Box phonebooks are impleted.
## Installation
To install the module in the personal modules folder run:
```
iex (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/krehberger/krFBConnector/master/Install.ps1')

```
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
