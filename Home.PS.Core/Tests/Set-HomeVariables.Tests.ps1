Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Core\Public\Set-HomeVariables.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Core\Public\Set-HomeVariables.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name Set-HomeVariables -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name Set-HomeVariables -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/Set-HomeVariables' -ErrorAction Ignore).Ast
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

describe 'Set-HomeVariables tests' {
    BeforeEach {
        Remove-Variable -Name "ITAlerts" -ErrorAction "SilentlyContinue"
        Remove-Variable -Name "ITSupport"  -ErrorAction "SilentlyContinue"
        Remove-Variable -Name "ITServices"  -ErrorAction "SilentlyContinue"
        Remove-Variable -Name "PSEmailServer" -ErrorAction "SilentlyContinue"
    }

    it 'sets $ITAlerts' {
        . $PSScriptRoot\..\Core\Public\Set-HomeVariables.ps1
        $ITAlerts | should -be "italerts@robharman.me"
    }

    it 'sets $ITServices' {
        . $PSScriptRoot\..\Core\Public\Set-HomeVariables.ps1
        $ITServices | should -be "itservices@robharman.me"
    }

    it 'sets $ITSupport' {
        . $PSScriptRoot\..\Core\Public\Set-HomeVariables.ps1
        $ITSupport | should -be "itsupport@robharman.me"
    }

    it 'sets $PSEmailServer' {
        . $PSScriptRoot\..\Core\Public\Set-HomeVariables.ps1
        $PSEmailServer | should -be "smtp.robharman.me"
    }
}