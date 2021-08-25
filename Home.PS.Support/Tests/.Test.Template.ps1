Install-Module -Name PSScriptAnalyzer -Force

BeforeDiscovery {
    $ScriptAnalyzerRules    =   @(Get-ScriptAnalyzerRule)
}

Describe 'Default Tests' -ForEach $ScriptAnalyzerRules {
    BeforeAll {
        $IncludeRule         =   $_
        $Path                =   "$PSScriptRoot\..\Support\Public\<FunctionName>.ps1"
    }
    It "<Path> Should not violate: <IncludeRule>" {
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }
}

describe '<FunctionName> tests' {
    context "Mock tests" {
        BeforeAll {
            mock -CommandName COMMAND -MockWith { return REPLACEMENT } -ParameterFilter { $Param -eq "thing" }
        }

        beforeeach {
            . "$PSScriptRoot\..\Support\Public\<FunctionName>.ps1"
        }

        it 'should return a type' {

            <FunctionName> | should -BeOfType type
        }

    }
}

describe '<FunctionName> Failure tests' {
    BeforeAll {
        . "$PSScriptRoot\..\Support\Public\<FunctionName>.ps1"
    }

    it 'should throw when you forget to add your own tests' {
        { throw } | Should -Not -Throw
    }
}