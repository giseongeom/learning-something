Set-Location $PSScriptRoot -Verbose
$env:DOTNET_ROOT="C:\tools\dotnet"
Publish-AWSPowerShellLambda -ScriptPath .\RDPLockDown.ps1 -Name RDPLockDown -Region ap-northeast-2 -Verbose 