function Update-HomeOutofOfficeMessage(){
    <#
    .SYNOPSIS
        Updates a user's Out of Office Message. Optionally disables the OOO.
    .DESCRIPTION
        Updates a user's Out of Office Message. Optionally disables the OOO. Accepts HTML as the OoO.
    .PARAMETER Disable
        Optional, switch. Disables OoO reply.
    .PARAMETER User
        Required, string. The username of the account whose OoO you're modifying.
    .PARAMETER OoOMessage
        Optional, string. Required if not disabling reply. You can use full HTML in here!
    .EXAMPLE
        Update-HomeOutOfOfficeMessage obumbler 'Oy will be oyt oyf the oyface.'

        Sets OBumbler's Out of office message to 'Oy will be oyt oyf the oyface.'
    .EXAMPLE
        Update-HomeOutOfOfficeMessage edean -disable

        Disables EDean's out of office message.
    .Notes
        Author:             Rob Harman
        Version Notes:      Initial refactoring
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory =  $false)]
        [string]
        $User   =   (read-host 'Please enter the UserName'),

        [Parameter(Mandatory =  $false)]
        [string]
        $OoOMessage    =   (read-host 'Please enter the Out of Office message as HTML'),

        [Parameter(Mandatory = $False)]
        [switch]
        $Disable
    )

    Confirm-HomeOpenShell 'Exchange'

    #Sanitize input
    if ($User -notlike '*@robharman.me') {
        $User += '@robharman.me'
    }

    if ($Disable) {
        $AutoReplyConfigurationParams = @{
            Identity            =   $User
            AutoReplyState      =   'Disabled'
        }
        if ($PSCmdlet.ShouldProcess($true)) {
            Set-MailboxAutoReplyConfiguration @AutoReplyConfigurationParams
        }

    }else {
        $AutoReplyConfigurationParams = @{
            Identity            =   $User
            AutoReplyState      =   'Enabled'
            InternalMessage     =   $OoOMessage
            ExternalMessage     =   $OoOMessage
            ExternalAudience    =   'All'
        }

        if ($PSCmdlet.ShouldProcess($true)) {
            Set-MailboxAutoReplyConfiguration @AutoReplyConfigurationParams
        }
    }
}