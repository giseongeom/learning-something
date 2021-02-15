Allow/Block using Geo-IP
============================

## Method 1 - Azure NSG 

* Azure NSG can hold up to 4,000 `IP Addresses (CIDR)` and 1,000 rules in a single NSG.

* [IPdeny.com](https://www.ipdeny.com/ipblocks/) provides aggregated South Korea IPv4 address list that has 941 lines. So, you can convert this list to single Azure NSG instance.

* The following example add Azure NSG rules that allow RDP connection from South Korea IPv4 address only. You can see more complicated code in the`example-azure-nsg.ps1` 

  ```powersheell
  # IP list / 941 lines
  $file = '.\kr-aggregated.zone.txt'
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
  
  
  ```

  

   


​    

## Method 2 - Windows Firewall

> [Greg Munson](https://www.gregsitservices.com/blog/author/tri0n/) wrote a useful script `Import-Firewall-Blocklist.ps1` And I converted the script to `Import-Firewall-Whitelist.ps1` to use my production server.



```PowerShell
# Create Windows Firewall rules
PS C:\temp> .\Import-Firewall-Whitelist.ps1 -InputFile .\kr-aggregated.zone.txt 

Deleting any inbound or outbound firewall rules named like 'kr-aggregated.zone-#*'

Creating an  inbound firewall rule named 'kr-aggregated.zone-#001' for IP ranges 1 - 100
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#002' for IP ranges 101 - 200
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#003' for IP ranges 201 - 300
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#004' for IP ranges 301 - 400
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#005' for IP ranges 401 - 500
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#006' for IP ranges 501 - 600
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#007' for IP ranges 601 - 700
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#008' for IP ranges 701 - 800
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#009' for IP ranges 801 - 900
Ok.
Creating an  inbound firewall rule named 'kr-aggregated.zone-#010' for IP ranges 901 - 941
Ok.


# Created rule name matches zonefile 
PS C:\temp> Get-NetFirewallRule | ? { $_.DisplayName -like "kr-aggregated*" } | ft -AutoSize

Name                                   DisplayName             DisplayGroup Enabled Profile Direction Action
----                                   -----------             ------------ ------- ------- --------- ------
{C0C5B017-2A64-4EC4-A443-446E176FB648} kr-aggregated.zone-#001              True    Any     Inbound   Allow 
{EB97EBC1-AA28-44C4-9F23-7A35F767F036} kr-aggregated.zone-#002              True    Any     Inbound   Allow 
{06B4A558-0A02-4170-B4EC-5D0D8FB677EF} kr-aggregated.zone-#003              True    Any     Inbound   Allow 
{FA7D2DBE-67E2-4BDD-AD12-18C827896950} kr-aggregated.zone-#004              True    Any     Inbound   Allow 
{EA8CA320-BD54-4EE1-9C71-6BD76F272683} kr-aggregated.zone-#005              True    Any     Inbound   Allow 
{E0A80845-6C74-420C-88C1-78EAA879790C} kr-aggregated.zone-#006              True    Any     Inbound   Allow 
{E9A23AD8-0E84-4F19-8065-67237F10594D} kr-aggregated.zone-#007              True    Any     Inbound   Allow 
{5CAF3AE7-A249-4E41-9CFB-BF173F92DABE} kr-aggregated.zone-#008              True    Any     Inbound   Allow 
{D519788B-A39E-4582-A9DF-6BF3BD262943} kr-aggregated.zone-#009              True    Any     Inbound   Allow 
{050B0BB9-F00B-4BA0-8638-ED9EC6D21904} kr-aggregated.zone-#010              True    Any     Inbound   Allow 


# Verify each rule has 100 IPv4 source addresses.
PS C:\temp> $rule1 = Get-NetFirewallRule | ? { $_.DisplayName -like "kr-aggregated*" } | Select-Object -First 1
PS C:\temp> $rule1_address_list = $rule1 | Get-NetFirewallAddressFilter | Select-Object -Property RemoteAddress 
PS C:\temp> $rule1_address_list

RemoteAddress                                                                               
-------------                                                                               
{1.11.0.0/255.255.0.0, 1.16.0.0/255.252.0.0, 1.96.0.0/255.240.0.0, 1.176.0.0/255.254.0.0...}

PS C:\temp> $rule1_address_list.RemoteAddress.Count
100


# Remove Windows Firewall rules generated by previous step
PS C:\temp> .\Import-Firewall-Whitelist.ps1 -InputFile .\kr-aggregated.zone.txt -DeleteOnly

Deleting any inbound or outbound firewall rules named like 'kr-aggregated.zone-#*'
Reminder: when deleting by name, leave off the '-#1' at the end of the rulename.

PS C:\temp> Get-NetFirewallRule | ? { $_.DisplayName -like "kr-aggregated*" } | ft -AutoSize
PS C:\temp> 

```

​        

## References

- [Azure Networking limits](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#networking-limits)
- [Blocking Unwanted Countries with Windows Firewall](https://www.gregsitservices.com/blog/2016/02/blocking-unwanted-countries-with-windows-firewall/)
- [IPdeny country block downloads](https://www.ipdeny.com/ipblocks/)

