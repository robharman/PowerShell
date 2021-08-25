function Confirm-HomeAdminRights {
    <#
    .SYNOPSIS
        Returns True if running in admin mode, false in user-mode.
    .DESCRIPTION
        Wrapper function to check if running with administrative rights.
    .EXAMPLE
        Confirm_HomeAdminRights

        Returns: True if running as admin.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    process {
        if ($PSVersionTable.Platform -eq 'UNIX') {
            return ((id -u) -eq 0)

        }else {
            $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            return $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }
    }
}