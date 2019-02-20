<# Use TLS 1.2 #>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/get-collectors/
Function Get-LMCollectorInfo() {
    Param(   
        [Parameter(Mandatory = $true)]
        [string]$accessId,
     
        [Parameter(Mandatory = $true)]
        [string]$accessKey,
     
        [Parameter(Mandatory = $true)]
        [string]$company,

        [Parameter(Mandatory = $true)]
        [int]$collectorId
    )

    BEGIN {
        <# request details #>
        $httpVerb = 'GET'
        $resourcePath = '/setting/collectors/' + $collectorId
        $queryParams  = ''

        <# Construct URL #>
        $url = 'https://' + $company + '.logicmonitor.com/santaba/rest' + $resourcePath + $queryParams
    }

    PROCESS {
        <# Get current time in milliseconds #>
        $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

        <# Concatenate Request Details #>
        $requestVars = $httpVerb + $epoch + $resourcePath

        <# Construct Signature #>
        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
        $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
        $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
        $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

        <# Construct Headers #>
        $auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization",$auth)
        $headers.Add("Content-Type",'application/json')
    
        <# Make Request #>
        $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Header $headers
        return $response 
    }

    END {}
}


# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/add-a-collector/
Function Add-LMCollector() {
    Param(   
        [Parameter(Mandatory = $true)]
        [string]$accessId,
     
        [Parameter(Mandatory = $true)]
        [string]$accessKey,
     
        [Parameter(Mandatory = $true)]
        [string]$company
    )

    BEGIN {
        <# request details #>
        $httpVerb = 'POST'
        $resourcePath = '/setting/collectors/'
        $data = '{"needAutoCreateCollectorDevice":false}'

        <# Construct URL #>
        $url = 'https://' + $company + '.logicmonitor.com/santaba/rest' + $resourcePath + $queryParams
    }

    PROCESS {
        <# Get current time in milliseconds #>
        $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

        <# Concatenate Request Details #>
        $requestVars = $httpVerb + $epoch + $data + $resourcePath

        <# Construct Signature #>
        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
        $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
        $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
        $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

        <# Construct Headers #>
        $auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization",$auth)
        $headers.Add("Content-Type",'application/json')
    
        <# Make Request #>
        $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers
        $status = $response.status
        if ($status -eq 200) {
            return $response.data.id
        } else {
            return -1
        }
    }

    END {}
}


# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/delete-a-collector/
Function Remove-LMCollector() {
    Param(   
        [Parameter(Mandatory = $true)]
        [string]$accessId,
     
        [Parameter(Mandatory = $true)]
        [string]$accessKey,
     
        [Parameter(Mandatory = $true)]
        [string]$company,

        [Parameter(Mandatory = $true)]
        [int]$collectorId
    )

    BEGIN {
        <# request details #>
        $httpVerb = 'DELETE'
        $resourcePath = '/setting/collectors/' + $collectorId
        $queryParams  = ''

        <# Construct URL #>
        $url = 'https://' + $company + '.logicmonitor.com/santaba/rest' + $resourcePath + $queryParams
    }

    PROCESS {
        <# Get current time in milliseconds #>
        $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

        <# Concatenate Request Details #>
        $requestVars = $httpVerb + $epoch + $resourcePath

        <# Construct Signature #>
        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
        $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
        $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
        $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

        <# Construct Headers #>
        $auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization",$auth)
        $headers.Add("Content-Type",'application/json')
    
        <# Make Request #>
        $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Header $headers
        $status = $response.status
        if ($status -eq 200) {
            return $true
        } else {
            return $false
        }
    }

    END {}
}

# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/downloading-a-collector-installer/
Function Save-LMCollectorInstaller() {
    Param(   
        [Parameter(Mandatory = $true)]
        [string]$accessId,
     
        [Parameter(Mandatory = $true)]
        [string]$accessKey,
     
        [Parameter(Mandatory = $true)]
        [string]$company,

        [Parameter(Mandatory = $true)]
        [int]$collectorId,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Win64","Win32","Linux64","Linux32")]
        [string]$installerType = 'Win64',

        [Parameter(Mandatory = $false)]
        [string]$downloadPath = 'c:\windows\temp'
    )

    BEGIN {
        <# request details #>
        $httpVerb = 'GET'
        $resourcePath = '/setting/collectors/' + $collectorId + '/installers/' + $installerType
        $queryParams  = ''

        <# Construct URL #>
        $url = 'https://' + $company + '.logicmonitor.com/santaba/rest' + $resourcePath + $queryParams
    }

    PROCESS {
        <# Get current time in milliseconds #>
        $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

        <# Concatenate Request Details #>
        $requestVars = $httpVerb + $epoch + $resourcePath

        <# Construct Signature #>
        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
        $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
        $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
        $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

        <# Construct Headers #>
        $auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization",$auth)
        $headers.Add("Content-Type",'application/json')
    
        if ($installerType -in ("Win64","Win32")) {
            $installer_ext = 'exe'
        } else {
            $installer_ext = 'bin'
        }

        <# Make Request #>       
        $installer_file = "LM-col-$collectorId-$(get-random)-installer-$installerType.$installer_ext"
        $installer_file_path = $downloadPath + '\' + $installer_file
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Headers $headers -Uri $url -Method $httpVerb -UseBasicParsing -OutFile $installer_file_path
        if ($?) { 
            Write-Host "Download location: $installer_file_path" 
            if (Test-Path $installer_file_path) {
                return $installer_file_path
            }
        } else {
            return $null
        }
    }

    END {}
}

