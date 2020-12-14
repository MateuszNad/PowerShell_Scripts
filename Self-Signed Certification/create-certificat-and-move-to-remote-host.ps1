


# Create your code signing certificate

# 1 - wygenerowanie certyfikatu
$paramNewCertificate = @{
    CertStoreLocation = "cert:\currentuser\my"
    Subject           = "CN=PowerShell Code Signing"
    KeyAlgorithm      = 'RSA'
    KeyLength         = 2048
    NotAfter          = (Get-Date).AddYears(2)
    Provider          = "Microsoft Enhanced RSA and AES Cryptographic Provider"
    KeyExportPolicy   = 'Exportable'
    KeyUsage          = 'DigitalSignature'
    Type              = 'CodeSigningCert'
}
($Cert = New-SelfSignedCertificate @paramNewCertificate)


# 2 - dodanie certyfikatu do zaufanych
($ExportedCert = Export-Certificate -Cert $Cert.PSPath -FilePath (Join-Path $env:USERPROFILE -ChildPath 'powershell-code-signing.cer'))
Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root -FilePath $ExportedCert.FullName
Import-Certificate -CertStoreLocation Cert:\CurrentUser\TrustedPublisher -FilePath $ExportedCert.FullName

# 3- podpisanie certyfikatem
$Cert = Get-ChildItem cert:\CurrentUser\My -CodeSigningCert
# Set-AuthenticodeSignature -FilePath "\\db-test01\WhiteListValidatorService\WhiteListScript\run.ps1" -Certificate $Cert
Set-AuthenticodeSignature -FilePath "C:\Users\Lenovo\Documents\Projekty\12_PowerShell\15_Repositories\PowerShell_Scripts\Where-Value.ps1" -Certificate $Cert

# 4 test certyfikatu
Set-ExecutionPolicy -Scope Process -ExecutionPolicy AllSigned
Get-ExecutionPolicy
. 'C:\Users\Lenovo\test.ps1'

# 5 - przeniesienie certyfikatu
$CertificatePath = (Join-Path $env:USERPROFILE -ChildPath 'powershell-code-signing.cer')
$Destination = 'C:\'
$ComputerName = '10.10.0.20'

#  moving cert to the destination
$Session = New-PSSession -ComputerName $ComputerName -Credential administrator
Copy-Item -Path $CertificatePath -Destination $Destination -ToSession $Session

# importing the certificate on the remote host
$RemoteCertPath = Join-Path $Destination -ChildPath (Split-Path $CertificatePath -Leaf)
Invoke-Command  -Session $Session -ScriptBlock {
    Import-Certificate -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath $using:RemoteCertPath
    Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root -FilePath $using:RemoteCertPath
}
