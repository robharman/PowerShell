<#
.SYNOPSIS
    All Home Core PowerShell functions and variables.

.DESCRIPTION
    All Home Core functions and variables.

    Exports the following commands:
        <FunctionsToExport>
    Sets the following global variables:
        $PSEmailServer, $ITAlerts, $ITServices, $ITSupport,

.NOTES
    Requires:       Windows Compatibility module if running in PowerShell Core.
    Version:        <ModuleVersion>
    Author:         Rob Harman
    Written:        <Date>
    Version Notes:  Updated Module Name for consistency.
    To Do:          <ToDo>
#>
#Requires -Version 5.0

$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

foreach ($FunctionToImport in @($Public + $Private)) {
    try {
        Write-Verbose "Importing $($FunctionToImport.FullName)"
        . $FunctionToImport.FullName

    } catch {
        Write-Error "Failed to import function $($FunctionToImport.FullName): $_"
    }
}

## Export all of the public functions making them available to the user
foreach ($Function in $Public) {
    Export-ModuleMember -Function $Function.BaseName
}

. $PSScriptRoot\Public\Set-HomeVariables.ps1
Set-HomeVariables