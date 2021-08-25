function Connect-HomeExchangeOnlineShell(){
    <#
    .SYNOPSIS
        Opens an Exchange Online Management Shell.
    .DESCRIPTION
        Imports ExchangeOnlineManagement module and connects to a Office365 Exchange Online Management shell.
    .EXAMPLE
        Connect-HomeExchangeOnlineShell

        Connects to 365 Exchange Management shell.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
        Requires:       Requires the Exchange Online Management module.
    #>
    try {
        # Handle PSCore vs Windows PS module import for compatibility with PS 5.1+
        if ($PSVersionTable.PSEdition -eq "Desktop"){
            Import-Module ExchangeOnlineManagement -EA Stop

        }elseif ($PSVersionTable.OS -like "Microsoft*") {
            Write-Warning "Not all Exchange Online commands are supported in PowerShell Core. Please run in Windows PowerShell"
            Import-Module ExchangeOnlineManagement -EA Stop -UseWindowsPowerShell

        }else{
            throw "Exchange Online not supported in UNIX based shells."
        }

    }catch {
        throw "Exchange Online module not installed. Please install by following these directions https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps"
    }

    Connect-ExchangeOnline -UserPrincipalName $Env:MyUPN -ShowProgress $True
}