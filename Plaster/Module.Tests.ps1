<%
@"
BeforeDiscovery {
    `$ScriptAnalyzerRules    =   @(Get-ScriptAnalyzerRule)
}

Describe 'Default Tests' -ForEach `$ScriptAnalyzerRules {
    BeforeAll {
        `$IncludeRule         =   `$_
        `$Path                =   "`$PSScriptRoot\..\$PLASTER_PARAM_ModuleShortName\$PLASTER_PARAM_ModuleName.psm1"
    }
    It "<Path> Should not violate: <IncludeRule>" {
        Invoke-ScriptAnalyzer -Path `$Path -IncludeRule `$IncludeRule | Should -BeNullOrEmpty
    }
}

describe 'Module-level tests' {
    it 'the module imports successfully' {
        { Import-Module "`$PSScriptRoot\..\$PLASTER_PARAM_ModuleShortName\$PLASTER_PARAM_ModuleName.psm1" -ErrorAction 'Stop' } | should -not -throw
    }

    it 'the module has an associated manifest' {
        Test-Path "`$PSScriptRoot\..\$PLASTER_PARAM_ModuleShortName\$PLASTER_PARAM_ModuleName.psd1" | should -Be `$true
    }
}
"@
%>