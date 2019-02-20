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
            if (($diskOpStatus | measure-object).Count -eq 1)                                                    { $is_Disk_OpStatus_Ready       = $true }
            if (($diskSizeMatch | measure-object).Count -eq 1)                                                   { $is_Disk_Size_Ready           = $true }
            if ((($diskPartitonStyle | measure-object).Count -eq 1) -and ($diskPartitonStyle.Name -eq "RAW"))    { $is_Disk_PartitionStyle_Ready = $true }

            if (($is_Disk_HealthStatus_Ready) -and ($is_Disk_OpStatus_Ready) -and ($is_Disk_Size_Ready) -and ($is_Disk_PartitionStyle_Ready)) {
            } else {
                Write-Host '$is_Disk_HealthStatus_Ready :' $is_Disk_HealthStatus_Ready
                Write-Host '$is_Disk_OpStatus_Ready :' $is_Disk_OpStatus_Ready       
                Write-Host '$is_Disk_Size_Ready :' $is_Disk_Size_Ready
                Write-Host '$is_Disk_PartitionStyle_Ready :' $is_Disk_PartitionStyle_Ready

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

# SIG # Begin signature block
# MIIa1gYJKoZIhvcNAQcCoIIaxzCCGsMCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDmpdNISJWnSy9U
# pKnyr4s+8I+AL7cZ+zuPqIPB5hbsCKCCFgswggPuMIIDV6ADAgECAhB+k+v7fMZO
# WepLmnfUBvw7MA0GCSqGSIb3DQEBBQUAMIGLMQswCQYDVQQGEwJaQTEVMBMGA1UE
# CBMMV2VzdGVybiBDYXBlMRQwEgYDVQQHEwtEdXJiYW52aWxsZTEPMA0GA1UEChMG
# VGhhd3RlMR0wGwYDVQQLExRUaGF3dGUgQ2VydGlmaWNhdGlvbjEfMB0GA1UEAxMW
# VGhhd3RlIFRpbWVzdGFtcGluZyBDQTAeFw0xMjEyMjEwMDAwMDBaFw0yMDEyMzAy
# MzU5NTlaMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsayzSVRLlxwS
# CtgleZEiVypv3LgmxENza8K/LlBa+xTCdo5DASVDtKHiRfTot3vDdMwi17SUAAL3
# Te2/tLdEJGvNX0U70UTOQxJzF4KLabQry5kerHIbJk1xH7Ex3ftRYQJTpqr1SSwF
# eEWlL4nO55nn/oziVz89xpLcSvh7M+R5CvvwdYhBnP/FA1GZqtdsn5Nph2Upg4XC
# YBTEyMk7FNrAgfAfDXTekiKryvf7dHwn5vdKG3+nw54trorqpuaqJxZ9YfeYcRG8
# 4lChS+Vd+uUOpyyfqmUg09iW6Mh8pU5IRP8Z4kQHkgvXaISAXWp4ZEXNYEZ+VMET
# fMV58cnBcQIDAQABo4H6MIH3MB0GA1UdDgQWBBRfmvVuXMzMdJrU3X3vP9vsTIAu
# 3TAyBggrBgEFBQcBAQQmMCQwIgYIKwYBBQUHMAGGFmh0dHA6Ly9vY3NwLnRoYXd0
# ZS5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADA/BgNVHR8EODA2MDSgMqAwhi5odHRw
# Oi8vY3JsLnRoYXd0ZS5jb20vVGhhd3RlVGltZXN0YW1waW5nQ0EuY3JsMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIBBjAoBgNVHREEITAfpB0wGzEZ
# MBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMTANBgkqhkiG9w0BAQUFAAOBgQADCZuP
# ee9/WTCq72i1+uMJHbtPggZdN1+mUp8WjeockglEbvVt61h8MOj5aY0jcwsSb0ep
# rjkR+Cqxm7Aaw47rWZYArc4MTbLQMaYIXCp6/OJ6HVdMqGUY6XlAYiWWbsfHN2qD
# IQiOQerd2Vc/HXdJhyoWBl6mOGoiEqNRGYN+tjCCBCAwggMIoAMCAQICEDRO1Vcg
# 1e3sSfQvzjfbK20wDQYJKoZIhvcNAQEFBQAwgakxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwx0aGF3dGUsIEluYy4xKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2Vydmlj
# ZXMgRGl2aXNpb24xODA2BgNVBAsTLyhjKSAyMDA2IHRoYXd0ZSwgSW5jLiAtIEZv
# ciBhdXRob3JpemVkIHVzZSBvbmx5MR8wHQYDVQQDExZ0aGF3dGUgUHJpbWFyeSBS
# b290IENBMB4XDTA2MTExNzAwMDAwMFoXDTM2MDcxNjIzNTk1OVowgakxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwx0aGF3dGUsIEluYy4xKDAmBgNVBAsTH0NlcnRpZmlj
# YXRpb24gU2VydmljZXMgRGl2aXNpb24xODA2BgNVBAsTLyhjKSAyMDA2IHRoYXd0
# ZSwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MR8wHQYDVQQDExZ0aGF3
# dGUgUHJpbWFyeSBSb290IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEArKDw+4BZ1JzHpM+doVlzCRBFDA0sbmjxbFtIaElZN/wLMxnCd3/MEC2VNBzm
# 600JpxzSuMmXNgK3idQkXwbAzESUlI0CYm/rWt0RjSiaXISQEHoNvXRmL2o4oOLV
# VETrHQefB7pv7un9Tgsp9T6EoAHxnKv4HH6JpOih2HFlDaNRe+680iJgDblbnd+6
# /FFbC6+Ysuku6QToYofeK8jXTsFMZB7dz4dYukpPymgHHRydSsbVL5HMfHFyHMXA
# Z+sy/cmSXJTahcCbv1N9Kwn0jJ2RH5dqUsveCTakd9h7h1BE1T5uKWn7OUkmHgml
# gHtALevoJ4XJ/mH9fuZ8lx3VnQIDAQABo0IwQDAPBgNVHRMBAf8EBTADAQH/MA4G
# A1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUe1tFz6/Oy3r9MZIaarbzRutXSFAwDQYJ
# KoZIhvcNAQEFBQADggEBAHkRwEuzkbb88Oln1A1uRb5V6JPSzgM/7dolsB1Xyx46
# dqBM7FB26GRyDKSp8biL1taHhLsy5UERwHfZs2Cd6xvV0W5ERKmmAexVYh13uFyO
# SEl8nDtXEaytczeOL3hckGhH2WBg5vwHPSIgF8T3FunE2HL5yHN83xYvFak+/Won
# tqHrWrqYH9XjTWQKnRPIYbr1ORyHuri9eyJ/9v6sQHnlrBBvPY8beXaLxDezIRiE
# 5TYA62Mgmbnp/jMEu0HIwQL5RGMgnoHOQtPWPyx202OcWd2PpuEOoC5B9y6VR8+8
# /TPz9gthfn6RK4FHwicw7qcQXTePXDkr5ATwe41WjGgwggSZMIIDgaADAgECAhBx
# oLc2ld2xr8I7K5oY7lTLMA0GCSqGSIb3DQEBCwUAMIGpMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMdGhhd3RlLCBJbmMuMSgwJgYDVQQLEx9DZXJ0aWZpY2F0aW9uIFNl
# cnZpY2VzIERpdmlzaW9uMTgwNgYDVQQLEy8oYykgMjAwNiB0aGF3dGUsIEluYy4g
# LSBGb3IgYXV0aG9yaXplZCB1c2Ugb25seTEfMB0GA1UEAxMWdGhhd3RlIFByaW1h
# cnkgUm9vdCBDQTAeFw0xMzEyMTAwMDAwMDBaFw0yMzEyMDkyMzU5NTlaMEwxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwx0aGF3dGUsIEluYy4xJjAkBgNVBAMTHXRoYXd0
# ZSBTSEEyNTYgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAm1UCTBcF6dBmw/wordPA/u/g6X7UHvaqG5FG/fUW7ZgHU/q6hxt9
# nh8BJ6u50mfKtxAlU/TjvpuQuO0jXELvZCVY5YgiGr71x671voqxERGTGiKpdGnB
# dLZoh6eDMPlk8bHjOD701sH8Ev5zVxc1V4rdUI0D+GbNynaDE8jXDnEd5GPJuhf4
# 0bnkiNIsKMghIA1BtwviL8KA5oh7U2zDRGOBf2hHjCsqz1v0jElhummF/WsAeAUm
# aRMwgDhO8VpVycVQ1qo4iUdDXP5Nc6VJxZNp/neWmq/zjA5XujPZDsZC0wN3xLs5
# rZH58/eWXDpkpu0nV8HoQPNT8r4pNP5f+QIDAQABo4IBFzCCARMwLwYIKwYBBQUH
# AQEEIzAhMB8GCCsGAQUFBzABhhNodHRwOi8vdDIuc3ltY2IuY29tMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwMgYDVR0fBCswKTAnoCWgI4YhaHR0cDovL3QxLnN5bWNiLmNv
# bS9UaGF3dGVQQ0EuY3JsMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDAzAO
# BgNVHQ8BAf8EBAMCAQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEVN5bWFudGVj
# UEtJLTEtNTY4MB0GA1UdDgQWBBRXhptUuL6mKYrk9sLiExiJhc3ctzAfBgNVHSME
# GDAWgBR7W0XPr87Lev0xkhpqtvNG61dIUDANBgkqhkiG9w0BAQsFAAOCAQEAJDv1
# 16A2E8dD/vAJh2jRmDFuEuQ/Hh+We2tMHoeei8Vso7EMe1CS1YGcsY8sKbfu+ZEF
# uY5B8Sz20FktmOC56oABR0CVuD2dA715uzW2rZxMJ/ZnRRDJxbyHTlV70oe73dww
# 78bUbMyZNW0c4GDTzWiPKVlLiZYIRsmO/HVPxdwJzE4ni0TNB7ysBOC1M6WHn/Td
# cwyR6hKBb+N18B61k2xEF9U+l8m9ByxWdx+F3Ubov94sgZSj9+W3p8E3n3XKVXdN
# XjYpyoXYRUFyV3XAeVv6NBAGbWQgQrc6yB8dRmQCX8ZHvvDEOihU2vYeT5qiGUOk
# b0n4/F5CICiEi0cgbjCCBKMwggOLoAMCAQICEA7P9DjI/r81bgTYapgbGlAwDQYJ
# KoZIhvcNAQEFBQAwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENv
# cnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZp
# Y2VzIENBIC0gRzIwHhcNMTIxMDE4MDAwMDAwWhcNMjAxMjI5MjM1OTU5WjBiMQsw
# CQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xNDAyBgNV
# BAMTK1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgU2lnbmVyIC0gRzQw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCiYws5RLi7I6dESbsO/6Hw
# YQpTk7CY260sD0rFbv+GPFNVDxXOBD8r/amWltm+YXkLW8lMhnbl4ENLIpXuwitD
# wZ/YaLSOQE/uhTi5EcUj8mRY8BUyb05Xoa6IpALXKh7NS+HdY9UXiTJbsF6ZWqid
# KFAOF+6W22E7RVEdzxJWC5JH/Kuu9mY9R6xwcueS51/NELnEg2SUGb0lgOHo0iKl
# 0LoCeqF3k1tlw+4XdLxBhircCEyMkoyRLZ53RB9o1qh0d9sOWzKLVoszvdljyEmd
# OsXF6jML0vGjG/SLvtmzV4s73gSneiKyJK4ux3DFvk6DJgj7C72pT5kI4RAocqrN
# AgMBAAGjggFXMIIBUzAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUF
# BwMIMA4GA1UdDwEB/wQEAwIHgDBzBggrBgEFBQcBAQRnMGUwKgYIKwYBBQUHMAGG
# Hmh0dHA6Ly90cy1vY3NwLndzLnN5bWFudGVjLmNvbTA3BggrBgEFBQcwAoYraHR0
# cDovL3RzLWFpYS53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNlcjA8BgNVHR8E
# NTAzMDGgL6AthitodHRwOi8vdHMtY3JsLndzLnN5bWFudGVjLmNvbS90c3MtY2Et
# ZzIuY3JsMCgGA1UdEQQhMB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC0y
# MB0GA1UdDgQWBBRGxmmjDkoUHtVM2lJjFz9eNrwN5jAfBgNVHSMEGDAWgBRfmvVu
# XMzMdJrU3X3vP9vsTIAu3TANBgkqhkiG9w0BAQUFAAOCAQEAeDu0kSoATPCPYjA3
# eKOEJwdvGLLeJdyg1JQDqoZOJZ+aQAMc3c7jecshaAbatjK0bb/0LCZjM+RJZG0N
# 5sNnDvcFpDVsfIkWxumy37Lp3SDGcQ/NlXTctlzevTcfQ3jmeLXNKAQgo6rxS8SI
# KZEOgNER/N1cdm5PXg5FRkFuDbDqOJqxOtoJcRD8HHm0gHusafT9nLYMFivxf1sJ
# PZtb4hbKE4FtAC44DagpjyzhsvRaqQGvFZwsL0kb2yK7w/54lFHDhrGCiF3wPbRR
# oXkzKy57udwgCRNx62oZW8/opTBXLIlJP7nPf8m/PiJoY1OavWl0rMUdPH+S4MO8
# HNgEdTCCBK0wggOVoAMCAQICEGhWf8trAnnDHEUnblCfz4swDQYJKoZIhvcNAQEL
# BQAwTDELMAkGA1UEBhMCVVMxFTATBgNVBAoTDHRoYXd0ZSwgSW5jLjEmMCQGA1UE
# AxMddGhhd3RlIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0EwHhcNMTcwNDI3MDAwMDAw
# WhcNMjAwNDI2MjM1OTU5WjBrMQswCQYDVQQGEwJLUjEUMBIGA1UECAwLR3llb25n
# Z2ktZG8xFDASBgNVBAcMC1Nlb25nbmFtLXNpMRcwFQYDVQQKDA5CbHVlaG9sZSwg
# SW5jLjEXMBUGA1UEAwwOQmx1ZWhvbGUsIEluYy4wggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQCzZsRo/S6HnoSoe/rXM6plUKwQ1YgJ2p32HxSD+ka+FjW6
# qw9So5nRNFrGRIiv0HATPkKvnyHyad6NG0t0TFPzXDn3wvZQqfVkzkxhXuipeCZe
# SEQVDnWoJNbANR/l33dqgd0CYnOpO+ans1t2OLxAhaXDstZcm6bQ8FjWDiNVXsyc
# 4GMYnRlNGq1p1KTOqnLrVV1pUSEvoKX63dSFDPrDW4UuR4aho8eF5IljW4YNUOwT
# Rdq4I0/sxV8Gfz74HL8ZESIPE5kySpl+Lp5kMQc0bu+XWVNIl/6a6b2DGbx+zvop
# lYzc61LhWDzI4++XgpTcZzfh7OCmMzoqjLWVgZ6VAgMBAAGjggFqMIIBZjAJBgNV
# HRMEAjAAMB8GA1UdIwQYMBaAFFeGm1S4vqYpiuT2wuITGImFzdy3MB0GA1UdDgQW
# BBQ/mtjuSGPBwYcS7e6k/bVRO1IXZDArBgNVHR8EJDAiMCCgHqAchhpodHRwOi8v
# dGwuc3ltY2IuY29tL3RsLmNybDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYI
# KwYBBQUHAwMwbgYDVR0gBGcwZTBjBgZngQwBBAEwWTAmBggrBgEFBQcCARYaaHR0
# cHM6Ly93d3cudGhhd3RlLmNvbS9jcHMwLwYIKwYBBQUHAgIwIwwhaHR0cHM6Ly93
# d3cudGhhd3RlLmNvbS9yZXBvc2l0b3J5MFcGCCsGAQUFBwEBBEswSTAfBggrBgEF
# BQcwAYYTaHR0cDovL3RsLnN5bWNkLmNvbTAmBggrBgEFBQcwAoYaaHR0cDovL3Rs
# LnN5bWNiLmNvbS90bC5jcnQwDQYJKoZIhvcNAQELBQADggEBAFrSVSsnqxde+y35
# dRp5jmo2+yrYxXxV1qmktyA66vTupoUsq/l0G5SDgP4ZjnYv1Gfmr6fW1skwD2So
# V0GqO3rjoNH9Z5rzj/MMalEOwmptelDD36iH+sxLoK0tG7/p5OFVxoATbI0Sihdb
# 40Ebl74qKvC6x/gXTKZnEwqCg2oMhq+NEqhS7msWWX6VYj7/5MwNKam1stpaO34D
# NLYiozCiHjm4lmk3qoghq24m9qHi+rQ1e+bjXy3q8LzDCNupsqJpTf//c3in9yu4
# PABPiYwTCFG7/N9qS3zcD6+vVkispyVEj2MjPlyXIUZ8TG/0ZiAERsYkKLdY2REC
# m8udOxoxggQhMIIEHQIBATBgMEwxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwx0aGF3
# dGUsIEluYy4xJjAkBgNVBAMTHXRoYXd0ZSBTSEEyNTYgQ29kZSBTaWduaW5nIENB
# AhBoVn/LawJ5wxxFJ25Qn8+LMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEINFifnYoUDEb
# iWTBk7dB/fe1PLtfDeclZKs++mx6lHdpMA0GCSqGSIb3DQEBAQUABIIBAFylUen5
# bfmAxWDSPfgwksNplvA16eoQc1Nw3pJ54uvTTfggjNk/KX4I2Hf28Fb7yBqXBarS
# 1P887TotgK0jX4MGMC+PVeHBqQLzQGF0brBiIkkE0igpkanfH1SE3pX9fXtmqOhK
# QJGgXqNIy1PzNQgdNPiufOrV7AQT9TOSKm4w/3joJA0iY/znYzDPMcXpkD/6/89d
# XPh/MsTrdIR9Pr7UOoySgyoBNp121U/vZlDEYXaewEfrqMnAH/6/jOGv2DxPcYBf
# aXHQR9z+JZJcCdVmrCjq3MsUJLAYtS9mo9Q+73Kp55hUPqFbf3Amqhly6Pzp333M
# vSXp+br2Tt7THjOhggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQsw
# CQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNV
# BAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0
# OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3
# DQEHATAcBgkqhkiG9w0BCQUxDxcNMTkwMjIwMDcwNjM0WjAjBgkqhkiG9w0BCQQx
# FgQUDMDBsdpBXnsb5KxDsXCo2QFfOxswDQYJKoZIhvcNAQEBBQAEggEAMo3srCZJ
# cjxlOnVm2Hmb4J+uHibuOVjCtDdFyx1S+GyIg0tS8d8eh7QyrNpxdUDVdvdiuzYF
# X3tUEHBuCnwpdLTUKOh/VIY6VXEByPujz9VSginvgrawYS1ScnN8pd98L7XEs2cK
# GKoh6KKQPN0/bCNFViBFoVAuJffvNBiwmWwgRS9GmQcCPiu5ex14V5JOJezJpRzS
# 5Rs1aI27I8b1NZxxJnIXpXlMHX1lAgRmRkpKACSHwVy6WqgzAxBVrkcNt8m9lOYL
# PZFdM5PElQ6ucj7BVqvyBxPzohy6epd7SQXrURvt7I1nSC5w2Yj41Vv1zsQ5CxJH
# lsLCtYal0e/Xmw==
# SIG # End signature block
