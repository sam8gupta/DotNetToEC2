$fqdn = "$((Get-WmiObject win32_computersystem).DNSHostName).$((Get-WmiObject win32_computersystem).Domain)" 
$cert=(Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -match "CN=$fqdn" } | Select-Object -First 1) 
if ($cert  -eq $null) { 
$cert = New-SelfSignedCertificate -DnsName $fqdn -CertStoreLocation "cert:\LocalMachine\My" 
} 
$binding = (Get-WebBinding -Name 'Default Web Site' | where-object {$_.protocol -eq "https"})
if($binding -ne $null) {
    Remove-WebBinding -Name 'Default Web Site' -Port 443 -Protocol "https" -HostHeader $fqdn
} 
New-WebBinding -Name 'Default Web Site' -Port 443 -Protocol https -HostHeader $fqdn 
(Get-WebBinding -Name 'Default Web Site' -Port 443 -Protocol "https" -HostHeader $fqdn).AddSslCertificate($cert.Thumbprint, "my")
