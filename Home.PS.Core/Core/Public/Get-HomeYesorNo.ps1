function Get-HomeYesorNo {
    <#
    .SYNOPSIS
        Prompts a user for a yes or no, and returns a boolean.
    .DESCRIPTION
        Prompts the user for an answer to a yes or no question, and keeps prompting until it can make sense of it.

        Simple wrapper script because I kept having to add this all over the stupid place.
    .PARAMETER Question
        String. Required. The yes or no question provided to the user. This will automatically have a "?" added if
        you happen to forget, and "(Yes/No)" will always be appended to it, so don't worry about adding that or
        it'll look silly in your user prompts.
    .EXAMPLE
        Get-HomeYesorNo "Have you read the Dark Tower series"

        Will prompt the user:
        "Have you read the Dark Tower series? (Yes/No):"

        Then return a $True/$False.
    .NOTES
        Author:         Rob Harman
        Version Notes:  Initial refactoring.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    Param (
        [Parameter( Mandatory = $true )]
        [string]
        $Question
    )

    process {
        if (!($Question.EndsWith("?"))){
            $Question = $Question + "?"
        }

        $ExpandedPrompt = $Question + " (Yes/No)"

        $Answer = read-Host $ExpandedPrompt

        if ("YES","YE","Y" -Contains $Answer) {
            $true

        }elseif ("NO", "N" -Contains $Answer) {
            $false

        }else {
            .\Get-HomeYesorNo.ps1 $Question
        }
    }
}