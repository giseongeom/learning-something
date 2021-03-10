#Requires -version 5.1

$az_subscriptions= "
azure-subscription-001
azure-subscription-002
azure-subscription-003
azure-subscription-004
giseongeom-DevTest-20181126
".Split("`r`n") -notmatch '^#.*' | Where-Object { $_.trim() }


$azvm_list = $null
$az_subscriptions | % { 
  $my_az_subscription = $PSItem
  $my_azvm_list = $null
  Select-AzSubscription -Subscription $my_az_subscription
  $my_azvm_list = get-azvm -Status |
    Sort-Object -Property HardwareProfile.VmSize | 
    Select-Object `
        @{l="Subscription";e={$my_az_subscription}},`
        Name,ResourceGroupName,Location,`
        @{l="VmSize";e={$_.HardwareProfile.VmSize}},`
        @{l="OsType";e={if($PSItem.OSProfile.WindowsConfiguration -ne $null){"Windows"}else{"Linux"}}},`
        @{l="Status";e={$PSItem.PowerState}}
  $azvm_list += $my_azvm_list
}


$azvm_list | Export-Csv -NoTypeInformation -Path C:\temp\vmlist.csv -Encoding UTF8 -Force
$azvm_list | Sort-Object -Property Subscription,ResourceGroupName,VmSize | ft -AutoSize
