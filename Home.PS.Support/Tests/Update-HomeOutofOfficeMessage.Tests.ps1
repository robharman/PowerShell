Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Support\Public\Update-HomeOutOfOfficeMessage.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Support\Public\Update-HomeOutOfOfficeMessage.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name Update-HomeOutOfOfficeMessage -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name Update-HomeOutOfOfficeMessage -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/Update-HomeOutOfOfficeMessage' -ErrorAction Ignore).Ast
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

describe 'Update-HomeOutofOfficeMessage tests' {
    context "Mock tests" {
        BeforeAll {
            New-Module -Name ExchangeOnlineManagement -ScriptBlock {
                function Set-MailboxAutoReplyConfiguration {
                    [CmdletBinding()]
                    param (
                        [Parameter(Mandatory    =   $false)]
                        [string]
                        $AutoReplyState,

                        [Parameter(Mandatory    =   $false)]
                        [string]
                        $InternalMessage,

                        [Parameter(Mandatory    =   $false)]
                        [string]
                        $ExternalMessage,

                        [Parameter(Mandatory    =   $false)]
                        [ValidateScript({
                            if ($_ -eq 'All') {
                                return $True

                            }else {
                                throw "Not set for all recipients, got: $_"
                            }
                        })]
                        [string]
                        $ExternalAudience,

                        [Parameter(Mandatory)]
                        [ValidateScript({
                            if ($_ -like "*@robharman.me") {
                                return $True

                            }else {
                                throw "Not a valid email address. Got: $_"
                            }
                        })]
                        [string]
                        $Identity
                    )

                    return $true
                }
            }

            . "$PSScriptRoot\..\Support\Public\Confirm-HomeOpenShell.ps1"

            mock -CommandName Read-Host -MockWith { return "teststring@robharman.me" }
            mock -CommandName Confirm-HomeOpenShell -MockWith { $True }
            mock -CommandName Set-MailboxAutoReplyConfiguration -MockWith { return 'Disabled' } -ParameterFilter {$AutoReplyState -eq 'Disabled'}
            mock -CommandName Set-MailboxAutoReplyConfiguration -MockWith { return $True }

            . "$PSScriptRoot\..\Support\Public\Update-HomeOutofOfficeMessage.ps1"
        }

        it 'should mock Confirm-HomeOpenShell' {
            Update-HomeOutofOfficeMessage | should -BeTrue

            Assert-MockCalled -CommandName 'Confirm-HomeOpenShell' -Times 1
        }

        it 'should mock Set-MailboxAutoReplyConfiguration' {
            Update-HomeOutofOfficeMessage | should -BeTrue

            Assert-MockCalled -CommandName 'Set-MailboxAutoReplyConfiguration' -Times 1
        }

        it 'should mock Read-Host with no parameters' {
            Update-HomeOutofOfficeMessage | should -BeTrue

            Assert-MockCalled -CommandName 'Read-Host' -Times 2
        }

        it 'should not mock Read-Host with parameters' {
            Update-HomeOutofOfficeMessage -User 'user' -OoOMessage 'OoO' | should -BeTrue

            Assert-MockCalled -CommandName 'Read-Host' -Times 0
        }

        it 'should mock Set-MailboxAutoReplyConfiguration' {
            Update-HomeOutofOfficeMessage -User 'user' -Disable | should -be @($true, 'Disabled')

            Assert-MockCalled -CommandName 'Set-MailboxAutoReplyConfiguration' -ParameterFilter {$AutoReplyState -eq 'Disabled'} -Times 1
        }
    }
}