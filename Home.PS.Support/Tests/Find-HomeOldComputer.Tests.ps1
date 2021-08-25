Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Support\Public\Find-HomeOldComputer.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }

    . "$PSScriptRoot\..\Support\Public\Find-HomeOldComputer.ps1"

    $GetHelpContent = @{
        HelpInfo                    =   Get-Help -Name Find-HomeOldComputer -Full | Select-Object -Property *
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
    $Params                     =   Get-Help -Name Find-HomeOldComputer -Parameter * -ErrorAction SilentlyContinue |
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
        Code                    =   (Get-Content -Path 'function:/Find-HomeOldComputer' -ErrorAction Ignore).Ast
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

describe 'Find-HomeOldComputer tests' {
    context "Mock tests" {
        BeforeAll {
            $OldComputerDate    =   Get-Date '6/23/1912 00:00:00'           # Alan Turing's birthday.

            function Get-ADDomainController {}
            function Get-ADComputer {}

            $Currentlient   =   [PSCustomObject]@{
                Name            =   'CurrentClient'
                OperatingSystem =   'Windows Desktop'
                LastLogonDate   =   (Get-Date).AddDays(-5)
            }

            $OldClient   =   [PSCustomObject]@{
                Name            =   'OldClient'
                OperatingSystem =   'Windows Desktop'
                LastLogonDate   =   $OldComputerDate
            }

            $RecentClient   =   [PSCustomObject]@{
                Name            =   'RecentClient'
                OperatingSystem =   'Windows Desktop'
                LastLogonDate   =   (Get-Date).AddDays(-31)
            }

            $CurrentServer   =   [PSCustomObject]@{
                Name            =   'CurrentServer'
                OperatingSystem =   'Windows Server'
                LastLogonDate   =   (Get-Date).AddDays(-5)
            }

            $OldServer      =   [PSCustomObject]@{
                Name            =   'CurrentServer'
                OperatingSystem =   'Windows Server 2019'
                LastLogonDate   =   $OldComputerDate
            }

            $RecentServer   =   [PSCustomObject]@{
                Name            =   'RecentServer'
                OperatingSystem =   'Windows Server 2019'
                LastLogonDate   =   (Get-Date).AddDays(-31)
            }

            mock -CommandName Get-ADDomainController -MockWith { return @(@{Name = 'DC00'}, @{Name = 'DC01'})}
            mock -CommandName Get-ADComputer -MockWith { return $Currentlient, $CurrentServer, $OldClient, $OldServer, $RecentClient, $RecentServer }

            . "$PSScriptRoot\..\Support\Public\Find-HomeOldComputer.ps1"
        }

        it 'should return <OldComputers> older than <NumberOfDays> old, when IncludeServers is <IncludeServers>, ServersOnly is <ServersOnly>' -TestCases @(
            @{ NumberOfDays = 30 ; IncludeServers = $False ; ServersOnly = $False ; OldComputers = 2 }
            @{ NumberOfDays = 30 ; IncludeServers = $False ; ServersOnly = $True  ; OldComputers = 2 }
            @{ NumberOfDays = 30 ; IncludeServers = $True  ; ServersOnly = $False ; OldComputers = 4 }
            @{ NumberOfDays = 1  ; IncludeServers = $False ; ServersOnly = $True  ; OldComputers = 3 }
            @{ NumberOfDays = 1  ; IncludeServers = $True  ; ServersOnly = $False ; OldComputers = 6 }
            @{ NumberOfDays = 1  ; IncludeServers = $False ; ServersOnly = $False ; OldComputers = 3 }
            @{ NumberOfDays = 90 ; IncludeServers = $False ; ServersOnly = $False ; OldComputers = 1 }
            @{ NumberOfDays = 90 ; IncludeServers = $False ; ServersOnly = $True  ; OldComputers = 1 }
            @{ NumberOfDays = 90 ; IncludeServers = $True  ; ServersOnly = $False ; OldComputers = 2 }
        ) {
            param ($ServersOnly, $IncludeServers, $NumberOfDays, $OldComputers)

            $OldComputerParams  =   @{
                NumberOfDays    =   $NumberOfDays
                IncludeServers  =   $IncludeServers
                ServersOnly     =   $ServersOnly
            }

            (Find-HomeOldComputer @OldComputerParams).Count    | Should -BeExactly $OldComputers

            Assert-MockCalled -CommandName Get-ADDomainController -Times 1 -Exactly
            Assert-MockCalled -CommandName Get-ADComputer -Times 2 -Exactly
        }
    }
}

describe 'Find-HomeOldComputer Failure tests' {
    BeforeAll {
        $OldComputerDate    =   Get-Date '6/23/1912 00:00:00'           # Alan Turing's birthday.

        function Get-ADDomainController {}
        function Get-ADComputer {}

        $Currentlient   =   [PSCustomObject]@{
            Name            =   'CurrentClient'
            OperatingSystem =   'Windows Desktop'
            LastLogonDate   =   (Get-Date).AddDays(-5)
        }

        $OldClient   =   [PSCustomObject]@{
            Name            =   'OldClient'
            OperatingSystem =   'Windows Desktop'
            LastLogonDate   =   $OldComputerDate
        }

        $RecentClient   =   [PSCustomObject]@{
            Name            =   'RecentClient'
            OperatingSystem =   'Windows Desktop'
            LastLogonDate   =   (Get-Date).AddDays(-31)
        }

        $CurrentServer   =   [PSCustomObject]@{
            Name            =   'CurrentServer'
            OperatingSystem =   'Windows Server'
            LastLogonDate   =   (Get-Date).AddDays(-5)
        }

        $OldServer      =   [PSCustomObject]@{
            Name            =   'CurrentServer'
            OperatingSystem =   'Windows Server 2019'
            LastLogonDate   =   $OldComputerDate
        }

        $RecentServer   =   [PSCustomObject]@{
            Name            =   'RecentServer'
            OperatingSystem =   'Windows Server 2019'
            LastLogonDate   =   (Get-Date).AddDays(-31)
        }

        mock -CommandName Get-ADDomainController -MockWith { return @(@{Name = 'DC00'}, @{Name = 'DC01'})}
        mock -CommandName Get-ADComputer -MockWith { return $Currentlient, $CurrentServer, $OldClient, $OldServer, $RecentClient, $RecentServer }

        . "$PSScriptRoot\..\Support\Public\Find-HomeOldComputer.ps1"

        mock -CommandName Get-ADDomainController -MockWith { return @(@{Name = 'DC00'}, @{Name = 'DC01'})}
        mock -CommandName Get-ADComputer -MockWith { return $Currentlient, $CurrentServer, $OldClient, $OldServer, $RecentClient, $RecentServer }
    }

    it 'should return throw an error' -TestCases @(
        @{ NumberOfDays = 100000 ; IncludeServers = $False ; ServersOnly = $False ; OldComputers = 999 }
        @{ NumberOfDays = 100000 ; IncludeServers = $True  ; ServersOnly = $False ; OldComputers = 999 }
        @{ NumberOfDays = 100000 ; IncludeServers = $False ; ServersOnly = $True  ; OldComputers = 999 }
    ){
        param ($ServersOnly, $IncludeServers, $NumberOfDays, $OldComputers)

        $OldComputerParams  =   @{
            NumberOfDays    =   $NumberOfDays
            IncludeServers  =   $IncludeServers
            ServersOnly     =   $ServersOnly
        }

        { Find-HomeOldComputer @OldComputerParams } | Should -throw
    }


}