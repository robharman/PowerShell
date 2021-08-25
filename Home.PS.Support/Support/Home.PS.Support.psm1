<#
.SYNOPSIS
    PowerShell core Support module.
.DESCRIPTION
    All Support management PowerShell commands.

    Exports the following commands:
        <FunctionsToExport>

    Exports the following aliases:
        ems         Connect-HomeExchangeShell
        3ems        Connect-HomeExchangeOnlineShell
        3sec        Connect-Home365SecurityShell
        fea         Find-HomeEmailAddress
        fes         Find-HomeEmailSubject
        fg          Find-HomeGroup
        fgm         Find-HomeGroupMembers
        fpc         Find-HomeComputer
        fu          Find-HomeUser
        gad         Get-ADUser
        upooo       Update-HomeOutofOfficeMessage
        npwd        New-HomePassword
.NOTES
    Requires:
    Version:        <ModuleVersion>
    Author:         Rob Harman
    Written:        <Date>
    Version Notes:  Initial Module
    To Do:          <toDo>
#>
#Requires -Version 5.0
#Requires -Module ActiveDirectory
$Public     =   @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private    =   @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

foreach ($FunctionToImport in @($Public + $Private)) {
    try {

        Write-Verbose "Importing $($FunctionToImport.FullName)"
        . $FunctionToImport.FullName

    }catch {

        Write-Error "Failed to import function $($FunctionToImport.FullName): $_"
    }
}

foreach ($Function in $Public) {
    Export-ModuleMember -Function $Function.BaseName
}

#region Aliases
#region Standard commands
###################################
Set-Alias   GAD     Get-ADUser
Set-Alias   GPC     Get-ADComputer
#endregion
#region Custom Commands
###################################
Set-Alias   ems     Connect-HomeExchangeShell
Set-Alias   3ems    Connect-HomeExchangeOnlineShell
Set-Alias   3sec    Connect-Home365SecurityShell
Set-Alias   fea     Find-HomeEmailAddress
Set-Alias   fes     Find-HomeEmailSubject
Set-Alias   fg      Find-HomeGroup
Set-Alias   fgm     Find-HomeGroupMembers
Set-Alias   fpc     Find-HomeComputer
Set-Alias   fu      Find-HomeUser
Set-Alias   upooo   Update-HomeOutofOfficeMessage
Set-Alias   npwd    New-HomePassword
#endregion
#region exports
Export-ModuleMember -Alias "gad"
Export-ModuleMember -Alias "gpc"
Export-ModuleMember -Alias "ems"
Export-ModuleMember -Alias "3ems"
Export-ModuleMember -Alias "3sec"
Export-ModuleMember -Alias "fea"

Export-ModuleMember -Alias "fes"
Export-ModuleMember -Alias "fg"
Export-ModuleMember -Alias "fgm"
Export-ModuleMember -Alias "fpc"
Export-ModuleMember -Alias "fu"
Export-ModuleMember -Alias "upooo"

Export-ModuleMember -Alias "npwd"