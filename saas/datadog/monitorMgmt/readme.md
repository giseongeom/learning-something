Datadog Monitor Management
============================

## Basic Usage

* dot-sourcing file `function-ddmgmt.ps1` is required.
* Implemented
  * Common Parameter(s)
    * `api_key`, `app_key` is always required for authentication
  * Get-DDMontior
  * Remove-DDRcpt
    * Parameter(s)
      - `collectorId` (Required)
  * Remove-DDRcpt
    * Parameter(s)
      - `monitor` (Required)
      - `target_rcpt` (Required)


## References

* [DataDog API Reference](https://docs.datadoghq.com/api/?lang=bash#monitors)

