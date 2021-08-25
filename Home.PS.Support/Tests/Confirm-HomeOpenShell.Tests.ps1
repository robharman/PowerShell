Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Support\Public\Confirm-HomeOpenShell.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Support\Public\Confirm-HomeOpenShell.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name Confirm-HomeOpenShell -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name Confirm-HomeOpenShell -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/Confirm-HomeOpenShell' -ErrorAction Ignore).Ast
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

describe 'Confirm-HomeOpenShell tests' {
    context "Mock tests" {
        BeforeAll {
            . "$PSScriptRoot\..\Support\Public\Connect-Home365SecurityShell.ps1"
            . "$PSScriptRoot\..\Support\Public\Connect-HomeExchangeOnlineShell.ps1"
            . "$PSScriptRoot\..\Support\Public\Confirm-HomeOpenShell.ps1"
            mock -CommandName Connect-Home365SecurityShell -MockWith { return $True }
            mock -CommandName Connect-HomeExchangeOnlineShell -MockWith { return $True }
        }

        it 'should call Connect-HomeExchangeOnlineShell by default' {
            mock -CommandName Get-PSSession -MockWith { return @{ ComputerName  =   "outlook.offfice365.com" } }
            Confirm-HomeOpenShell

            Assert-MockCalled -CommandName Connect-HomeExchangeOnlineShell -Times 1
            Assert-MockCalled -CommandName Connect-Home365SecurityShell -Times 0
        }

        it 'should call Connect-HomeExchangeOnlineShell when asked' {
            mock -CommandName Get-PSSession -MockWith { return @{ ComputerName  =   "outlook.offfice365.com" } }
            Confirm-HomeOpenShell -ShellType 'Exchange'

            Assert-MockCalled -CommandName Connect-HomeExchangeOnlineShell -Times 1
            Assert-MockCalled -CommandName Connect-Home365SecurityShell -Times 0
        }

        it 'should call Connect-Home365SecurityShell when asked ' {
            mock -CommandName Get-PSSession -MockWith { return @{ ComputerName  =   "b.compliance.protection.outlook.com" } } -ParameterFilter { $Param -eq "thing" }
            Confirm-HomeOpenShell -ShellType 'Security'

            Assert-MockCalled -CommandName Connect-Home365SecurityShell -Times 1
            Assert-MockCalled -CommandName Connect-HomeExchangeOnlineShell -Times 0
        }

    }
}

describe 'Confirm-HomeOpenShell Failure tests' {
    context "Mock tests" {
        BeforeAll {
            . "$PSScriptRoot\..\Support\Public\Connect-Home365SecurityShell.ps1"
            . "$PSScriptRoot\..\Support\Public\Connect-HomeExchangeOnlineShell.ps1"
            . "$PSScriptRoot\..\Support\Public\Confirm-HomeOpenShell.ps1"
            mock -CommandName Connect-Home365SecurityShell -MockWith { return $True }
            mock -CommandName Connect-HomeExchangeOnlineShell -MockWith { return $True }
        }

        it 'should throw with an invalid shell.' {
            { Confirm-HomeOpenShell  (-join ((97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})) } | should -Throw
        }
    }
}