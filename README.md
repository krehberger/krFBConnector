# Fritz!Box Connector

Windows Powershell module which use the Fritz!Box TR64-Api Webservices. In a first version cmdlets for creating and updating Fritz!Box phonebooks are implemented.

## Installation

To install the module in the personal modules folder run:

```Powershell
iex (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/krehberger/krFBConnector/master/Install.ps1')

```

## *** **Important** ***

 >When using the cmdlet 'Get-FBOlContacts':</br>If you have a 32 bit version of office installed, Powershell should **also** be running from x86 and not 64 bit!</br>If the module 'krFBConnector' cannot be loaded please check your Powershell ExecutionPolicy with
>
>``` Powershell
>Get-Executionpolicy
> ```
>
>and set it to 'RemoteSigned' with
>
>``` Powershell
> Set-Executionpolicy RemoteSigned -scope CurrentUser
> ```
>if necessary.

## Features

Currently the following cmdlets are implemented:

* **Add-FBPhonebook**</br>Adds a new phone book to the Fritz!Box.

* **Update-FBPhonebook**</br>Updates the Fritz!Box phone book with contacts from Microsoft Outlook. If the phone book to be updated does not exist, a new one is created.

* **Set-FBPhonebookEntry**</br>Adds new phone book entries to a Fritz!Box phonebook.

* **Remove-FBPhonebook**</br>Removes a phone book from the Fritz!Box.

* **Get-FBPhonebookList**</br>Shows all available phone books on the Fritz!Box.

* **Get-FBPhonebook**</br>Exports a Fritz!Box phone book to an xml file.

* **Get-FBOlContacts**</br>Reads Microsoft Outlook contacts.

* **Get-FBCSVContacts**</br>Reads contacts from an CSV file.</br>The CSV file must have the following fields:

```CSV
Categories, CreationTime, LastModificationTime, FullName, FileAs, BusinessTelephoneNumber, Business2TelephoneNumber, HomeTelephoneNumber, Home2TelephoneNumber, MobileTelephoneNumber, OtherTelephoneNumber, BusinessFaxNumber, HomeFaxNumber, OtherFaxNumber, Sensitivity
```

* **Get-FBExternalIP**</br>Get's the external IP address

## Usage Examples

### Add-FBPhonebook

```Powershell
Add-FBPhoenbook -phonebookName MyPhonebook
```

## Update-FBPhonebook

```Powershell
Update-FBPhonebook -pbName MyPhonebook
Update-FBPhonebook -pbID 1 -category FritzBox -pbName MyPhoenbook
```

## Get-FBOlContacts

```Powershell
Get-FBOlContacts -category FritzBox -CreateCSV  csvFilePath "c:\temp"
Get-FBOlContacts
```

## Set-FBPhonebookEntry

```Powershell
Get-FBOlContacts -category FritzBox | Set-FBPhonebookEntry -phonebookID 2
```
