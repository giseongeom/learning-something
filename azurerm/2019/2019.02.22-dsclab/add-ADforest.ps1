Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
$SafeModeAdministratorPassword = ConvertTo-SecureString -String 'Pa$$w0rd1234!' -AsPlainText -Force
Install-ADDSForest -DomainName 'dsclab.local' -SafeModeAdministratorPassword $SafeModeAdministratorPassword -InstallDNS -Force