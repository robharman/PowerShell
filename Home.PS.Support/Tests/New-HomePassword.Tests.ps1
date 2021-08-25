Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Support\Public\New-HomePassword.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Support\Public\New-HomePassword.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name New-HomePassword -Full | Select-Object -Property *
    }

    $Examples = $GetHelpContent.HelpInfo.Examples.Example | ForEach-Object { @{ Example = $_ } }

    it 'should have Get-Help info' -TestCases $GetHelpContent {
        $HelpInfo                   |   Should -Not -BeNullOrEmpty
    }

    it 'should have a synopsis' -TestCases $GetHelpContent {
        $HelpInfo.Synopsis      |   Should -Not -BeNullOrEmpty
    }

    it 'should have a description' -TestCases $GetHelpContent {
        $HelpInfo.Description   |   Should -Not -BeNullOrEmpty
    }

    it 'should have the author as the first note' -TestCases $GetHelpContent {
        $Notes                  =   $HelpInfo.AlertSet.Alert.Text -split '\n'

        $Notes[0].Trim()        |   Should -BeLike 'Author: *'
    }

    it 'should have the version notes as the second note' -TestCases $GetHelpContent {
        $Notes                  =   $HelpInfo.AlertSet.Alert.Text -split '\n'

        $Notes[1].Trim()        |   Should -BeLike 'Version Notes: *'
    }

    # Check parameters
    $Params                     =   Get-Help -Name New-HomePassword -Parameter * -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -and $_.Name -notin ('WhatIf', 'Confirm') } |

        ForEach-Object {
            @{
                Name            =   $_.Name
                Description     =   $_.Description.Text
            }
        }

    # Pulls actual code as an Abstract Syntax Tree (AST) to get parameters see the following devblog for more:
    # https://devblogs.microsoft.com/scripting/learn-how-it-pros-can-use-the-powershell-ast/
    $InternalCode = @{
        Code                    =   (Get-Content -Path 'function:/New-HomePassword' -ErrorAction Ignore).Ast
        Params                  =   $Params
    }

    it 'should have help info for all params' -TestCases $InternalCode -Skip:(-not ($Params -and $InternalCode.Code)) {
        @($Params).Count    |   Should -Be $Code.Body.ParamBlock.Parameters.Count
    }

    it 'should describe Parameter -<Name>' -TestCases $Params -Skip:(-not $Params) {
        $Description            |   Should -Not -BeNullOrEmpty
    }

    it 'should have at least one usage example' -TestCases $GetHelpContent {
        $HelpInfo.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
    }

    it 'should show what you get back' -TestCases $Examples {
        $Example.Remarks        |   Should -Not -BeNullOrEmpty
    }
}

Describe 'Mock Tests' {
    BeforeAll {
        mock -CommandName Get-Random -MockWith { return 1 } -ParameterFilter { $Maximum -gt 1 }
        mock -CommandName Get-Content -MockWith { return "11111	abacus`n# SIG # Begin signature block" }
        mock -CommandName Get-AuthenticodeSignature -MockWith { return @{ Status = "Valid" } }
    }

    beforeeach {
        . "$PSScriptRoot\..\Support\Public\New-HomePassword.ps1"
    }

    it 'should return a string' {

        New-HomePassword -SuppressWarning | should -BeOfType string

        Assert-MockCalled -CommandName Get-AuthenticodeSignature -Times 1
    }

    it 'should contain abacus' {

        New-HomePassword -SuppressWarning | should -BeLike *abacus*

        Assert-MockCalled -CommandName Get-AuthenticodeSignature -Times 1
    }

    it 'should mock Get-Random at least 24 times' {

        New-HomePassword -SuppressWarning

        Assert-MockCalled -CommandName Get-Random -Times 24
    }

    it 'should return a simple password when asked' {
        $SpecialCharacters  =   " `~!@#$%^&*()_+-=[]\{}|;':,./<>?""" -split ""
        $TestPassword       =   New-HomePassword -Simple -SuppressWarning

        $TestPassword.Substring( 0,( $TestPassword.Length -6 ) ) -match '^[a-zA-Z]+$' | should -BeTrue

        $TestPassword[-6] | should -BeIn $SpecialCharacters

        { [int]$TestPassword.Substring($TestPassword.Length -5) } | should -Not -Throw
    }

    it 'should return a long enough password' {
        ( New-HomePassword -SuppressWarning -NumberOfWords 5 ).split(' ').Count | should -BeGreaterOrEqual 5
    }

    it 'should not be too long' {
        ( New-HomePassword -SuppressWarning -NumberOfWords 3 ).split(' ').Count | should -BeLessOrEqual 6
    }

    it 'should be complex when not simple' {
        ( New-HomePassword -SuppressWarning) -match '^[a-zA-Z0-9]+$' | should -BeFalse
    }

    it 'should show a warning when you do not supress it ' {
        $WarningPreference  =   "Stop"
        { New-HomePassword | Out-Null } | should -Throw
    }

    it 'should not show a warning when you supress it ' {
        $WarningPreference  =   "Stop"
        { New-HomePassword -SuppressWarning } | should -Not -Throw
    }
}

describe 'New-HomePassword Failure tests' {
    BeforeAll {
        . $PSScriptRoot\..\Support\Public\New-HomePassword.ps1
    }

    it 'should throw when signature fails' {
        mock Get-AuthenticodeSignature { return @{ State = "NotSigned" } }

        { New-HomePassword } | should -Throw

        Assert-MockCalled Get-AuthenticodeSignature -Times 1
    }
}