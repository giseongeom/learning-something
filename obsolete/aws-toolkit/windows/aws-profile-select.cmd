@echo off
::    -----------------------------------------------------------------
::    * Subject : AWS profile / region selection script
::    * Author  : GiSeong Eom <jurist@kldp.org>
::    * Created : 2016.01.07
::    * Updated : 2016.04.07
::    -----------------------------------------------------------------
SETLOCAL ENABLEDELAYEDEXPANSION


SET _func_version=0.3-build-20160407
SET PROG_FILE_NAME=%~nx0
SET AWS_RZ_LISTFILE=%TEMP%\aws-region.txt
SET AWS_CRED_LISTFILE=%TEMP%\aws-credential.txt
SET AWS_CRED=%USERPROFILE%\.aws\credentials
del /q /f %AWS_RZ_LISTFILE% 2> nul
del /q /f %AWS_CRED_LISTFILE% 2> nul
IF NOT EXIST %AWS_CRED% (
  CALL :file_not_found_display "AWS Credentials" %AWS_CRED%
  GOTO :done
)
REM
REM newline variable needs 2 blank lines. So do not remove lines below
set newline=^


set region_list=tokyo,ap-northeast-1 seoul,ap-northeast-2 n.virgina,us-east-1 n.california,us-west-1 oregon,us-west-2 singapore,ap-southeast-1 sydney,ap-southeast-2 saopaulo,sa-east-1 ireland,eu-west-1 frankfurt,eu-central-1
for /F %%i in ("%region_list: =!newline!%") do (
  set _region_list_output=%%i
  echo !_region_list_output!>> %AWS_RZ_LISTFILE%
)

for /F "delims=" %%i in ('findstr /i "[" %AWS_CRED%') do (
  set profile_user=%%i
  for /f "delims=" %%a in (%AWS_CRED%) do (
    set ln=%%a
    if "x!ln:~0,1!"=="x[" (
       set currarea=!ln:~0,-1!]
    ) else (
       for /F "tokens=1,3" %%i in ("!ln!") do (
         if "x!currarea!"=="x!profile_user!" (
           if %%i==aws_access_key_id ( 
             set aws_accesskey=%%j
             set redady_count=1
           )
           if %%i==aws_secret_access_key (
             set aws_secretkey=%%j
             set redady_count=2
           )
           if !redady_count!==2 (
             set aws_tmp_profile=!profile_user:~1,-1!,!aws_accesskey!,!aws_secretkey!
             echo !aws_tmp_profile!>>%AWS_CRED_LISTFILE%
             set redady_count=0
           )
         )
        )
    )
  )
)





IF "#%1#" == "##" (
  CALL :usage
  GOTO :done
)
IF NOT "#%3#" == "##" (
  CALL :usage_display_error
  CALL :usage
  GOTO :done
)
GOTO :selection



:selection
IF /I "%1" == "-r" (
  IF /I #%2# == ## (
    CALL :name_not_found_display *REGION*
    CALL :usage  
    CALL :list-region
    GOTO :done
)
  SET AWS_RZ_SELECTION=%2
  GOTO :select-region
)
IF /I "%1" == "-p" (
  IF /I #%2# == ## (
    CALL :name_not_found_display *PROFILE*
    CALL :usage
    CALL :list-profile
    GOTO :done
)
  SET AWS_PROFILE_SELECTION=%2
  GOTO :select-profile
)
IF /I "%1" == "-l" (
  IF /I #%2# == ## (
    CALL :list-region
    CALL :list-profile
    GOTO :done
)
)  
CALL :usage_display_error
CALL :usage
GOTO :done


:list-profile
echo.
FOR /f "eol=# delims=, tokens=1-3" %%i in (%AWS_CRED_LISTFILE%) do (
  set SecretAccesskey_tmp=%%k
  echo. AWS Profile: %%i
  echo.     AccessKeyId: %%j
  echo.     SecretAccesskey: **********!SecretAccesskey_tmp:~-5!
)
echo.
exit /b 0


:list-region
echo.
FOR /f "eol=# delims=, tokens=1-2" %%i in (%AWS_RZ_LISTFILE%) do (
  echo. AWS Region: %%i [%%j]
)
echo.
exit /b 0


:select-region
FOR /f "eol=# delims=, tokens=1-2" %%i in ('findstr /i /C:"%AWS_RZ_SELECTION%" %AWS_RZ_LISTFILE%') do (
  SET AWS_RZ_SELECTED=%%i
  SET AWS_RZ_NAME_SELECTED=%%j
)
IF /I "%AWS_RZ_SELECTION%" == "%AWS_RZ_SELECTED%" (
  SET AWS_DEFAULT_REGION=%AWS_RZ_NAME_SELECTED%
  SET AWS_DEFAULT_REGION_SELECTED=%AWS_RZ_SELECTED%
  echo. 
  echo ---------------------------------------------------------------------
  echo AWS_DEFAULT_REGION: %AWS_RZ_SELECTION% [%AWS_RZ_NAME_SELECTED%]
  echo ---------------------------------------------------------------------
  echo.    
  ENDLOCAL & SET AWS_DEFAULT_REGION=%AWS_RZ_NAME_SELECTED%& SET AWS_DEFAULT_REGION_SELECTED=%AWS_RZ_SELECTED%
  GOTO :done
) ELSE (
  echo.
  echo ---------------------------------------------------------------------
  echo %AWS_RZ_SELECTION% is incorrect. Please ensure correct region name
  echo ---------------------------------------------------------------------
  echo.
  CALL :list-region
  GOTO :done
)


:select-profile
FOR /f "eol=# delims=, tokens=1-3" %%i in ('findstr /i /C:"%AWS_PROFILE_SELECTION%" %AWS_CRED_LISTFILE%') do (
  SET AWS_PROFILE_SELECTED=%%i
  SET AWS_PROFILE_ACCESS_KEY=%%j
  SET AWS_PROFILE_SECRET_KEY=%%k
)
IF /I "%AWS_PROFILE_SELECTION%" == "%AWS_PROFILE_SELECTED%" (
  SET AWS_ACCESS_KEY_ID=%AWS_PROFILE_ACCESS_KEY%
  SET AWS_SECRET_ACCESS_KEY=%AWS_PROFILE_SECRET_KEY%
  echo. 
  echo ---------------------------------------------------------------------
  echo AWS_ACCESS_KEY_ID: %AWS_PROFILE_ACCESS_KEY% [%AWS_PROFILE_SELECTED%]
  echo AWS_SECRET_ACCESS_KEY: **********%AWS_PROFILE_SECRET_KEY:~-5%
  echo ---------------------------------------------------------------------
  echo.    
  ENDLOCAL & SET AWS_ACCESS_KEY_ID=%AWS_PROFILE_ACCESS_KEY%& SET AWS_SECRET_ACCESS_KEY=%AWS_PROFILE_SECRET_KEY%& SET AWS_SELECTED_PROFILE=%AWS_PROFILE_SELECTED%
  GOTO :done
) ELSE (
  echo.
  echo ---------------------------------------------------------------------
  echo %AWS_PROFILE_SELECTION% is incorrect. Please ensure correct profile name
  echo ---------------------------------------------------------------------
  echo.
  CALL :list-profile
  GOTO :done
)


:usage_display_error
echo.
echo Please enter correct argument.
echo.
exit /b 0


:file_not_found_display
echo.
echo %1: %2 not found. Exiting... 
echo.
exit /b 0


:name_not_found_display
echo.
echo %1 is required.
echo.
exit /b 0



:usage
IF DEFINED AWS_DEFAULT_REGION (
  IF DEFINED AWS_DEFAULT_REGION_SELECTED (
    echo.
    echo AWS_DEFAULT_REGION: %AWS_DEFAULT_REGION% [%AWS_DEFAULT_REGION_SELECTED%]
  ) ELSE (
    echo AWS_DEFAULT_REGION: %AWS_DEFAULT_REGION%
  )
)

IF DEFINED AWS_ACCESS_KEY_ID (
  IF DEFINED AWS_SELECTED_PROFILE (
    echo AWS_ACCESS_KEY_ID: %AWS_ACCESS_KEY_ID% [%AWS_SELECTED_PROFILE%]
    echo AWS_SECRET_ACCESS_KEY: **********%AWS_SECRET_ACCESS_KEY:~-5%
  ) ELSE (
    echo AWS_ACCESS_KEY_ID: %AWS_ACCESS_KEY_ID%
    echo AWS_SECRET_ACCESS_KEY: **********%AWS_SECRET_ACCESS_KEY:~-5%
  )
)
echo.

echo -------------------------------------------------------------------------------------
echo #   
echo #    Usage: %PROG_FILE_NAME% [ -l ^| -p PROFILE ^| -r REGION ]
echo #    Options:
echo #         -l             List the Region names and AWS Credential currently stored.
echo #         -p PROFILE     Set the AWS Default Credential, using the given AWS profile.
echo #         -r REGION      Set the AWS Default Region, using the given city name.
echo #   
echo #                                                         Version: %_func_version%
echo -------------------------------------------------------------------------------------
exit /b 0



:done
GOTO :EOF

