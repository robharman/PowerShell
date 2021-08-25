function Find-HomeOldComputer(){
    <#
    .SYNOPSIS
        Wrapper function to find all AD Computers that haven't logged in in $NumberOfDays
    .DESCRIPTION
        Finds all AD Computers which have not logged in against any of our domain controllers in $NumberOfDays
        and outputs their names into a formatted table.
    .PARAMETER NumberOfDays
        Required, integer, default 30. Maximum number of days ago that a computer must have logged in since.
    .PARAMETER IncludeServers
        Optional, switch. If specified the list of computers will include Windows Servers.
    .PARAMETER ServersOnly
        Optional, switch. If specified the list returned will not include
    .PARAMETER LocalOnly
        Optional, switch. If specified the query is only run against a local domain controller.
    .PARAMETER ReportOnly
        Optional, switch. If specified returns formatted list. Useful for maintenance, not scripting.
    .EXAMPLE
        Find-HomeOldComputer

        Returns all non-server computers which haven't logged in against any domain controller in the last 30 days.
    .EXAMPLE
        Find-HomeOldComputer 60 -IncludeServers -LocalOnly

        Checks against local DC only and returns a list of all computers which haven't logged in in the last 60 days.
    .EXAMPLE
        Find-HomeOldComputer -ServersOnly -LocalOnly

        Checks against local DC only and returns a list of all servers which haven't logged in in the last 30 days.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory    =   $false)]
        [int32]
        $NumberOfDays = 30,

        [Parameter(Mandatory    =   $false)]
        [switch]
        $IncludeServers,

        [Parameter(Mandatory    =   $false)]
        [switch]
        $ServersOnly,

        [Parameter(Mandatory    =   $false)]
        [switch]
        $ReportOnly
    )
    $CutOffDate         =   (Get-Date).AddDays(-$NumberOfDays).ToString()
    $DCList             =   Get-ADDomainController -filter *
    $OldComputers       =   @()

    foreach ($DomainController in $DCList){
        Write-Verbose "Querying against $($DomainController.Name)..."
        # Build list and make sure we're not adding duplicate computers

        $ADComputerParams    =   @{
            Properties  =   'OperatingSystem','LastLogonDate'
            F           =   '*'
            Server      =   $DomainController.Name
        }
        $OldComputers   =   Get-ADComputer @ADComputerParams | Where-Object { ($_.LastLogonDate -lt $CutOffDate) }
    }

    # Filter list as needed
    if ($ServersOnly) {
        $OldComputers   =   $OldComputers | Where-Object {$_.OperatingSystem -like "*Server*"}

    }elseif (-not $IncludeServers){
        $OldComputers   =   $OldComputers | Where-Object {$_.OperatingSystem -notlike "*Server*"}
    }

    if ($OldComputers.Count -eq 0) {throw "No old computers found."}
    # Format Output as needed
    if ($ReportOnly){

        Write-Output $OldComputers | Format-Table Name
    }else{

        return $OldComputers
    }
}