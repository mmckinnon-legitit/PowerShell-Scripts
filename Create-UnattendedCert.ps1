param(
    [Parameter()]
    [string]$certName
    
)

$cert = New-SelfSignedCertificate `
    -Subject "CN=$certName" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(3) `
    -HashAlgorithm "SHA256"

# Export the certificate (public key) to upload to Azure
$certPath = "$certName.cer"
Export-Certificate -Cert $cert -FilePath $certPath
