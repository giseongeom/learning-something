#Requires -version 5


# Added parameter-validation
# See https://learn-powershell.net/2014/02/04/using-powershell-parameter-validation-to-make-your-day-easier/
Function New-StorageSpaceVolume() {
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateCount(2,32)]
        [uint32[]]$diskIds,
     
        [Parameter(Mandatory = $true)]
        [ValidateLength(1,1)]
        [ValidatePattern('[e-zE-Z]')]
        [string]$driveLetter,

        [Parameter(Mandatory = $true)]
        [ValidateLength(3,12)]
        [string]$driveLabel
    )

    BEGIN {
        #UpperCase
        $driveLetter = $driveLetter.ToUpper()
        $driveLabel  = $driveLabel.ToUpper()
        $storageSpacePoolName = $driveLabel
        $storageSpacePoolName = $storageSpacePoolName.ToUpper()
        $virtualDiskName      = $storageSpacePoolName

        #Validate diskIds
        $disks = Get-Disk -Number ($diskIds) -ErrorAction SilentlyContinue
        $disks_count = ($disks | Measure-Object).count
        if (($disks_count -ge 2) -and ($disks_count -eq $diskIds.Count)) {
            $diskHealthStatus  = $disks | Group-Object -Property HealthStatus
            $diskOpStatus      = $disks | Group-Object -Property OperationalStatus
            $diskSizeMatch     = $disks | Group-Object -Property Size
            $diskPartitonStyle = $disks | Group-Object -Property PartitionStyle
            
            [bool]$is_Disk_HealthStatus_Ready   = $false
            [bool]$is_Disk_OpStatus_Ready       = $false
            [bool]$is_Disk_Size_Ready           = $false
            [bool]$is_Disk_PartitionStyle_Ready = $false            
            
            if ((($diskHealthStatus | measure-object).Count -eq 1 ) -and ($diskHealthStatus.Name -eq "Healthy")) { $is_Disk_HealthStatus_Ready   = $true }
            if ((($diskOpStatus | measure-object).Count -eq 1)      -and ($diskOpStatus.Name     -eq "Offline")) { $is_Disk_OpStatus_Ready       = $true }
            if (($diskSizeMatch | measure-object).Count -eq 1)                                                   { $is_Disk_Size_Ready           = $true }
            if ((($diskPartitonStyle | measure-object).Count -eq 1) -and ($diskPartitonStyle.Name -eq "RAW"))    { $is_Disk_PartitionStyle_Ready = $true }

            if (($is_Disk_HealthStatus_Ready) -and ($is_Disk_OpStatus_Ready) -and ($is_Disk_Size_Ready) -and ($is_Disk_PartitionStyle_Ready)) {
            } else {
                $diskHealthStatus
                $diskOpStatus
                $diskSizeMatch
                $diskPartitonStyle
                Write-Output "Failed in validating diskIds...."
                Break
            }
        } else {
            Write-Host '$diskIds: '  $diskIds
            Write-Host '$diskIds.count: '  $diskIds.Count
            Write-Host '$disks.count: ' $disks_count
            Write-Output "Failed in validating diskIds...."
            Break
        }


        #Validate driveLetter
        $volumes = Get-Volume | Where-Object { ($_.DriveLetter) }
        if ($volumes) {
            $driveLetterMatch = $volumes | Where-Object { $_.DriveLetter -match $driveLetter } | Measure-Object
            if ($driveLetterMatch.count -ne 0) {
                $volumes | Format-Table -AutoSize
                Write-Output "Failed in validating driveLetter..."
                Break
            }        
        }


        #Validate storagePoolName/driveLabel
        $volumes = Get-Volume | Where-Object { ($_.FileSystemLabel) }
        if ($volumes) {
            $driveLabelMatch = $volumes | Where-Object { $_.FileSystemLabel -match $driveLabel } | Measure-Object
            if ($driveLabelMatch.count -ne 0) {
                $volumes | Format-Table -AutoSize
                Write-Output "Failed in validating driveLabel..."
                Break
            }        
        }


    }

    PROCESS {
        Write-Host -NoNewline  "Creating StoragePool - $storageSpacePoolName ................. "
        $ss_subsystem = Get-StorageSubSystem | Select-Object -First 1
        if ($ss_subsystem) {
            $ss_phy_disks = Get-PhysicalDisk -CanPool $true -StorageSubsystem $ss_subsystem | Where-Object { $_.DeviceId -in $diskIds }

            # Create Data Volume using Storage Space
            # http://www.lazywinadmin.com/2013/08/ws2012-storage-creating-storage-pool.html
            $ss_storagepool = New-StoragePool -FriendlyName $storageSpacePoolName -StorageSubSystemUniqueId $ss_subsystem.UniqueId -PhysicalDisks $ss_phy_disks -Verbose
            if (($ss_storagepool | Measure-Object).Count -gt 0) {
                Write-Host -NoNewline 'Done'
                Write-Host ''

                # Create Virtual Disk with 64KB
                # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sql/virtual-machines-windows-sql-performance
                $ss_vd_columns = $diskIds.Count

                Write-Host -NoNewline "Creating VirtualDisk - $virtualDiskName ................. "
                $ss_virtualdisk = New-VirtualDisk –FriendlyName $virtualDiskName -UseMaximumSize `
                                    –StoragePoolFriendlyName $storageSpacePoolName -NumberOfColumns $ss_vd_columns `
                                    -Interleave 65536 -ResiliencySettingName simple
               if (($ss_virtualdisk | Measure-Object).Count -gt 0) {
                    Write-Host -NoNewline 'Done'
                    Write-Host ''

                    $ss_vd_drive_letter = $driveLetter
                    $ss_vd_drive_label  = $driveLabel

                    Write-Host -NoNewline "Creating Volume ${ss_vd_drive_letter}: ................. "
                    $ss_volume = Get-VirtualDisk -FriendlyName $virtualDiskName | 
                                   Initialize-Disk -PartitionStyle GPT -PassThru | 
                                   New-Partition -DriveLetter $ss_vd_drive_letter -UseMaximumSize |
                                   Format-Volume -FileSystem NTFS -NewFileSystemLabel $ss_vd_drive_label -AllocationUnitSize 65536 -Confirm:$false
                    if (($ss_volume | Measure-Object).Count -gt 0) {
                        Write-Host -NoNewline 'Done'
                        Write-Host ''
                    } else {
                        Write-Host -NoNewline 'Failed'
                        Write-Host ''
                        $ss_vd_drive_letter
                        $ss_vd_drive_label
                        $ss_volume
                        BREAK
                    }

               } else {
                   Write-Host -NoNewline 'Failed'
                   Write-Host ''
                   $ss_virtualdisk
                   BREAK
               }
            } else {
                Write-Host -NoNewline 'Failed'
                Write-Host ''
                $ss_storagepool
                BREAK
            }
        }
    }

    END {}
}


Function Get-DiskCount() {
    Param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('RAW','MBR','GPT', ignorecase=$True)]
        [string]$PartitionStyle = "RAW"
    )

    BEGIN {}
    
    PROCESS {
        $disks_count = (Get-Disk | Where-Object { $_.PartitionStyle -eq $PartitionStyle } | Measure-Object).Count
    }
    
    END {
        return $disks_count
    }

}


Function Clear-StoragePool() {
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(2,16)]
        [string]$poolName,

        [Parameter(Mandatory = $false)]
        [ValidateCount(2,32)]
        [uint32[]]$diskIds
    )

    BEGIN {
        [uint32[]]$storagePoolDiskIds = (Get-PhysicalDisk -StoragePool (Get-StoragePool $poolName) | Select-Object -ExpandProperty DeviceId)
        if (($diskIds | Measure-Object).Count -eq 0 ) {
            $diskIds = $storagePoolDiskIds
        }
    }
    
    PROCESS {
        Get-StoragePool -FriendlyName $poolName -IsPrimordial $false | Remove-VirtualDisk -Confirm:$false
        Get-StoragePool -FriendlyName $poolName -IsPrimordial $false | Remove-StoragePool -Confirm:$false
        Get-Disk -Number $diskIds | Clear-Disk -Confirm:$false
        Get-Disk -Number $diskIds | Set-Disk -IsOffline $true
    }

    END {}
}
