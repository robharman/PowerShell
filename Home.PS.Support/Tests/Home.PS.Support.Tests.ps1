Install-Module -Name PSScriptAnalyzer -Force

BeforeDiscovery {
    $ScriptAnalyzerRules    =   @(Get-ScriptAnalyzerRule)
}

Describe 'Default Tests' -ForEach $ScriptAnalyzerRules {
    BeforeAll {
        $IncludeRule         =   $_
        $Path                =   "$PSScriptRoot\..\Support\Home.PS.Support.psm1"
    }
    It "<Path> Should not violate: <IncludeRule>" {
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }
}

describe 'Module-level tests' {
    it 'the module imports successfully' {
        Import-Module  "$PSScriptRoot\..\Build\Include\ActiveDirectory.psm1"

        { Import-Module "$PSScriptRoot\..\Support\Home.PS.Support.psm1" -ErrorAction 'Stop' } | should -not -throw
    }

    it 'the module has an associated manifest' {
        Test-Path "$PSScriptRoot\..\Support\Home.PS.Support.psd1" | should -Be $true
    }
}