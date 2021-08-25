function New-HomeRandomString {
    <#
    .SYNOPSIS
        Returns a random lowercase alphabetic string.
    .DESCRIPTION
        Takes an integer as a string lengh and returns a random alphabetic string that long.
    .PARAMETER RandomStringLength
        Optional. Integer. Defaults to 8. Sets length of randomly generated alphabetic string to return.
    .PARAMETER AlphaNumeric
        Optional. Switch. Alias: 'an'. Returns an alphanumeric string instead of an alphabetic one.
    .PARAMETER IncludeCapitals
        Optional. Switch. Alias: 'caps'. Adds capital letters to the list of available characters.
    .PARAMETER AllCharacters
        Optional. Switch. Alias: 'all'. Returns an alphanumeric string instead of an alphabetic one.
    .EXAMPLE
        New-HomeRandomString 16

        Returns: ksowagdhrlipznyt
    .EXAMPLE
        New-HomeRandomString -AlphaNumeric

        Returns: f74gb82m
    .EXAMPLE
        New-HomeRandomString -AlphaNumeric -IncludeCapitals

        Returns: J89Nbc02
    .EXAMPLE
        New-HomeRandomString -All

        Returns: LdC1D@ah
    .NOTES
        Author:         Rob Harman
        Version Notes:  Updated Module Name for consistency.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [int]
        $RandomStringLength  =   8,

        [Parameter(Mandatory = $false)]
        [Alias('an')]
        [switch]
        $AlphaNumeric,

        [Parameter(Mandatory = $false)]
        [Alias('caps')]
        [switch]
        $IncludeCapitals,

        [Parameter(Mandatory = $false)]
        [Alias('all')]
        [switch]
        $AllCharacters
    )

    if ($AllCharacters) {
        return (-join (1..$RandomStringLength | ForEach-Object {(40..126) | Get-Random | ForEach-Object {[char]$_}}))

    }elseif ($AlphaNumeric) {
        if ($IncludeCapitals) {
            return (-join (1..$RandomStringLength | ForEach-Object {
                switch (Get-Random(0,2)) {
                    0   { (48..57)  | Get-Random | ForEach-Object {[char]$_} }
                    1   { (65..90)  | Get-Random | ForEach-Object {[char]$_} }
                    2   { (97..122) | Get-Random | ForEach-Object {[char]$_} }
                }
            }))

        }else {
            return (-join (1..$RandomStringLength | ForEach-Object {
                switch (Get-Random(0,1)) {
                    0   { (48..57) | Get-Random | ForEach-Object {[char]$_} }
                    1   { (97..122) | Get-Random | ForEach-Object {[char]$_} }
                }
            }))
        }

    }elseif ($IncludeCapitals) {
        return (-join (1..$RandomStringLength | ForEach-Object {
            switch (Get-Random(0,1)) {
                0   { (65..90) | Get-Random | ForEach-Object {[char]$_} }
                1   { (97..122) | Get-Random | ForEach-Object {[char]$_} }
            }
        }))

    }else {
        return (-join (1..$RandomStringLength | ForEach-Object {(97..122) | Get-Random | ForEach-Object {[char]$_}}))
    }
}