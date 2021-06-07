describe 'New-DicewarePassword tests' {
    BeforeAll {
        . $PSScriptRoot\New-DicewarePassword.ps1
        $SpecialCharacters  =   " `~!@#$%^&*()_+-=[]\{}|;':,./<>?""" -split ""
    }

    mock Get-AuthenticodeSignature { return @{ State = "Signed" } }

    it 'passes all default PSScriptAnalyzer rules' {
        Invoke-ScriptAnalyzer -Path "$PSScriptRoot\New-DicewarePassword.ps1" | should -BeNullOrEmpty
    }

    it 'should return a string' {
        New-DicewarePassword | should -BeOfType string
    }

    it 'should return a simple password when asked' {
        $TestPassword   =   New-DiceWarePassword -Simple
        $TestPassword.Substring( 0,( $TestPassword.Length -6 ) ) -match '^[a-zA-Z]+$' | should -BeTrue
        $TestPassword[-6] | should -BeIn $SpecialCharacters
        { [int]$TestPassword.Substring($TestPassword.Length -5) } | should -Not -Throw
    }

    it 'should return a long enough password' {
        ( New-DiceWarePassword -NumberOfWords 5 ).split(' ').Count | should -BeGreaterOrEqual 5
    }

    it 'should not be too long' {
        ( New-DiceWarePassword -NumberOfWords 3 ).split(' ').Count | should -BeLessOrEqual 6
    }

    it 'should be complex when not simple' {
        ( New-DiceWarePassword ) -match '^[a-zA-Z0-9]+$' | should -BeFalse
    }

    it 'should not show a warning when you supress it ' {
        $WarningPreference  =   "Stop"
        { New-DicewarePassword -SuppressWarning } | should -not -Throw
    }
}

describe 'New-DiceWarePassword Failure tests' {
    BeforeAll {
        . $PSScriptRoot\New-DicewarePassword.ps1
    }

    it 'should throw when signature fails' {
        mock Get-AuthenticodeSignature { return @{ State = "NotSigned" } }
        { New-DicewarePassword } | should -Throw
    }
}