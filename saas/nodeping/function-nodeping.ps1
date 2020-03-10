#Requires -version 5.1

Function Get-NodePingCheckList() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        # NodePing API endpoint
        $nodeping_url = 'https://api.nodeping.com/api/1/checks'
    }

    PROCESS {
        [array]$checkList = @()
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -Method Get -ContentType "application/json"
        $fromjson.PSObject.Properties | ForEach-Object { $checkList += $_.value }
    }

    END {
        if ($checkList.Count -gt 0) {
            return $checkList
        }
        else {
            [array]$checkList = @()
            return $checkList
        }
    }
}

Function Get-NodePingContactList() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        # NodePing API endpoint
        $nodeping_url = 'https://api.nodeping.com/api/1/contacts?'
    }

    PROCESS {
        [array]$contactList = @()
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -Method Get -ContentType "application/json"
        $fromjson.PSObject.Properties | ForEach-Object { $contactList += $_.value }
    }

    END {
        if ($contactList.Count -gt 0) {
            return $contactList
        }
        else {
            [array]$contactList = @()
            return $contactList
        }
    }
}

Function Get-NodePingScheduleList() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        # NodePing API endpoint
        $nodeping_url = 'https://api.nodeping.com/api/1/schedules/'
    }

    PROCESS {
        $scheduleList = @{ }
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -Method Get -ContentType "application/json"
        $fromjson.PSObject.Properties | ForEach-Object { $scheduleList.Add($_.name, $_.value) }
    }

    END {
        if ($scheduleList.Count -gt 0) {
            return $scheduleList
        }
        else {
            [array]$scheduleList = @()
            return $scheduleList
        }
    }
}

Function Get-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(ParameterSetName = 'byId')]
        [string]$checkId,

        [Parameter(ParameterSetName = 'byLabel')]
        [string]$checkLabel
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        if ($PSBoundParameters.ContainsKey('checkId')) {
            $nodeping_url = "https://api.nodeping.com/api/1/checks/$checkId"
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        if ($PSBoundParameters.ContainsKey('checkLabel')) {
            $myList = Get-NodePingCheckList -token $mySecretToken
            $myCheck = $myList | Where-Object { $_.label -eq $checkLabel } | Select-Object -First 1
            if ($myCheck) {
                $myCheckId = $myCheck._id
                $nodeping_url = "https://api.nodeping.com/api/1/checks/$myCheckId"
            }
        }
    }

    PROCESS {
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -Method Get -ContentType "application/json"
        return $fromjson
    }

    END { }
}

Function Enable-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(Mandatory = $true)]
        [string]$checkId
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }


        # NodePing API endpoint
        $nodeping_url = "https://api.nodeping.com/api/1/checks/$checkId"
    }

    PROCESS {
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method Get
        $json_req = @{
            type      = $fromjson.type
            enabled   = "true"
            threshold = $fromjson.parameters.threshold
            target    = $fromjson.parameters.target
        }
        $body = $json_req | ConvertTo-Json

        Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method PUT -Body $body | Out-Null
    }

    END { }
}

Function Disable-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(Mandatory = $true)]
        [string]$checkId
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }


        # NodePing API endpoint
        $nodeping_url = "https://api.nodeping.com/api/1/checks/$checkId"
    }

    PROCESS {
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method Get
        $json_req = @{
            type      = $fromjson.type
            enabled   = "false"
            threshold = $fromjson.parameters.threshold
            target    = $fromjson.parameters.target
        }
        $body = $json_req | ConvertTo-Json

        Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method PUT -Body $body | Out-Null
    }

    END { }
}

Function Remove-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(ParameterSetName = 'byId')]
        [string]$checkId,

        [Parameter(ParameterSetName = 'byLabel')]
        [string]$checkLabel
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        if ($PSBoundParameters.ContainsKey('checkId')) {
            # NodePing API endpoint
            $nodeping_url = "https://api.nodeping.com/api/1/checks/$checkId"
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        if ($PSBoundParameters.ContainsKey('checkLabel')) {
            $myCheck = Get-NodePingCheck -token $mySecretToken -checkLabel $checkLabel
            if ($myCheck) {
                $myCheckId = $myCheck._id
                $nodeping_url = "https://api.nodeping.com/api/1/checks/$myCheckId"
            }
        }
    }

    PROCESS {
        Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method DELETE
    }

    END { }
}

Function Copy-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(ParameterSetName = 'byId')]
        [string]$srcCheckId,

        [Parameter(ParameterSetName = 'byLabel')]
        [string]$srcCheckLabel
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        if ($PSBoundParameters.ContainsKey('srcCheckId')) {
            $checkId = $srcCheckId
            # NodePing API endpoint
            $nodeping_url = "https://api.nodeping.com/api/1/checks/$checkId"
            $srcCheck = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method Get
        }

        if ($PSBoundParameters.ContainsKey('srcCheckLabel')) {
            $myCheck = Get-NodePingCheck -token $mySecretToken -checkLabel $srcCheckLabel
            if ($myCheck) {
                $myCheckId = $myCheck._id
                $nodeping_url = "https://api.nodeping.com/api/1/checks/$myCheckId"
                $srcCheck = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method Get
            }
        }

        # NodePing POST API endpoint
        $nodeping_post_url = "https://api.nodeping.com/api/1/checks/"
    }

    PROCESS {
        if ($srcCheck) {
            $dstCheck = @{ }
            $srcCheck.psobject.properties | ForEach-Object { $dstCheck[$_.name] = $_.value }

            $dstCheck.Remove('_id')
            $dstCheck.Remove('customer_id')
            $dstCheck.Remove('uuid')
            $dstCheck.Remove('created')
            $dstCheck.Remove('modified')
            $dstCheck.Remove('status')
            $dstCheck.Remove('parameters')
            $dstCheck.Remove('label')
            $dstCheck.Remove('customer_id')
        }

        $srcCheck.parameters.psobject.Properties | ForEach-Object {
            $_tmp_propertities = $_
            $dstCheck.Add($_tmp_propertities.name, $_tmp_propertities.value)
        }

        $label_suffix = get-date -format FileDateTimeUniversal
        $label_prefix = 'CLONE'
        $label = $label_prefix + '-' + $srcCheck.label + '-' + $label_suffix
        $dstCheck.Add("label", $label)
        $body = $dstCheck | ConvertTo-Json
        $res = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_post_url -Headers $req_header -ContentType "application/json" -Method POST -Body $body
        return $res
    }

    END { }
}

Function Set-NodePingCheck() {
    [CmdletBinding(DefaultParameterSetName = 'Main')]
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(Mandatory = $true)]
        [string]$checkId,

        [Parameter(Mandatory = $false)]
        [string]$label,

        [ValidateSet("North America", "Europe", "East Asia/Oceania", "World Wide", "Default")]
        [string]$region,

        [ValidateSet("Very High", "High", "Medium", "Low", "Very Low")]
        [string]$sensitivity,

        [ValidateSet(1, 3, 5, 15, 30, 60, 240, 360, 720, 1440)]
        [int]$frequency,

        [Alias("targetHost", "targetURL")]
        [string]$target,

        [Alias("threshold")]
        [int]$timeout,

        [Parameter(ParameterSetName = 'checkTypePort')]
        [int]$targetPort,

        [Parameter(ParameterSetName = 'checkTypePort')]
        [ValidateSet("True", "False")]
        [string]$invert,

        [Parameter(ParameterSetName = 'checkTypeHttp')]
        [ValidateSet("True", "False")]
        [string]$force_ipv6_resolution,

        [Parameter(ParameterSetName = 'checkTypeHttp')]
        [ValidateSet("True", "False")]
        [string]$follow_redirect
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        # NodePing API endpoint
        $nodeping_url = "https://api.nodeping.com/api/1/checks/$checkId"
    }

    PROCESS {
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method Get
        $checkType = $fromjson.type
        $json_req = @{
            type      = $fromjson.type
            enabled   = $fromjson.enable
            threshold = $fromjson.parameters.threshold
            target    = $fromjson.parameters.target
        }

        # target
        if ($PSBoundParameters.ContainsKey('target')) {
            $json_req.Remove("target")
            $json_req.Add("target", $target)
        }

        # timeout/threshold
        if ($PSBoundParameters.ContainsKey('timeout')) {
            $json_req.Remove("threshold")
            $json_req.Add("threshold", $timeout)
        }

        if ($PSBoundParameters.ContainsKey('label')) { $json_req.Add("label", $label) }
        if ($PSBoundParameters.ContainsKey('frequency')) { $json_req.Add("interval", $frequency) }

        if ($PSBoundParameters.ContainsKey('region')) {
            switch ($PSBoundParameters.region) {
                'North America' { $json_req.Add("runlocations", 'nam') }
                'Europe' { $json_req.Add("runlocations", 'eur') }
                'East Asia/Oceania' { $json_req.Add("runlocations", 'eao') }
                'World Wide' { $json_req.Add("runlocations", 'wlw') }
                'Default' { $json_req.Add("runlocations", '') }
            }
        }

        if ($PSBoundParameters.ContainsKey('sensitivity')) {
            switch ($PSBoundParameters.sensitivity) {
                'Very High' { $json_req.Add("sens", 0) }
                'High' { $json_req.Add("sens", 2) }
                'Medium' { $json_req.Add("sens", 5) }
                'Low' { $json_req.Add("sens", 7) }
                'Very Low' { $json_req.Add("sens", 10) }
            }
        }

        if ($checkType -eq 'PORT') {
            if ($PSBoundParameters.ContainsKey('targetPort')) { $json_req.Add("port", $targetPort) }
            if ($PSBoundParameters.ContainsKey('invert')) { $json_req.Add("invert", $invert) }
        }

        if ($checkType -eq 'HTTP') {
            if ($PSBoundParameters.ContainsKey('force_ipv6_resolution')) { $json_req.Add("ipv6", $force_ipv6_resolution) }
            if ($PSBoundParameters.ContainsKey('follow_redirect')) { $json_req.Add("follow", $follow_redirect) }
        }

        $body = $json_req | ConvertTo-Json -Compress
        $res = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method PUT -Body $body
        return $res
    }

    END { }
}

Function Get-NodePingNotification() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(ParameterSetName = 'byId')]
        [string]$checkId,

        [Parameter(ParameterSetName = 'byLabel')]
        [string]$checkLabel
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        if ($PSBoundParameters.ContainsKey('checkId')) {
            $nodeping_url = "https://api.nodeping.com/api/1/notifications/$checkId"
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        if ($PSBoundParameters.ContainsKey('checkLabel')) {
            $myList = Get-NodePingCheckList -token $mySecretToken
            $myCheck = $myList | Where-Object { $_.label -eq $checkLabel } | Select-Object -First 1
            if ($myCheck) {
                $myCheckId = $myCheck._id
                $nodeping_url = "https://api.nodeping.com/api/1/notifications/$myCheckId"
            }
        }
    }

    PROCESS {
        $res = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -Method Get -ContentType "application/json"
        return $res
    }

    END { }
}


Function Get-NodePingCheckResult() {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$token,

        [Parameter(ParameterSetName = 'byId')]
        [string]$checkId,

        [Parameter(ParameterSetName = 'byLabel')]
        [string]$checkLabel
    )

    BEGIN {
        if ($PSBoundParameters.ContainsKey('token')) {
            [string]$mySecretToken = $token
        }
        elseif ($env:nodeping_token) {
            [string]$mySecretToken = $env:nodeping_token
        }
        else {
            Write-Host "nodeping_token not found. Exiting..."
            Break
        }

        if ($PSBoundParameters.ContainsKey('checkId')) {
            $nodeping_url = "https://api.nodeping.com/api/1/results/$checkId"
        }

        # See https://github.com/PowerShell/PowerShell/issues/4274
        $my_cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mySecretToken + ':' + 'mysecret'))
        $req_header = @{
            "Authorization" = "Basic $my_cred"
            "Accept"        = "application/json"
        }

        if ($PSBoundParameters.ContainsKey('checkLabel')) {
            $myList = Get-NodePingCheckList -token $mySecretToken
            $myCheck = $myList | Where-Object { $_.label -eq $checkLabel } | Select-Object -First 1
            if ($myCheck) {
                $myCheckId = $myCheck._id
                $nodeping_url = "https://api.nodeping.com/api/1/results/$myCheckId"
            }
        }

        $body = @{
            limit = 5
            clean = 1
        }
    }

    PROCESS {
        $res = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -body $body -Method Get -ContentType "application/json"
        return $res
    }

    END { }
}


