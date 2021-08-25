Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Core\Public\New-HomeRandomString.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Core\Public\New-HomeRandomString.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name New-HomeRandomString -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name New-HomeRandomString -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/New-HomeRandomString' -ErrorAction Ignore).Ast
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

describe 'New-HomeRandomString tests' {
    context 'Basic tests' {
        BeforeAll {
            . "$PSScriptRoot\..\Core\Public\New-HomeRandomString.ps1"
        }

        it 'should return a string' {

            New-HomeRandomString                | should -BeOfType string
        }

        it 'should return an 8 character long string' {

            (New-HomeRandomString).Length       | should -BeExactly 8
        }

        it 'should return a 16 character long string' {

            (New-HomeRandomString -RandomStringLength 16 ).Length   | should -BeExactly 16
        }

        it 'should return an alphabetic string' {

            New-HomeRandomString                | should -Match '^[a-z]+$'
        }

        it 'should return an alphanumeric string when asked' {

            $AlphaNumString = New-HomeRandomString -AlphaNumeric
            $AlphaNumString | should -Match '[a-z]|[0-9]'
        }

        it 'should return a 16 character long alphanumeric string when asked' {

            $AlphaNumString = New-HomeRandomString -AlphaNumeric 16
            $AlphaNumString                     | should -Match '[a-z]|[0-9]'
            $AlphaNumString.Length              | should -BeExactly 16

        }

        it 'should return a 16 character long alphanumeric string, allowing capitals when asked' {

            $AlphaNumString = New-HomeRandomString -AlphaNumeric -IncludeCapitals 16
            $AlphaNumString                     | should -Match '[a-z]|[A-Z]|[0-9]'
            $AlphaNumString.Length              | should -BeExactly 16

        }

        it 'should return a 16 character long string with any characters' {

            $AlphaNumString = New-HomeRandomString -AlphaNumeric 16
            $AlphaNumString.Length              | should -BeExactly 16

        }

        it 'should work with alias <Alias>' -TestCases @(
            @{ Alias = 'an'   ; Long = $false ; RegEx = '[a-z]|[0-9]'}
            @{ Alias = 'caps' ; Long = $false ; RegEx = '[a-z]|[A-Z]|[0-9]'}
            @{ Alias = 'all'  ; Long = $false ; RegEx = '.'}
            @{ Alias = 'an'   ; Long = $True  ; RegEx = '[a-z]|[0-9]'}
            @{ Alias = 'caps' ; Long = $True  ; RegEx = '[a-z]|[A-Z]|[0-9]'}
            @{ Alias = 'all'  ; Long = $True  ; RegEx = '.'}
        ) {
            param (
                $Alias,
                $Long,
                $Match
            )

            if ($Long) {
                $Params =   @{
                    RandomStringLength  =   16
                    $Alias              =   $true
                }

                $AlphaNumString = New-HomeRandomString @Params
                $AlphaNumString                     | Should -Match $RegEx
                $AlphaNumString.Length              | should -BeExactly 16

            }else {
                $Params = @{$Alias  =   $True}

                $AlphaNumString = New-HomeRandomString @Params
                $AlphaNumString                     | Should -Match $RegEx
                $AlphaNumString.Length              | should -BeExactly 8
            }
        }
    }
}

Describe 'New-HomeRandomString mock tests' {
    context 'Mock tests' {
        BeforeAll {
            . "$PSScriptRoot\..\Core\Public\New-HomeRandomString.ps1"
            mock -CommandName Get-Random -MockWith { return 97 }
        }

        it "should return an 8 character long string of a's" {

            New-HomeRandomString            | should -Match 'aaaaaaaa'

            Assert-MockCalled -CommandName 'Get-Random' -Times 8
        }

        it "should return an 32 character long string of a's" {

            New-HomeRandomString 32         | should -Match 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

            Assert-MockCalled -CommandName 'Get-Random' -Times 32
        }

    }
}

describe 'New-HomeRandomString Failure tests' {
    BeforeAll {
        . "$PSScriptRoot\..\Core\Public\New-HomeRandomString.ps1"
    }

    it 'should throw when you pass a string' {
        {New-HomeRandomString 'B'} | Should -Throw
    }


}