function Find-HomeEmailAddress(){
    <#
    .SYNOPSIS
        Searches AD Objects for a particular email address.
    .DESCRIPTION
        Finds AD Object to which the email address is attached. Greps through all user accounts and contacts, so it may
        take a while.

        Returns the object's name, DN, all email addresses and their logon name if it is a user account.

        The logon name is /generally/ the same as the user email's local-part, but not always.

        This function also returns contacts.
    .PARAMETER EmailAddress
        Required, string. Can be either the full address or just the name.
    .PARAMETER IncludeContacts
        Optional, switch. If specified will return results that match contacts synced from IH. Otherwise will only
        include local AD objects.
    .PARAMETER FormatOutput
        Optional, switch. If specified you get a printed formatted list instead of a usable object.
    .EXAMPLE
        Find-HomeEmailAddress rdeschain@robharman.me

        Returns Roland Deschain's information.
    .EXAMPLE
        Find-HomeEmailAddress support

        Retrurns information about all domain accounts which have the word 'support' in their email address.
    .EXAMPLE
        Find-HomeEmailAddress support -IncludeContacts

        Returns information about all domain accounts, and contacts synced from home which have the word "support" in
        their email address.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory = $True )]
        [ValidateScript({
            if ($_ -notlike '*@*.*') {
                throw "Expected an email address, got: $_"

            }else { return $True }
        })]
        [string]
        $EmailAddress,

        [Parameter( Mandatory = $false )]
        [switch]
        $IncludeContacts,

        [Parameter( Mandatory = $False )]
        [switch]
        $FormatOutput
    )

    # Format email address for search.
    $Email = "smtp:*$EmailAddress*"

    if ($IncludeContacts) {
        $ADObjects  =   Get-ADObject -Properties SAMAccountName,ProxyAddresses -f {proxyaddresses -like $Email}

    }else{
        $ADObjects  =   Get-ADObject -Properties SAMAccountName,ProxyAddresses -f {proxyaddresses -like $Email} |
            where-object {$_.DistinguishedName -notlike '*OU=Home Contacts*'}
    }

    if ($ADObjects.Count -eq 0) {
        throw 'No users found'
    }
    # Build list of objects to return.
    $UsersWithAddresses = @()
    if ($FormatOutput) {
        foreach ($ADObject in $ADObjects){
            $ProxyAddresses =   ''

            # Get all their email addresses
            foreach ($ProxyAddress in $ADObject.ProxyAddresses){
                if ($ProxyAddress -Like 'smtp*'){
                    $ProxyAddresses +=  $ProxyAddress + "`n"
                }
            }
            # Build a nice little object to cleanly format output
            $Properties = @{
                'ObjectDN'          =   $ADObject.DistinguishedName
                "Object's Name"     =   $ADObject.Name
                'Logon Name'        =   $ADObject.SAMAccountName
                'ProxyAddresses'    =   $ProxyAddresses.Trim()
            }
            $UserWithAddresses      =   New-Object -TypeName PSObject -Property $Properties
            $UsersWithAddresses    +=   $UserWithAddresses
        }
        return $UsersWithAddresses | Format-List

    }else {
        return $ADObjects
    }
}