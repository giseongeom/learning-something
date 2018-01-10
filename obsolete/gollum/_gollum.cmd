@echo off
SETLOCAL
REM See http://stackoverflow.com/questions/16623780/how-to-get-windows-batchs-parent-folder
for %%i in ("%~dp0..") do set "parent=%%~fi"
cd /d %USERPROFILE%\Documents\Github\TIL && %parent%\jruby\bin\gollum --config config.rb
ENDLOCAL
