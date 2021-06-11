describe 'New-DiceWarePassword tests' {
    context "Mock tests" {
        BeforeAll {
            mock -CommandName Get-Random -MockWith { return 1 } -ParameterFilter { $Maximum -gt 1 }
            mock -CommandName Get-Content -MockWith { return "11111	abacus`n# SIG # Begin signature block" }
            mock -CommandName Get-AuthenticodeSignature -MockWith { return @{ Status = "Valid" } }
        }

        beforeeach {
            . "$PSScriptRoot\New-DiceWarePassword.ps1"
        }

        it 'passes all default PSScriptAnalyzer rules' {
            Invoke-ScriptAnalyzer -Path "$PSScriptRoot\New-DiceWarePassword.ps1" | should -BeNullOrEmpty
        }

        it 'should return a string' {

            New-DiceWarePassword -SuppressWarning | should -BeOfType string

            Assert-MockCalled -CommandName Get-AuthenticodeSignature -Times 1
        }

        it 'should mock Get-Random at least 3 times' {

            New-DiceWarePassword -SuppressWarning

            Assert-MockCalled -CommandName Get-Random -Times 3
        }

        it 'should return a simple password when asked' {
            $SpecialCharacters  =   " `~!@#$%^&*()_+-=[]\{}|;':,./<>?""" -split ""

            $TestPassword   =   New-DiceWarePassword -Simple -SuppressWarning
            $TestPassword.Substring( 0,( $TestPassword.Length -6 ) ) -match '^[a-zA-Z]+$' | should -BeTrue
            $TestPassword[-6] | should -BeIn $SpecialCharacters

            { [int]$TestPassword.Substring($TestPassword.Length -5) } | should -Not -Throw
        }

        it 'should return a long enough password' {
            ( New-DiceWarePassword -SuppressWarning -NumberOfWords 5 ).split(' ').Count | should -BeGreaterOrEqual 5
        }

        it 'should not be too long' {
            ( New-DiceWarePassword -SuppressWarning -NumberOfWords 3 ).split(' ').Count | should -BeLessOrEqual 6
        }

        it 'should be complex when not simple' {
            ( New-DiceWarePassword -SuppressWarning) -match '^[a-zA-Z0-9]+$' | should -BeFalse
        }

        it 'should show a warning when you do not supress it ' {
            $WarningPreference  =   "Stop"
            { New-DiceWarePassword | Out-Null } | should -Throw
        }

        it 'should not show a warning when you supress it ' {
            $WarningPreference  =   "Stop"
            { New-DiceWarePassword -SuppressWarning } | should -Not -Throw
        }
    }
}

describe 'New-DiceWarePassword Failure tests' {
    BeforeAll {
        . $PSScriptRoot\New-DiceWarePassword.ps1
    }

    it 'should throw when signature fails' {
        mock Get-AuthenticodeSignature { return @{ State = "NotSigned" } }
        { New-DiceWarePassword } | should -Throw

        Assert-MockCalled Get-AuthenticodeSignature -Times 1
    }
}