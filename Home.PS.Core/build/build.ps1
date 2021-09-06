[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [switch]
    $SignFiles
)

$ModuleVersion          =   $env:ModuleVersion
$moduleName             =   $env:ModuleName
$ModuleSDescription     =   $env:ModuleDsscription
$ModuleShortName        =   $env:ModuleShortName
$toDo                   =   $env:ToDo

$PathToJoin         =   @{
    Path                =   $env:SYSTEM_DEFAULTWORKINGDIRECTORY
    ChildPath           =   "$ModuleName\$ModuleShortName\$ModuleName.psd1"
}
$manifestPath           =   Join-Path @PathToJoin

$ManifestContent        =   Get-Content -Path $manifestPath -Raw
$ManifestContent        =   $ManifestContent -replace '<ModuleName>', $ModuleName
$ManifestContent        =   $ManifestContent -replace '<ModuleDescription>', $ModuleSDescription
$ManifestContent        =   $ManifestContent -replace '<ModuleVersion>', $ModuleVersion

# Populate public functions.
$PathToJoin         =   @{
    Path                =   $env:SYSTEM_DEFAULTWORKINGDIRECTORY
    ChildPath           =   "$ModuleName\$ModuleShortName\Public"
}
$PublicFunctionsPath    =   Join-Path @PathToJoin
$PublicFunctions    =   Get-ChildItem -Path $PublicFunctionsPath -Filter '*.ps1' | Select-Object -ExpandProperty BaseName

if ((Test-Path -Path $PublicFunctionsPath) -and ($PublicFunctions.Count -gt 0)) {

    $ModuleFunctions    =   "'$($PublicFunctions -join "','")'"

}else {
    $ModuleFunctions    =   $null
}

$ManifestContent        =   $ManifestContent -replace "'<FunctionsToExport>'", $ModuleFunctions
$ManifestContent        |   Set-Content -Path $manifestPath

# Makes sure you wrote tests for your functions, which shouldn't be a problem. Because you did, right?
Write-Output 'Checking for missing test files'
Get-ChildItem $PublicFunctionsPath | ForEach-Object {
    $TestFileName       =   "$(($_.Name).Replace('.ps1','.Tests.ps1'))"
    $TestFile       =   Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath "$ModuleName\Tests\$TestFileName"

    if (!(Test-Path $TestFile)) {

        $Local:CantContinue   =   $true
        Write-Warning "$TestFileName missing, cannot continue."
    }
}

if ( $Local:CantContinue ) { throw 'At least one test was missing, exiting.' }

## Set dynamic .psm1 info
$PathToJoin     =   @{
    Path                =   $env:SYSTEM_DEFAULTWORKINGDIRECTORY
    ChildPath           =   "$ModuleName\$ModuleShortName\$ModuleName.psm1"
}
$ModulePath             =   Join-Path @PathToJoin

$ModuleContent          =   Get-Content -Path $ModulePath -Raw

$ModuleContent          =   $ModuleContent -replace '<ModuleName>', $ModuleName
$ModuleContent          =   $ModuleContent -replace '<ModuleVersion>', $ModuleVersion
$ModuleContent          =   $ModuleContent -replace '<ModuleDescription>', $ModuleDescription
$ModuleContent          =   $ModuleContent -replace '<FunctionsToExport>', $ModuleFunctions

$ModuleContent          =   $ModuleContent -replace '<Date>', $(Get-Date -Format 'yyyy-MM-dd')
$ModuleContent          =   $ModuleContent -replace '<todo>', $toDo

$ModuleContent          |   Set-Content -Path $ModulePath

if ($SignFiles) {
    $CodeSigningCert = (Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0]

    $PathToJoin     =   @{
        Path                =   $env:SYSTEM_DEFAULTWORKINGDIRECTORY
        ChildPath           =   "$ModuleName\$ModuleShortName\Private"
    }
    $PrivateFunctionsPath   =   Join-Path @PathToJoin

    if (Test-Path -Path $PrivateFunctionsPath) {
        foreach ($File in (Get-ChildItem $PrivateFunctionsPath)) {
            Set-AuthenticodeSignature $File.FullName -Certificate $CodeSigningCert -EA Stop
        }
    }

    foreach ($File in (Get-ChildItem $PublicFunctionsPath)) {
        Set-AuthenticodeSignature $File.FullName -Certificate $CodeSigningCert -EA Stop
    }

    Set-AuthenticodeSignature $ModulePath -Certificate $CodeSigningCert -EA Stop
    Set-AuthenticodeSignature $manifestPath -Certificate $CodeSigningCert -EA Stop
}