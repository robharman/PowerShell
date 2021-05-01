Function New-DiceWarePassword {
    <#
    .SYNOPSIS
        Creates a human readable pseudo-random password based on Diceware with some extra symbols thrown in, and maybe
        some words turned into numbers in order to meet 'complexity' requiremnents. Returns a string.

    .PARAMETER DictionaryDirectory
        String. Optional. Defaults to local directory. The path to the directory containing the signed password 
        dictionaries.

    .PARAMETER NumberOfDice
        32 bit int. Optional. Defaults to 5. Sets the number of virtual dice to use and the $PasswordDictionary file to
        use. Example files can be found here: https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases

    .PARAMETER NumberOfWords
        32 bit Int. Optional. Defaults to 5. Sets the number of words to return in the password.

    .PARAMETER Simple
        Switch. Optional. Returns a basic WordSymbolNumber password. 

    .PARAMETER SuppressWarning
        Switch. Optional. Suppresses bad idea warning. 

    .EXAMPLE
        New-DiceWarePassword 5

        Returns a 5 word password like: wolves , BEAM > TOWER ? rose & HORN

    .EXAMPLE
        New-DiceWarePassword -Simple

        Returns a simple password like: MINES%01919

    .EXAMPLE
        New-DiceWarePassword -DictionaryDirectory "\\fileserver\passworddictionaries\" -NumberOfDice 5 -NumberOfWords 5

        Returns a five word password based on the five die dictionary at \\fileserver\passworddictionaries\5.ps1
    .NOTES
        This is not a way to generate secure or truly random passwords. This should be used only for temporary passwords
        in lieu of setting generic common passwords that users never change. 

        This assumes you've got diceware word lists for the appropriate $NumberOfDice in $DictionaryDirectory, and that 
        they're signed .ps1 files named $NumberOfDice.ps1. By default $DictionaryDirectory is the same director as the
        script is in. 

        The Dice file needs to be setup with one numbered entry per line, and one small word, such as:
        1314    train
        Each digit must be between 1-6, and each number must be 4 digits. This can easily be scaled to d10, with a new
        diceware list. 
    #>
    Param (
        [Parameter( Mandatory = $False )]
        [int32]
        $NumberOfWords          =   5,

        [Parameter( Mandatory = $false )]
        [string]
        $DictionaryDirectory    =   ".",

        [Parameter( Mandatory = $False )]
        [Int32]
        $NumberOfDice           =   5,

        [Parameter( Mandatory = $False )]
        [switch]
        $Simple                 =   $False,

        [Parameter( Mandatory = $False )]
        [switch]
        $SuppressWarning        =   $False
    )

    if ($SuppressWarning) {
        # Don't write warning about how this is a bad idea
    }else {

        Write-Warning "These passwords are not truly random and should only be used as temporary passwords."
    }

    # Make sure the password file hasn't been altered.
    if ((Get-AuthenticodeSignature $DictionaryDirectory\${NumberOfDice}.ps1).Status -NE "Valid") {

        Write-Error "Password Dictionary signature failed to validate!"

        return $null
    }

    $PasswordDictPath           =   "$DictionaryDirectory\$($NumberOfDice).ps1"
    $DiceFile       =   Get-Content $PasswordDictPath -TotalCount (Get-Content $PasswordDictPath).IndexOf("# SIG # Begin signature block")
    $PasswordDictionary         =   @{}
    $SpecialCharacters          =   "`~!@#$%^&*()_+-=[]\{}|;':,./<>?"""

    foreach ($line in $DiceFile){
        $PasswordDictionary[$line.split()[0]] = $line.split()[1]
    }
    function rollDice() {

        $DiceRoll               =   ""
        $DiceRoll              +=   ([string](1..$NumberOfDice | ForEach-Object {(Get-Random(1..6))}) -replace('\s',''))

        return $DiceRoll
    }

    $Password                   =   ""

    if ($Simple) {
        $Word = $PasswordDictionary[(rollDice)]

        # 50/50 for capitalization
        if (Get-Random(1,0)) {
            $Word               =   $Word.ToUpper()
        }

        $Special                =   $SpecialCharacters[(get-random(0..$SpecialCharacters.length))]

        $Number                 =   (Get-Random(0..99999)).ToString("00000")

        Write-Output $Word$Special$Number

    }else {
        $Password               +=  1..$NumberOfWords | ForEach-Object {

            $Word               =   $PasswordDictionary[(rollDice)]

            # Make sure everything isn't all just lowercase letters
            if (Get-Random(1,0)) {

                if (Get-Random(1,0)) {

                    $Word       =   (Get-Random(0..99999)).ToString("00000")
                }

                $Word           =   $Word.ToUpper()
            }

            if (Get-Random(1,0)){

                Return $Word + " " +($SpecialCharacters[(get-random(0..$SpecialCharacters.length))])

            }else {

                Return $Word
            }
        }

        # Make *sure* that a complex password doesn't come out as all lowercase; recursively call function if it does.
        if ($Password -cmatch "^[^A-Z]*$"){
            $Password           =   $null

            $Password = New-DiceWarePassword -NumberOfDice $NumberOfDice -NumberOfWords $NumberOfWords -DictionaryDirectory $DictionaryDirectory
        }

        $Password
    }
}
