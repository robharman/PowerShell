<%
@"
<#
.SYNOPSIS
    $PLASTER_PARAM_ModuleDescription
.DESCRIPTION

.NOTES
    Requires:
    Version:        <ModuleVersion>
    Author:         Rob Harman
    Written:        <Date>
    Version Notes:  Initial Module
    To Do:          <toDo>
#>
#Requires -Version 5.0
"@
@'
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
'@
%>