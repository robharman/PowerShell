function Connect-Home365SecurityShell(){
    <#
    .SYNOPSIS
        Opens an Exchange Online Compliance Shell.
    .DESCRIPTION
        Imports ExchangeOnlineManagement module and connects to the Office365 Compliance Centre.
    .EXAMPLE
        Connect-Home365SecurityShell

        Connects to 365 Compliance Centre shell.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
        Requires:       Requires the Exchange Online Management module.
    #>
    try {
        # Handle PSCore vs Windows PS module import for compatibility with PS 5.1+
        if ($PSVersionTable.PSEdition -eq "Desktop"){
            Import-Module ExchangeOnlineManagement -ErrorAction Stop

        }elseif ($PSVersionTable.OS -like "Microsoft*") {
            Write-Warning "Not all Exchange Online commands are supported in PowerShell Core. Please run in Windows PowerShell"
            Import-Module ExchangeOnlineManagement -ErrorAction Stop -UseWindowsPowerShell

        }else{
            throw "Exchange Online not supported in UNIX based shells."
        }

    }catch{
        throw "Exchange Online module not installed. Please install by following these directions https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps"
    }

    Connect-IPPSSession -UserPrincipalName $Env:MyUPN
}