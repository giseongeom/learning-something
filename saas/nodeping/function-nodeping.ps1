Function Get-NodePingCheckList() {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$token
    )

    BEGIN {
        $mySecretToken = $token

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
        if ($?) {
            $fromjson.PSObject.Properties | ForEach-Object { $checkList += $_.value }
        }
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

Function Get-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$token,

        [Parameter(Mandatory = $true)]
        [string]$checkId
    )

    BEGIN {
        $mySecretToken = $token

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
        $fromjson = Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -Method Get -ContentType "application/json"
    }

    END {
        if ($?) {
            return $fromjson
        }
    }
}

Function Enable-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$token,

        [Parameter(Mandatory = $true)]
        [string]$checkId
    )

    BEGIN {
        $mySecretToken = $token

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
        } | ConvertTo-Json -Compress
        $body = $json_req

        Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method PUT -Body $body | Out-Null
    }

    END { }
}

Function Disable-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$token,

        [Parameter(Mandatory = $true)]
        [string]$checkId
    )

    BEGIN {
        $mySecretToken = $token

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
        } | ConvertTo-Json -Compress
        $body = $json_req

        Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method PUT -Body $body | Out-Null
    }

    END { }
}


Function Remove-NodePingCheck() {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$token,

        [Parameter(Mandatory = $true)]
        [string]$checkId
    )

    BEGIN {
        $mySecretToken = $token

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
        Invoke-RestMethod -UseBasicParsing -Uri $nodeping_url -Headers $req_header -ContentType "application/json" -Method DELETE | Out-Null
    }

    END { }
}