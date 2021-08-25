Import-Module Az.Accounts                           | Out-Null
Import-Module Az.Automation                         | Out-Null

$AzConnection                   =   Get-AutomationConnection -Name AzureRunAsConnection
$ConnectionParams           =  @{
    ServicePrincipal            =   $True
    Tenant                      =   $AzConnection.TenantID
    ApplicationId               =   $AzConnection.ApplicationID
    CertificateThumbprint       =   $AzConnection.CertificateThumbprint
}
$AzConnectionResult             =   Connect-AzAccount @ConnectionParams
$AzureContext                   =   Set-AzContext -SubscriptionId $AzConnection.SubscriptionId

if ($AzConnectionResult) {
    Write-Verbose "Connected to Azure account..."
}else {
    throw "Could not connect to Azure account"
}