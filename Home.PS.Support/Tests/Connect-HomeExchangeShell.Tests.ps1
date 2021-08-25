Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        # We have to use Invoke-Expression in order to connect to the Exchange Shell in PowerShell Core.
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule | Where-Object RuleName -ne 'PSAvoidUsingInvokeExpression')) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Support\Public\Connect-HomeExchangeShell.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Support\Public\Connect-HomeExchangeShell.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name Connect-HomeExchangeShell -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name Connect-HomeExchangeShell -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/Connect-HomeExchangeShell' -ErrorAction Ignore).Ast
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

describe 'Connect-HomeExchangeShell tests' {
    context "Mock tests" {
        BeforeAll {
            $Env:MyUPN  =   'null@test.test'

            mock -CommandName Invoke-Expression -MockWith { return $True }

            . "$PSScriptRoot\..\Support\Public\Connect-HomeExchangeShell.ps1"
        }

        it 'should not throw in Windows PowerShell' {

            { Connect-HomeExchangeShell } | should -Not -Throw

            Assert-MockCalled -CommandName 'Invoke-Expression' -Times 1
        }
    }
}

describe 'Connect-HomeExchangeShell Failure tests' {
    BeforeAll {
        $env:ExchangeInstallPath        =   $null
        $Env:MyUPN  =   'null@test.test'

        . "$PSScriptRoot\..\Support\Public\Connect-HomeExchangeShell.ps1"
    }

    it 'should throw when the ExchangeOnlineManagement module is not available' {
        { Connect-HomeExchangeShell } | Should -Throw
    }
}