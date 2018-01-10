@echo off
SETLOCAL

REM  HOW TO escape % character in setx
REM
REM  1) prefix ^ before % (when used at Command Prompt)
REM  2) prefix % one more before % (when used at .cmd / .bat script)
REM  3) Do not use prefix at PS prompt
REM
REM


IF #%1# == ## (
  GOTO :usage
) ELSE (
  GOTO :selection
)

:selection
IF /I %COMPUTERNAME% == GISEONG-PC   SET USBDRV=H
IF /I %COMPUTERNAME% == GISEONG-HOME SET USBDRV=F
IF /I %1 == toUSB       GOTO :tousb
IF /I %1 == fromUSB     GOTO :fromusb
echo.
echo Please enter correct argument.
echo.
GOTO :usage


:tousb
SET COPY_ARGS=/mir /timfix /np /nfl /ndl /j
robocopy %USERPROFILE%\Documents\Bitbucket\          %USBDRV%:\MYFILES\Bitbucket      %COPY_ARGS%
robocopy %USERPROFILE%\devtools\                     %USBDRV%:\MYFILES\devtools       %COPY_ARGS%
robocopy %USERPROFILE%\Documents\GitHub\             %USBDRV%:\MYFILES\GitHub         %COPY_ARGS%
goto :end


:fromusb
SET COPY_ARGS=/mir /timfix /np /nfl /ndl
robocopy %USBDRV%:\MYFILES\Bitbucket          %USERPROFILE%\Documents\Bitbucket     %COPY_ARGS%
robocopy %USBDRV%:\MYFILES\devtools           %USERPROFILE%\Devtools                %COPY_ARGS%
robocopy %USBDRV%:\MYFILES\GitHub             %USERPROFILE%\Documents\GitHub        %COPY_ARGS%
goto :end


:usage
echo ---------------------------------------------------------------------
echo # Filename: %0
echo #    Usage: %0 ^(ToUSB^|^FromUSB)
echo #  
echo #   
echo ---------------------------------------------------------------------
GOTO :end


:end
ENDLOCAL
