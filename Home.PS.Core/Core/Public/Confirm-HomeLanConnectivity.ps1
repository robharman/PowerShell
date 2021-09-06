function Confirm-HomeLanConnectivity {
    <#
    .SYNOPSIS
        Quick check to see if we're connected to our internal network.
    .DESCRIPTION
        Quick DNS and connectivity check to see if we're internally connected. Returns a Boolean, accepts an
        alternative target to check.
    .PARAMETER Target
        Optional, string. Defaults to 'dc00'. The host target to test.
    .PARAMETER Domain
        Optional, string. Defaults to 'robharman.me'. The domain to test.
    .EXAMPLE
        Confirm-HomeLanConnectivity

        Returns: True if test succeeds.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [CmdletBinding()]
    param (
        [parameter( Mandatory = $false )]
        [string]
        $Target =   'dc00',

        [Parameter( Mandatory = $false )]
        [string]
        $Domain =   'robharman.me'

    )

    process {
        Write-Verbose "Testing $($Target).$Domain"
        try {
                $OnPrivateLAN   =   (Test-Connection "$Target.$Domain" -ErrorAction Stop -Count 1 -Quiet)

        }catch {

            $OnPrivateLAN       =   $False
        }
    }

    end {
        return $OnPrivateLAN
    }
}