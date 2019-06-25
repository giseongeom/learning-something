$api_key       = '****'
$app_key       = '****'
$url_base      = "https://app.datadoghq.com/" 
$url_signature = "api/v1/monitor"

function Get-DDMonitor {
  $datadog_url = $url_base `
                + $url_signature `
                + "?api_key=$api_key" `
                + "&" + "application_key=$app_key" 

  $result = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $datadog_url
  Return $result
}


function Remove-DDRcpt() {
    Param
    (
        [Parameter(Mandatory = $true)]
        $monitor,

        [Parameter(Mandatory = $true)]
        $target_rcpt
    )


  [int]$dd_monitor_id        = $monitor.id
  [string]$dd_monitor_query  = $monitor.query
  [string]$dd_monitor_name   = $monitor.name
  [string]$dd_monitor_msg    = $monitor.message

  $dd_monitor_msg = $dd_monitor_msg -replace "$target_rcpt",''

  $dd_monitor_body = New-Object psobject
  $dd_monitor_body | Add-Member -MemberType NoteProperty -TypeName string -Name query -Value $dd_monitor_query
  $dd_monitor_body | Add-Member -MemberType NoteProperty -TypeName string -Name name -Value $dd_monitor_name
  $dd_monitor_body | Add-Member -MemberType NoteProperty -TypeName string -Name message -Value $dd_monitor_msg

  $dd_body = $dd_monitor_body | ConvertTo-Json

  $datadog_url = $url_base `
                + $url_signature `
                + '/' + $dd_monitor_id `
                + "?api_key=$api_key" `
                + "&" + "application_key=$app_key" 

  $result = Invoke-RestMethod -Method Put -UseBasicParsing -Uri $datadog_url -Body $dd_body -Verbose
  Return $result
}

