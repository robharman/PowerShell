function Set-HomeVariables {
    <#
    .SYNOPSIS
        Sets common enterprise variables.
    .DESCRIPTION
        Sets the following global variables:
        $PSEmailServer, $ITAlerts, $ITServices, $ITSupport,
    .EXAMPLE
        Set-HomeVariables

        Sets the following global variables: $PSEmailServer, $ITAlerts, $ITServices, $ITSupport,
    .NOTES
        Author:         Rob Harman
        Version Notes:  Refactor for CI/CD
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param()

    # Defaults
    Set-Variable -Scope Global -Name PSEmailServer -Value 'smtp.robharman.me'

    # Home variables
    Set-Variable -Scope Global -Name ITAlerts -Value 'italerts@robharman.me'
    Set-Variable -Scope Global -Name ITSupport -Value 'itsupport@robharman.me'
    Set-Variable -Scope Global -Name ITServices -Value 'itservices@robharman.me'
}