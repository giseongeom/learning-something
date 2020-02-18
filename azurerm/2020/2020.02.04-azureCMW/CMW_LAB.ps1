# 사전 준비
# ResourceGroup / Subscription 정의
$lab_subscription = 'xxxx-xxxx-xxxx-xxxx'
$lab_rg = 'xxxx-rg'

# VM 생성에 필요한 AzureRM template 지정
$template_uri = 'https://raw.githubusercontent.com/giseongeom/learning-something/master/azurerm/2020/2020.02.04-azureCMW/cmwlabdeploy.json'

# Maintenance Configuration에 사용될 Name 지정
$mgmt_cfg_name = 'labazmaintconfig20200217'


# 리소스 생성
# Subscription 지정하고 Resource Group 생성
Select-AzSubscription -Subscription $lab_subscription
New-AzResourceGroup -Name $lab_rg -Location koreacentral -Verbose

# VM 생성
# Standard_D8s_v3 / 10대 / DNG 배치
$vmSize  = 'Standard_D8s_v3'
$vmCount = 5
New-AzResourceGroupDeployment -ResourceGroupName $lab_rg -TemplateUri $template_uri -vmCount $vmCount -vmSize $vmSize -isDngVM $true -Verbose

# 잘 생성되었는지 확인
get-azvm -ResourceGroupName $lab_rg

# VM에 연결할 Maintenance Configuration 생성
$mgmt_config = New-AzMaintenanceConfiguration -ResourceGroupName $lab_rg -MaintenanceScope host -Location KoreaCentral -Name $mgmt_cfg_name

# VM에 Maintenance Configuration 연결(Assignment)
$azNewConfigAssignmentList = @()
get-azvm -ResourceGroupName $lab_rg | % {
    $vmname = $_.Name
    $cfg_assignment_name = $vmname + "_" + "cfg_assignment"
    $azNewConfigAssignment = New-AzConfigurationAssignment -ResourceGroupName $lab_rg -ResourceName $vmname -Location koreacentral -ResourceType VirtualMachines -ProviderName Microsoft.Compute -ConfigurationAssignmentName $cfg_assignment_name -MaintenanceConfigurationId $mgmt_config.Id
    $azNewConfigAssignmentList += $azNewConfigAssignment
}

# Assignemt 확인
$azAppliedConfigAssignmentList = @()
get-azvm -ResourceGroupName $lab_rg | % {
    $vmname = $_.Name
    $azAppliedConfigAssignment = Get-AzConfigurationAssignment -ResourceGroupName $lab_rg -ResourceName $vmname -ProviderName Microsoft.Compute -ResourceType VirtualMachines
    $azAppliedConfigAssignmentList += $azAppliedConfigAssignment
}


# Platform Update 있는지 확인
get-azvm -ResourceGroupName $lab_rg | % {
    $vmname = $_.Name
    Get-AzMaintenanceUpdate -ResourceGroupName $lab_rg -ResourceName $vmname -ProviderName Microsoft.Compute  -ResourceType VirtualMachines -Verbose
}


# Update 적용
# 적용된 Update는 $AzUpdateAppliedList 배열에 저장.
$AzUpdateAppliedList = @()
get-azvm -ResourceGroupName $lab_rg | % {
    $vmname = $_.Name
    $pendingUpdate = Get-AzMaintenanceUpdate -ResourceGroupName $lab_rg  -ResourceName $vmname -ProviderName Microsoft.Compute -ResourceType VirtualMachines

    if ($pendingUpdate) {
        $AzUpdateApplied = New-AzApplyUpdate -ResourceGroupName $lab_rg -ResourceName $vmname -ResourceType VirtualMachines -ProviderName Microsoft.Compute
        if ($?) { $AzUpdateAppliedList += $AzUpdateApplied }
    }
}
$AzUpdateAppliedList

# 10 - 15 분 정도 기다렸다가 Get-AzMaintenanceUpdate cmdlet로 Update 상태를 확인해보자 (최대 20분)
# Get-AzMaintenanceUpdate의 결과가 없으면 업데이트가 완료된 것이다.

# 개별 update의 진행상황은 Get-AzApplyUpdate cmdlet으로 알 수 있다.
# Get-AzApplyUpdate의 결과가 Completed로 표시되면 업데이트가 완료된 것이다.
$AzUpdateAppliedList | % {
  $vmname = $_.ResourceId -split '/' | Select-Object -Last 1
  $update_name = $_.Name 
  Get-AzApplyUpdate -ResourceGroupName $lab_rg -ResourceName $vmname -ProviderName Microsoft.Compute -ResourceType VirtualMachines -ApplyUpdateName $update_name
}



# Update가 완료되었다면 이제 테스트에 사용된 VM, 리소스 그룹을 삭제한다.
# 
# ***** IMPORTANT!!! ******
#
# VM을 삭제하기 전에 *반드시* Assignment 삭제한다.
get-azvm -ResourceGroupName $lab_rg | % {
    $vmname = $_.Name
    $cfg_assignment_name = $vmname + "_" + "cfg_assignment"
    Remove-AzConfigurationAssignment -ResourceGroupName $lab_rg -ResourceName $vmname -ResourceType VirtualMachines -ProviderName Microsoft.Compute -ConfigurationAssignmentName $cfg_assignment_name -Force
}

# Maintenance Configuration 삭제
Remove-AzMaintenanceConfiguration -ResourceGroupName $lab_rg -Name $mgmt_cfg_name -Force -AsJob

# VM 삭제
get-azvm -ResourceGroupName $lab_rg | remove-azvm -Force -NoWait

# 리소스 그룹 삭제
Remove-AzResourceGroup -Name $lab_rg -Force -AsJob

