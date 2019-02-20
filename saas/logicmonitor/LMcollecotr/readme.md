LogicMonitor Collector Management
============================

## Basic Usage

* dot-sourcing file `function-lmadmin.ps1` is required.
* Implemented
  * Common Parameter(s)
    * `accessId`, `accessKey`, `company`  is always required for authentication
  * Get-LMCollectorInfo
    * Parameter(s)
      * `collectorId` (Required)
  * Add-LMCollector
  * Remove-LMCollector
    * Parameter(s)
      - `collectorId` (Required)
  * Save-LMCollectorInstaller
    * Parameter(s)
      - `collectorId` (Required)
      - `installerType` : `Win64` is default
      - `downloadPath`:  `c:\windows\temp` is default

​    

​    


## Add Collector

```PowerShell
PS > . .\function-lmadmin.ps1
PS > $accessId  = 'abcdefg'
PS > $accessKey = '0123456789'
PS > $company   = 'mycompany'

PS > Add-LMCollector -accessId $accessId -accessKey $accessKey -company $company
554

PS > $col = Get-LMCollectorInfo -accessId $accessId -accessKey $accessKey -company $company -collectorId 554

PS > $col.data.id
554

PS > $col.data.platform
n/a

```

​    

​    

## Download installer

```PowerShell
PS > Save-LMCollectorInstaller -accessId $accessId -accessKey $accessKey -company $company -collectorId 554
Download location: c:\windows\temp\LM-col-554-1362504490-installer-Win64.exe
c:\windows\temp\LM-col-554-1362504490-installer-Win64.exe

PS > $col = Get-LMCollectorInfo -accessId $accessId -accessKey $accessKey -company $company -collectorId 554

PS > $col.data.platform
windows

```

>  After download is complete, the `platform`attribute of collector is changed to windows or linux. And you can not change the value.

​    

​    

## Delete Collector

```PowerShell
PS > Remove-LMCollector -accessId $accessId -accessKey $accessKey -company $company -collectorId 554
True
```

> Whenever I delete collecotr via REST API,  the status is code always `200`.  Even the `collecotrId` is non-exist on LM side, the result is same. So you may ignore the return value of this function.

​    

​    

## References

* [LogicMonitor - REST API v1 Examples](https://www.logicmonitor.com/support/rest-api-developers-guide/v1/rest-api-v1-examples/)
* [LogicMonitor - Managing Collectors with the REST API](https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/)

