<%
@"
Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    it '<Path> Should not violate: <IncludeRule>' -TestCases @(
        Foreach (`$ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   `$ScriptAnalyzerRule.RuleName
                Path        =   "`$PSScriptRoot\..\$PLASTER_PARAM_ModuleShortName\Public\<FunctionName>.ps1"
            }
        }
    ) {
        param(
            `$IncludeRule,
            `$Path
        )
        Invoke-ScriptAnalyzer -Path `$Path -IncludeRule `$IncludeRule | Should -BeNullOrEmpty
    }

    . "`$PSScriptRoot\..\$PLASTER_PARAM_ModuleShortName\Public\<FunctionName>.ps1"

    `$GetHelpContent = @{
        HelpInfo                =   Get-Help -Name <FunctionName> -Full | Select-Object -Property *
    }

    it 'should have Get-Help info' -TestCases `$GetHelpContent {
        `$HelpInfo               |   Should -Not -BeNullOrEmpty
    }

    it 'should have a synopsis' -TestCases `$GetHelpContent {
        `$HelpInfo.Synopsis      |   Should -Not -BeNullOrEmpty
    }

    it 'should have a description' -TestCases `$GetHelpContent {
        `$HelpInfo.Description   |   Should -Not -BeNullOrEmpty
    }

    it 'should have Author as the first note' -TestCases `$GetHelpContent {
        `$Notes                  =   `$HelpInfo.AlertSet.Alert.Text -split '\n'

        `$Notes[0].Trim()        |   Should -BeLike 'Author: *'
    }

    it 'should have Version Notes as the second note' -TestCases `$GetHelpContent {
        `$Notes                  =   `$HelpInfo.AlertSet.Alert.Text -split '\n'

        `$Notes[1].Trim()        |   Should -BeLike 'Version Notes: *'
    }

    `$Params = Get-Help -Name <FunctionName> -Parameter * -ErrorAction SilentlyContinue |
    Where-Object { `$_.Name -and `$_.Name -notin ('WhatIf', 'Confirm') } | ForEach-Object {
        @{
            Name                =   `$_.Name
            Description         =   `$_.Description.Text
        }
    }

    `$InternalCode = @{
        Code                    =   (Get-Content -Path 'function:/<FunctionName>' -ErrorAction Ignore).Ast
        Params                  =   `$Params
    }

    it 'should have help info for all params' -TestCases `$InternalCode -Skip:(-not (`$Params -and `$InternalCode.Code)) {
        @(`$Params).Count    |   Should -Be `$Code.Body.ParamBlock.Parameters.Count
    }

    it 'should describe Parameter -<Name>' -TestCases `$Params -Skip:(-not `$Params) {
        `$Description            |   Should -Not -BeNullOrEmpty
    }

    `$Examples = `$GetHelpContent.HelpInfo.Examples.Example | ForEach-Object { @{ Example = `$_ } }

    it 'should contain at least one example' -TestCases `$GetHelpContent {
        `$HelpInfo.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
    }

    it 'should show what you get back' -TestCases `$Examples {
        `$Example.Remarks        |   Should -Not -BeNullOrEmpty
    }
}

describe '<FunctionName> tests' {
    context "Mock tests" {
        BeforeAll {
            mock -CommandName COMMAND -MockWith { return REPLACEMENT } -ParameterFilter { `$Param -eq "thing" }
        }

        beforeeach {
            . "`$PSScriptRoot\..\$PLASTER_PARAM_ModuleShortName\Public\<FunctionName>.ps1"
        }

        it 'should return a type' {

            <FunctionName> | should -BeOfType type
        }
    }
}

describe '<FunctionName> Failure tests' {
    BeforeAll {
        . "`$PSScriptRoot\..\$PLASTER_MARAM_ModuleShortName\Public\<FunctionName>.ps1"
    }

    it 'should throw when you forget to add your own tests' {
        { throw } | Should -Not -Throw
    }
}
"@
%>