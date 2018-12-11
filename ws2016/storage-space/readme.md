Storage Space related function(s)
============================

## Basic Usage

* dot-sourcing file `function-ssadmin.ps1` is required.
* Implemented
  * New-StorageSpaceVolume
   * Parameter(s)
     * `diskIds`
     * `driveLetter`
     * `driveLabel` should be unique inside machine
  * Clear-StoragePool
   * Parameter(s)
     * `poolName` (Required)
     * `diskIds`
  * Get-DiskCount
   * Parameter(s)
     * `PartitionStyle`


## Create

```PowerShell

PS C:\Users\Administrator\Documents> New-StorageSpaceVolume -diskIds (1..3) -driveLetter E -driveLabel DBDATA1
Creating StoragePool - DBDATA1 ................. Done
Creating VirtualDisk - DBDATA1 ................. Done
Creating Volume E: ................. Done

PS C:\Users\Administrator\Documents> Get-Volume
DriveLetter FileSystemLabel FileSystem DriveType HealthStatus OperationalStatus SizeRemaining      Size
----------- --------------- ---------- --------- ------------ ----------------- -------------      ----
E           DBDATA1         NTFS       Fixed     Healthy      OK                    173.77 GB 173.87 GB
            System Reserved NTFS       Fixed     Healthy      OK                    162.88 MB    500 MB
C                           NTFS       Fixed     Healthy      OK                    127.55 GB 145.51 GB
D                                      CD-ROM    Healthy      Unknown                     0 B       0 B


PS C:\Users\Administrator\Documents> Get-StoragePool
FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly
------------ ----------------- ------------ ------------ ----------
Primordial   OK                Healthy      True         False
DBDATA1      OK                Healthy      False        False

PS C:\Users\Administrator\Documents> New-StorageSpaceVolume -diskIds 3,4 -driveLetter F -driveLabel DBDATA2
$diskIds:  3 4
$diskIds.count:  2
$disks.count:  1
Failed in validating diskIds....

PS C:\Users\Administrator\Documents> New-StorageSpaceVolume -diskIds 4,5 -driveLetter F -driveLabel DBDATA2
Creating StoragePool - DBDATA2 ................. Done
Creating VirtualDisk - DBDATA2 ................. Done
Creating Volume F: ................. Done

PS C:\Users\Administrator\Documents> Get-StoragePool
FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly
------------ ----------------- ------------ ------------ ----------
Primordial   OK                Healthy      True         False
DBDATA2      OK                Healthy      False        False
DBDATA1      OK                Healthy      False        False

PS C:\Users\Administrator\Documents> Get-Volume
DriveLetter FileSystemLabel FileSystem DriveType HealthStatus OperationalStatus SizeRemaining      Size
----------- --------------- ---------- --------- ------------ ----------------- -------------      ----
F           DBDATA2         NTFS       Fixed     Healthy      OK                    115.77 GB 115.87 GB
E           DBDATA1         NTFS       Fixed     Healthy      OK                    173.77 GB 173.87 GB
            System Reserved NTFS       Fixed     Healthy      OK                    162.88 MB    500 MB
C                           NTFS       Fixed     Healthy      OK                    127.55 GB 145.51 GB
D                                      CD-ROM    Healthy      Unknown                     0 B       0 B


PS C:\Users\Administrator\Documents> Get-VirtualDisk
FriendlyName ResiliencySettingName OperationalStatus HealthStatus IsManualAttach   Size
------------ --------------------- ----------------- ------------ --------------   ----
DBDATA2      Simple                OK                Healthy      False          116 GB
DBDATA1      Simple                OK                Healthy      False          174 GB
```


## Delete

```PowerShell
PS C:\Users\Administrator\Documents> Get-VirtualDisk
FriendlyName ResiliencySettingName OperationalStatus HealthStatus IsManualAttach   Size
------------ --------------------- ----------------- ------------ --------------   ----
DBDATA2      Simple                OK                Healthy      False          116 GB
DBDATA1      Simple                OK                Healthy      False          174 GB


PS C:\Users\Administrator\Documents> Get-StoragePool
FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly
------------ ----------------- ------------ ------------ ----------
Primordial   OK                Healthy      True         False
DBDATA2      OK                Healthy      False        False
DBDATA1      OK                Healthy      False        False


PS C:\Users\Administrator\Documents> Get-StoragePool -IsPrimordial $false | % { Clear-StoragePool -poolName $_.FriendlyName }

PS C:\Users\Administrator\Documents> Get-VirtualDisk

PS C:\Users\Administrator\Documents> Get-StoragePool
FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly
------------ ----------------- ------------ ------------ ----------
Primordial   OK                Healthy      True         False

```


## Misc.

```PowerShell
PS C:\Users\Administrator\Documents> Get-DiskCount -PartitionStyle RAW
11

PS C:\Users\Administrator\Documents> Get-DiskCount -PartitionStyle GPT
0

PS C:\Users\Administrator\Documents> Get-DiskCount -PartitionStyle MBR
1

PS C:\Users\Administrator\Documents> Get-DiskCount
11
```