
# IP list / 941 lines
$file = 'c:\temp\kr-aggregated.zone.txt'
$ip_list = get-content $file | where {($_.trim().length -ne 0) -and ($_ -match '^[0-9a-f]{1,4}[\.\:]')} 
$line_count = $list_KR_IPv4.Count


# Create nsg
$nsg_name = "NSG-Allow-Korea-20210210-2309"
New-AzNetworkSecurityGroup -ResourceGroupName "rg-lab-20h2" -Location "koreacentral" -Name $nsg_name -Verbose
$nsg1 = Get-AzNetworkSecurityGroup -ResourceGroupName "rg-lab-20h2" -Name $nsg_name


# 1 source IP per rule (941 rules)
$i = 1
$nsg_priority_start = 1000
$ip_list | Select-Object -First 10 |  % {
#$ip_list | % {
  $my_ip = $PSItem
  [int]$nsg_pri = $nsg_priority_start + $i
  [string]$nsg_rule_name = "Allow-from-Korea-$i"
  [string]$nsg_rule_desc = "From $my_ip"
  
  #"$my_ip / $nsg_pri / $nsg_rule_name / $nsg_rule_desc"

  $nsg1 | 
  Add-AzNetworkSecurityRuleConfig  `
    -Priority $nsg_pri `
    -Name $nsg_rule_name `
    -Description $nsg_rule_desc `
    -Access Allow -Protocol Tcp -Direction Inbound `
    -SourceAddressPrefix $my_ip -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 |
  Set-AzNetworkSecurityGroup -Verbose
  $i++
}


# Multiple source IPs per rule
$max_ip_per_rule = 50

$i = 1
$nsg_priority_start = 1000
$start = 1
$end = $max_ip_per_rule
while ($start -le $line_count) {
    if ($end -gt $line_count) { $end = $line_count }
    [int]$nsg_pri = $nsg_priority_start + $i
    [string]$nsg_rule_name = "Allow-from-Korea-$i"
    $my_ip_list = $ip_list[$($start - 1)..$($end - 1)]

    $nsg1 | 
    Add-AzNetworkSecurityRuleConfig  `
        -Priority $nsg_pri `
        -Name $nsg_rule_name `
        -Access Allow -Protocol Tcp -Direction Inbound `
        -SourceAddressPrefix $my_ip_list -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 |
    Set-AzNetworkSecurityGroup

    $i++
    $start += $max_ip_per_rule
    $end   += $max_ip_per_rule
}


# Remove nsg
Remove-AzNetworkSecurityGroup -Name $nsg_name -ResourceGroupName rg-lab-20h2 -Force | Set-AzNetworkSecurityGroup 
