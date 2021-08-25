Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Support\Public\Connect-Home365SecurityShell.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Support\Public\Connect-Home365SecurityShell.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name Connect-Home365SecurityShell -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name Connect-Home365SecurityShell -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/Connect-Home365SecurityShell' -ErrorAction Ignore).Ast
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

describe 'Connect-Home365SecurityShell tests' {
    context "Mock tests" {
        BeforeAll {
            $Env:MyUPN  =   'null@test.test'

            New-Module -Name 'ExchangeOnlineManagement' -ScriptBlock {
                function Connect-IPPSSession {
                    [CmdletBinding()]
                    param (
                        [Parameter(Mandatory)]
                        [string]
                        $UserPrincipalName
                    )

                    return $true
                }
            }
            mock Import-Module -MockWith {return $True}

            mock -CommandName Connect-IPPSSession -MockWith { return $True }

            . "$PSScriptRoot\..\Support\Public\Connect-Home365SecurityShell.ps1"
        }

        it 'should not throw in Windows PowerShell' {

            { Connect-Home365SecurityShell } | should -Not -Throw

            Assert-MockCalled -CommandName 'Connect-IPPSSession' -Times 1
        }

        it 'should not throw in PowerShell Core on Windows' {

            { Connect-Home365SecurityShell } | should -Not -Throw

            Assert-MockCalled -CommandName 'Connect-IPPSSession' -Times 1
        }

    }
}

describe 'Connect-Home365SecurityShell Failure tests' {
    BeforeAll {
        $Env:MyUPN  =   'null@test.test'

        mock -CommandName 'Import-Module' -MockWith {throw}

        . "$PSScriptRoot\..\Support\Public\Connect-Home365SecurityShell.ps1"
    }

    it 'should throw when the ExchangeOnlineManagement module is not available' {
        { Connect-Home365SecurityShell } | Should -Throw

        Assert-MockCalled "Import-Module" -Times 1
    }
}