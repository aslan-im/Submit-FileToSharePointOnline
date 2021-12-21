Function Submit-FileToSPO{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $SiteUrl,

        [Parameter(Mandatory)]
        [string]
        $LibraryName,

        [Parameter(Mandatory)]
        [string]
        $FolderName,

        [Parameter(Mandatory)]
        [string]
        $TargetFilePath,

        [Parameter(Mandatory)]
        [pscredential]
        $Credentials
    )

    $ClientDLLPath = "$PSScriptRoot\DLL\Microsoft.SharePoint.Client.dll"
    $ClientRuntimeDLL = "$PSScriptRoot\DLL\Microsoft.SharePoint.Client.Runtime.dll"

    if(!$(Test-Path $ClientDLLPath) -or !$(Test-Path $ClientRuntimeDLL)){
        throw "Please check DLL files in function root folder. DLL should be in $ClientDLLPath and $ClientRuntimeDLL"
        break
    }

    if (!$(Test-Path $TargetFilePath)) {
        throw "TargetFilePath: File can't be found. Please check the Path"
    }

    Add-Type -Path $ClientDLLPath
    Add-Type -Path $ClientRuntimeDLL

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $SpoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credentials.UserName, $Credentials.Password)

    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl) 
    $Context.Credentials = $SpoCredentials

    $Library = $Context.Web.Lists.GetByTitle($LibraryName)
    $Context.Load($Library.RootFolder)
    $Context.ExecuteQuery()

    $TargetFolder = $Context.Web.GetFolderByServerRelativeUrl($Library.RootFolder.ServerRelativeUrl + "/" + $FolderName)
    $FileStream = ([System.IO.FileInfo] (Get-Item $TargetFilePath)).OpenRead()
    $TargetFileName = Split-path $TargetFilePath -leaf

    $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
    $FileCreationInfo.Overwrite = $true
    $FileCreationInfo.ContentStream = $FileStream
    $FileCreationInfo.URL = $TargetFileName
    $FileUploaded = $TargetFolder.Files.Add($FileCreationInfo)

    $Context.Load($FileUploaded)
    try {
        $Context.ExecuteQuery()
    }
    catch {
        throw $_.Exception
        break
    }

    $FileStream.Close()
}