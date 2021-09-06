function Connect-HomeExchangeShell(){
    <#
    .SYNOPSIS
        Opens an Exchange Online Shell.
    .DESCRIPTION
        Imports the installed Exchange Management Shell, and connects to on-Prem Exchange.
    .EXAMPLE
        Connect-HomeExchangeShell

        Connects to On-Prem Exchange Server
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
        Requires:       Requires the Exchange Management Tools be installed, and that you have connectivity to the
                        on-Prem Exchange Server.
    #>
    try {
        # Handle PSCore vs Windows PS module import for compatibility with PS 5.1+
        if ($PSVersionTable.PSEdition -eq 'Desktop'){

            Add-PSSnapin microsoft.exchange.management.powershell.snapin

        }elseif ($PSVersionTable.OS -like 'Microsoft*') {
            Write-Warning 'Not all Exchange commands are supported in PowerShell Core. Please run in Windows PowerShell'

            Invoke-Expression ". '$env:ExchangeInstallPath\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto -ClientApplication:ManagementShell -ErrorAction 'Stop'"

        }else{
            throw 'Exchange Online not supported in UNIX based shells.'
        }

    }catch {
        throw 'Exchange tools are not installed. Please install the Exchange tools.'
    }
}