Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Support\Public\Find-HomeGroupMember.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Support\Public\Find-HomeGroupMember.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name Find-HomeGroupMember -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name Find-HomeGroupMember -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/Find-HomeGroupMember' -ErrorAction Ignore).Ast
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

describe 'Find-HomeGroupMember tests' {
    context "Mock tests" {
        BeforeAll {
            . "$PSScriptRoot\..\Support\Public\Find-HomeGroupMember.ps1"

            function Get-ADGroupMember {}

            $User       =   [PSCustomObject]@{
                Name            =   'Test User'
                SAMAccountName  =   'tuser'
                Enabled         =   $True
                ObjectClass     =   'User'
            }

            $NestedUser =   [pscustomobject]@{
                Name            =   'Nested User'
                SAMAccountName  =   'nuser'
                Enabled         =   $True
                ObjectClass     =   'User'
            }

            $NestedUser2 =   [pscustomobject]@{
                Name            =   'Second Nested User'
                SAMAccountName  =   '2nuser'
                Enabled         =   $True
                ObjectClass     =   'User'
            }

            $NestedNestedGroup = [pscustomobject]@{
                Name            =   'NestedNestedGroup'
                Members         =   @($NestedUser, $NestedUser2)
                ObjectClass     =   'Group'
            }

            $NestedGroup    =   [pscustomobject]@{
                Name            =   'NestedGroup'
                Members         =   @($NestedNestedGroup)
                ObjectClass     =   'Group'
            }

            $ADGroup        =   [pscustomobject]@{
                Name            =   'ADGroup'
                Members         =   @($User, $NestedGroup)
            }

            mock -CommandName Get-ADGroupMember -MockWith { return $ADGroup.Members } -ParameterFilter { 'ADGroup' -eq $Group}
            mock -CommandName Get-ADGroupMember -MockWith { return $NestedGroup.Members } -ParameterFilter { 'NestedGroup' -eq $Group }
            mock -CommandName Get-ADGroupMember -MockWith { return $NestedNestedGroup.Members } -ParameterFilter { 'NestedNestedGroup' -eq $Group }
        }

        it '<GroupName> should contain <MemberCount> objects' -TestCases @(
                @{GroupName = 'ADGroup'             ; Recurse = $False ; MemberCount = 2 ; MockTimes = 1}
                @{GroupName = 'NestedGroup'         ; Recurse = $False ; MemberCount = 1 ; MockTimes = 1}
                @{GroupName = 'NestedNestedGroup'   ; Recurse = $False ; MemberCount = 2 ; MockTimes = 1}
                @{GroupName = 'ADGroup'             ; Recurse = $True  ; MemberCount = 3 ; MockTimes = 3}
                @{GroupName = 'NestedGroup'         ; Recurse = $True  ; MemberCount = 2 ; MockTimes = 2}
                @{GroupName = 'NestedNestedGroup'   ; Recurse = $True  ; MemberCount = 2 ; MockTimes = 1}

        ) {
            param (
                $GroupName, $Recurse, $MemberCount, $MockTimes
            )
            $Members = Find-HomeGroupMember -Group $GroupName -Recurse:$Recurse
            $Members.Count | should -BeExactly $MemberCount

            Assert-MockCalled -Times $MockTimes -Exactly -CommandName Get-ADGroupMember
        }

        it '<GroupName> should contain <GroupCount> groups, and <UserCount> users' -TestCases @(
            @{GroupName = 'ADGroup'           ; Recurse = $False ; UserCount = 1 ; GroupCount = 2 ; MockTimes = 1}
            @{GroupName = 'NestedGroup'       ; Recurse = $False ; UserCount = 0 ; GroupCount = 1 ; MockTimes = 1}
            @{GroupName = 'NestedNestedGroup' ; Recurse = $False ; UserCount = 2 ; GroupCount = 2 ; MockTimes = 1}
            @{GroupName = 'ADGroup'           ; Recurse = $True  ; UserCount = 3 ; GroupCount = 0 ; MockTimes = 3}
            @{GroupName = 'NestedGroup'       ; Recurse = $True  ; UserCount = 2 ; GroupCount = 0 ; MockTimes = 2}
            @{GroupName = 'NestedNestedGroup' ; Recurse = $True  ; UserCount = 2 ; GroupCount = 0 ; MockTimes = 1}
        ) {
            param (
                $GroupName, $Recurse, $UserCount, $GroupCount, $MockTimes
            )
            $GroupCount     =   0
            $UserCount      =   0
            $Members        =   Find-HomeGroupMember -Group $GroupName -Recurse:$Recurse

            $Members | ForEach-Object {
                if ($_ -eq 'user') {
                    $usercount++

                }elseif ($_ -eq 'Group'){
                    $groupcount++
                }
            }
            $GroupCount | Should -Be $GroupCount
            $UserCount  | Should -Be $UserCount

            Assert-MockCalled -Times $MockTimes -Exactly -CommandName Get-ADGroupMember
        }
    }
}

describe 'Find-HomeGroupMember Failure tests' {
    BeforeAll {
        function Get-ADGroupMember {}

        . "$PSScriptRoot\..\Support\Public\Find-HomeGroupMember.ps1"

        mock -CommandName Get-ADGroupMember -MockWith { throw } -ParameterFilter { 'SomeInvalidGroupName' -eq $Group}
    }

    it 'should throw when ask for an invalid AD Group' {
        {Find-HomeGroupMember -Group 'SomeInvalidGroupName' -ErrorAction 'Stop' } | Should -Throw
    }
}