[cmdletbinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$ForestName,

    [Parameter(Mandatory=$true)]
    [String]$SafeModeAdministratorPassword
)
$SMAP = $SafeModeAdministratorPassword | ConvertTo-SecureString -AsPlainText -Force
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath 'C:\Windows\NTDS' `
    -DomainName $ForestName `
    -InstallDns:$true `
    -LogPath 'C:\Windows\NTDS' `
    -NoRebootOnCompletion:$false `
    -SysvolPath 'C:\Windows\SYSVOL' `
    -SafeModeAdministratorPassword $SMAP `
    -Force

Exit 0