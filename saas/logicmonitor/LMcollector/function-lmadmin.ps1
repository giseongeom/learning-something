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


# SIG # Begin signature block
# MIIa1gYJKoZIhvcNAQcCoIIaxzCCGsMCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD6+IwNg47E9E0f
# gt97oDvFQjIt7UU5kH7y/QXIcfUGsqCCFgswggPuMIIDV6ADAgECAhB+k+v7fMZO
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
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIDwHi/nsUoKg
# eEQ9L+R8rh9DesjL2EYDASIO1bbV79v8MA0GCSqGSIb3DQEBAQUABIIBAFI4zcqU
# HMbQhhFcgPKa5Tji6elEa+mtMfSMOLBa5d2z5e1RsrNkcOsPRjWqmQcTR0XSz5Uf
# qzw2A7C8khHPdX2A46TtZRbBm7JB3TcSV5WOTuI7rnp0XVSmAWPijdl0z66t5XeO
# DFwhVYlVqbcru0/pPbFJUNr9XktY/qjVJFnxhIelwIj+gf2cO7eO18N/9GIyhKI1
# WdI5juJKIQ39YoZjMqse+oAhHTfZWjs4NUeGk/rN1yr9OuCYiAG7lO45zLoqlcy6
# ioOLIOfvnh+Z/Sqb1bB0I0UWAPcsfqx7MaSVwlvTQDV7673LwC2UjZehL6MNHuUT
# DbUtkGmQ1NSDoSShggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQsw
# CQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNV
# BAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0
# OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3
# DQEHATAcBgkqhkiG9w0BCQUxDxcNMTkwMjIwMDcwNTUzWjAjBgkqhkiG9w0BCQQx
# FgQU+vTtmfqqhkcNHy9zUXpGhJUhefwwDQYJKoZIhvcNAQEBBQAEggEAhtJeRRSz
# 9dRaZTwmeqKe9683i+HPvq+RiydDtEpAZqRkIyt3np6xVOvTYxRk0+EeNEWbKX/s
# W5wFDJBKJauBu0posX4q0cAuw+w23F2ueeW4DuoXsJMQrmL6XwzVBlJnOCmlqFPb
# ccvKi3+zXO8x5SU1V9XlySgodagwnmAcSt+grgjhbvoAFHO6sFRInJPMumumtjtr
# BUu9kaPl2cUSfEDGIPHSsXUYbLBFfoz/y7Aq/BSXVAh4uEVGCHZf5pODQJpnlBk2
# NnwshUi8Vu8c/y3duZHtjMI51xLpIP6If2wkQzZ7h4mrr6fSCUb//5wFtUJz3RKi
# 85p8pkjvyJW9YA==
# SIG # End signature block
