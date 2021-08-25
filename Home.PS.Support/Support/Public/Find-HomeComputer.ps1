function Find-HomeComputer(){
    <#
    .SYNOPSIS
        Wrapper function to make finding computers in AD easier.
    .DESCRIPTION
        Easier than Get-ADComputer and more robust search than in ADUC. Finds computers with the search string anywhere
        in their name, not just at the start of it.
    .PARAMETER Computer
        Required, string. The search string to find in a computer's name.
    .PARAMETER Inactive
        Optional, switch. Set to true in order to search for disabled computer objects.
    .PARAMETER NoFormat
        Optional, switch. Set to return all found computers to the pipeline instead of outputting a formatted list.
    .EXAMPLE
        Find-HomeComputer mgmt
        Returns all computers with mgmt in their name.
    .Example
        Find-HomeComputer mgmt $False

        Returns all computers with MGMT in their name which are disabled.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
        To do:          Fix tests.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string[]]
        $Computer,

        [Parameter(Mandatory = $False)]
        [switch]
        $Inactive,

        [Parameter(Mandatory = $False)]
        [switch]
        $NoFormat
    )

    process {
        $ADComputer =   "*$Computer*"
        if ($Inactive) {
            $Computers  =   Get-ADComputer -filter {(Enabled -eq $False) -and (Name -like $ADComputer)} -Properties LastLogonDate,Description

        }else {
            $Computers  =   Get-ADComputer -filter {Name -like $ADComputer} -Properties LastLogonDate,Description
        }

        if ($Null -eq $Computers){
            Write-Output "No computers found."
        }

        # Format nicely if there's a whack of them to return
        if (($NoFormat -ne $True) -and ($Computers.Length -gt 5)) {
            $Computers | Sort-Object name | Format-Table Name

        }else {
            $Computers
        }
    }
}