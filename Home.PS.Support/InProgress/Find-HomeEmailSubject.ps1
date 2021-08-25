function Find-HomeEmailSubject(){
    <#
    .SYNOPSIS
        Runs a message trace for emails with the specified subect over the last two days by default.
    .DESCRIPTION
        Connects to Exchange Online and runs a message trace for emails with the specified subect over the last two
        days by default.
    .PARAMETER  Days
        Optional, integer. Defaults to 2. Number of days back to search.
    .PARAMETER  Subject
        Required, string. The subject of message to search.
    .EXAMPLE
        Find-HomeEmailSubject 'test subject'

        Returns all emails with the subject 'Test Subject'
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        [string]
        $Subject,

        [Parameter(Mandatory =  $false)]
        [int]$Days = 2
    )

    # Check for an existing 365 shell, and open one if none exists
    Confirm-HomeOpenShell "Exchange"

    $StartDate  =   (Get-Date).AddDays(-$Days)
    $EndDate    =   Get-Date

    return Get-MessageTrace -StartDate $StartDate -EndDate $EndDate | Where-Object {$_.Subject -like "*$Subject*"} | Format-Table
}