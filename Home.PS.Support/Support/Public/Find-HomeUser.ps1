function Find-HomeUser(){
    <#
    .SYNOPSIS
        Searches AD users for some part of their name.
    .DESCRIPTION
        Finds AD users which match the search string. Returns the object if there's 3 or less, or a list of all matching users if not.

        Returns the user with their manager as figuring out who has one set is one of the most common uses for this function.
    .PARAMETER User
        Required, string. The search string
    .PARAMETER Disabled
        Optional, switch. Searches disabled users only.
    .PARAMETER All
        Optional, switch. Searches all users, regardless of enabled or disabled.
    .PARAMETER ReportOnly
        Optional, switch. If specified returns formatted list. Useful for maintenance, not scripting.
    .EXAMPLE
        Find-HomeUser Eddie

        Returns all active users with Eddie in their name..
    .EXAMPLE
        Find-HomeUser Roland -Disabled

        Returns all disabled users with Roland in their name..
    .EXAMPLE
        Find-HomeUser Susannah -all

        Returns all userswith Susannah in their name, regardless of enabled state.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelinebyPropertyName=$True)]
        [string]$User,

        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelinebyPropertyName=$True)]
        [switch]$Disabled,

        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelinebyPropertyName=$True)]
        [switch]$All,

        [Parameter(
            ValueFromPipeline=$True,
            ValueFromPipelinebyPropertyName=$True)]
        [switch]$ReportOnly
    )

    begin {
        # Stop PowerShell from whingning about the asterisks
        $ADUser = "*$User*"
    }

    process {
        #Find disabled users
        if ($Disabled) {
            $Users = Get-ADUser -f {(Enabled -eq $False) -and (Name -like $ADUser)} -Properties Manager
        }

        # Find all active/inactive users
        elseif ($All) {
            $Users = Get-ADUser -f {Name -like $ADUser} -Properties Manager

        }else {
            $Users = Get-ADUser -f {(Enabled -eq $True) -and (Name -like $ADUser)} -Properties manager
        }

        # Catch no users.
        if ($Null -eq $Users) {
            throw "No users found."
        }

        # Pretty up large output.
        if ($ReportOnly) {
            Write-Output $Users | Sort-Object Name | Format-Table Name,UserPrincipalName

        }else {
            return $Users
        }
    }
}