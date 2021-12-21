BeforeAll{
    . $PSScriptRoot\..\Submit-FileToSPO.ps1
}
Describe "Submit-FileToSPO" {
    BeforeAll{
        $ClientDLL = "$PSScriptRoot\..\DLL\Microsoft.SharePoint.Client.dll"
        $ClientRuntimeDLL = "$PSScriptRoot\..\DLL\Microsoft.SharePoint.Client.Runtime.dll"
        $DLLs = @($ClientDLL,$ClientRuntimeDLL)
    }
    It "DLL files exist" {
        foreach($DLL in $DLLs){
            Test-Path $DLL | Should -be $true
        }
        
    }

}