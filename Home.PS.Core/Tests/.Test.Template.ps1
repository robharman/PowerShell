Install-Module -Name PSScriptAnalyzer -Force

Describe 'Default Tests' {
    It "<Path> Should not violate: <IncludeRule>" -TestCases @(
        Foreach ($ScriptAnalyzerRule in (Get-ScriptAnalyzerRule)) {
            @{
                IncludeRule =   $ScriptAnalyzerRule.RuleName
                Path        =   "$PSScriptRoot\..\Core\Public\<FunctionName>.ps1"
            }
        }
    ) {
        param(
            $IncludeRule,
            $Path
        )
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }
}

describe '<FunctionName> tests' {
    context "Mock tests" {
        BeforeAll {
            mock -CommandName COMMAND -MockWith { return REPLACEMENT } -ParameterFilter { $Param -eq "thing" }
        }

        beforeeach {
            . "$PSScriptRoot\..\Core\Public\<FunctionName>.ps1"
        }

        it 'should return a type' {

            <FunctionName> | should -BeOfType type
        }

    }
}

describe '<FunctionName> Failure tests' {
    BeforeAll {
        . "$PSScriptRoot\..\Core\Public\<FunctionName>.ps1"
    }

    it 'should throw when you forget to add your own tests' {
        { throw } | Should -Not -Throw
    }
}