Install-Module -Name PSScriptAnalyzer -Force

BeforeDiscovery {
    $ScriptAnalyzerRules    =   @(Get-ScriptAnalyzerRule)
}

Describe 'Default Tests' -ForEach $ScriptAnalyzerRules {
    BeforeAll {
        $IncludeRule         =   $_
        $Path                =   "$PSScriptRoot\..\Core\Home.PS.Core.psm1"
    }
    It "<Path> Should not violate: <IncludeRule>" {
        Invoke-ScriptAnalyzer -Path $Path -IncludeRule $IncludeRule | Should -BeNullOrEmpty
    }
}

describe 'Module-level tests' {
    BeforeEach {
        Remove-Variable -Name "ITAlerts" -ErrorAction "SilentlyContinue"
        Remove-Variable -Name "ITSupport"  -ErrorAction "SilentlyContinue"
        Remove-Variable -Name "ITServices"  -ErrorAction "SilentlyContinue"
        Remove-Variable -Name "PSEmailServer" -ErrorAction "SilentlyContinue"
    }

    it 'the module imports successfully' {
        { Import-Module "$PSScriptRoot\..\Core\Home.PS.Core.psm1" -ErrorAction 'Stop' } | should -not -throw
    }

    it 'the module has an associated manifest' {
        Test-Path "$PSScriptRoot\..\Core\Home.PS.Core.psd1" | should -Be $true
    }

    it 'sets $ITAlerts' {
        Import-Module "$PSScriptRoot\..\Core\Home.PS.Core.psm1" -Force
        $ITAlerts | should -be "italerts@robharman.me"
    }

    it 'sets $ITServices' {
        Import-Module "$PSScriptRoot\..\Core\Home.PS.Core.psm1" -Force
        $ITServices | should -be "itservices@robharman.me"
    }

    it 'sets $ITSupport' {
        Import-Module "$PSScriptRoot\..\Core\Home.PS.Core.psm1" -Force
        $ITSupport | should -be "itsupport@robharman.me"
    }

    it 'sets $PSEmailServer' {
        Import-Module "$PSScriptRoot\..\Core\Home.PS.Core.psm1" -Force
        $PSEmailServer | should -be "smtp.robharman.me"
    }
}