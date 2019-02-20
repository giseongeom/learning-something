@echo off
SETLOCAL

SET LOCAL_ROOT=%~dp0
CD /D %LOCAL_ROOT%

cmd /c az account set --subscription %subscription_id%
cmd /c az group deployment create -g %resource_group%  --template-file appgwdeploy.json --parameters @appgwdeploy.parameters.json --parameters @backend.json --verbose



ENDLOCAL