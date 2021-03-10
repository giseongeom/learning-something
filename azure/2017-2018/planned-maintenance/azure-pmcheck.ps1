# See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/maintenance-notifications
function MyAzureVM-MaintenanceCheck
{
   param
   (
     [Parameter(Mandatory=$true)]
     $subscriptionId
   )

    Select-AzureRmSubscription -SubscriptionId $subscriptionId
    $rgList= Get-AzureRmResourceGroup 

    for ($rgIdx=0; $rgIdx -lt $rgList.Length ; $rgIdx++)
    {
        $rg = $rgList[$rgIdx]
        $vmList = Get-AzureRMVM -ResourceGroupName $rg.ResourceGroupName
        for ($vmIdx=0; $vmIdx -lt $vmList.Length ; $vmIdx++)
        {
            $vm = $vmList[$vmIdx]
            $vmDetails = Get-AzureRMVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Status
              if ($vmDetails.MaintenanceRedeployStatus)
              {
                Write-Output "$($vmDetails.ResourceGroupName) / $($vmDetails.Name) / IsSelfPmAllowed: $($vmDetails.MaintenanceRedeployStatus.IsCustomerInitiatedMaintenanceAllowed) / SelfPmStart: $($vmDetails.MaintenanceRedeployStatus.PreMaintenanceWindowStartTime) / AzurePmStart: $($vmDetails.MaintenanceRedeployStatus.MaintenanceWindowStartTime) / LastOpCode: $($vmDetails.MaintenanceRedeployStatus.LastOperationResultCode)"
              }
         }
    }
}
