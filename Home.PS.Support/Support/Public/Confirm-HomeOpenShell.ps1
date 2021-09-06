function Confirm-HomeOpenShell(){
    <#
    .SYNOPSIS
        Checks to see if there is an open shell and opens one if there is not.
    .DESCRIPTION
        Checks to see if there is an open shell and opens one if there is not. Defaults to Exchange.

        Built as a workaround to the ever-updating commands and modules Microsoft has for Exchange management.
        Connect-HomeExchangeOnlineShell and Connect-Home365Security Shell will be updated to address module changes.

        This function should be used to open shells in all support/infrastructure cmdlets to ensure reliability.

        Extensible to add additional ShellTypes. Simpy add the appropriate computer name in the remote shell to check
        and add another Connect-HomeShell wrapper function like Connect-HomeExchangeOnlineShell.
    .PARAMETER ShellType
        Optional, string. Defaults to 'Exchange'. Set the type of shell you want to connect.
    .EXAMPLE
        Confirm-HomeOpenShell

        Returns: True if there's an open Exchange Online Management Shell in the session.
    .EXAMPLE
        Confirm-HomeOpenShell -ShellType Security

        Returns: True if there's an open Security and Compliacnce Management Shell in the session.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $False)]
        [string]
        $ShellType          =   'Exchange'
    )

    $ShellURLs = @{
        Exchange                    =   'outlook.office365.com'
        Security                    =   '*.compliance.protection.outlook.com'
    }

    if (!($ShellURLs.ContainsKey($ShellType))) {
        throw 'Invalid shell type'
    }

    $ActiveHomePSSession            =   $False
    $ImportedShells                 =   Get-PSSession

    foreach ($Shell in $ImportedShells){
        if ($Shell.ComputerName -like $ShellURLs.$ShellType){
            $ActiveHomePSSession    =   $True

        }
    }

    if (-Not $ActiveHomePSSession){
        switch ($ShellType){
            'Exchange' {
                Connect-HomeExchangeOnlineShell

            } 'Security' {
                Connect-Home365SecurityShell
            }
        }
    }
}