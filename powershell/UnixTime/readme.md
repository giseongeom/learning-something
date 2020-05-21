Convert unixtime with PowerShell
============================

## Basic Usage

* dot-sourcing file `function_unixtime.ps1` is required.
* Implemented
  * ConvertFrom-UnixTimeMillisecond
    
    * Parameter(s)
      * `Date` (Required) 
    
  * ConvertTo-UnixTimeMillisecond

    * Parameter(s)
      * `Date` (Required) 

  * ConvertTo-UnixTimeNanosecond
    * Parameter(s)
      - `Date` (Required) 
    
       

​    


## Convert datetime to/from unix time

```PowerShell
PS > . .\function-unixtime.ps1
PS > $thistime = get-date
PS > $thistime

Thursday, May 21, 2020 2:01:15 PM

PS > ConvertTo-UnixTimeMillisecond -Date $thistime
1590069675064.92

PS > ConvertFrom-UnixTimeMillisecond -Date 1590069675064.92

Thursday, May 21, 2020 2:01:15 PM

```

​        

## References

