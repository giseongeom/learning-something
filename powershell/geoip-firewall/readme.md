Convert unixtime with PowerShell
============================

## Basic Usage

* dot-sourcing file `function_unixtime.ps1` is required.
* Implemented
  * ConvertFrom-UnixTime
    
    * Parameter(s)
      * `unixtime` (Required) 
    
  * ConvertFrom-UnixTimeMillisecond
  
    * Parameter(s)
      * `unixtime` (Required) 
  
  * ConvertTo-UnixTime
  
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
Friday, May 22, 2020 4:17:54 PM

PS > ConvertTo-UnixTime -Date $thistime
1590131874

PS > ConvertFrom-UnixTime -unixtime 1590131874
Friday, May 22, 2020 4:17:54 PM

PS > ConvertTo-UnixTimeMillisecond -Date $thistime
1590131874091.26

PS > ConvertFrom-UnixTimeMillisecond -unixtime 1590131874091.26
Friday, May 22, 2020 4:17:54 PM

```

​        

## References

