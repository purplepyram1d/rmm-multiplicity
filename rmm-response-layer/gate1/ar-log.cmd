@echo off
setlocal enableextensions
REM Gate 1 wrapper = independent dispatch observer. Generates an invocation id, logs wrapper-start/end
REM around the PowerShell run to a WRAPPER-OWNED log, and forwards stdin + the invocation id to the script.
set "RDIR=C:\Lab\response"
set "WLOG=%RDIR%\ar-wrapper.log"
if not exist "%RDIR%" mkdir "%RDIR%"
set "INVID=INV-%RANDOM%%RANDOM%%RANDOM%"
>>"%WLOG%" echo %DATE% %TIME% wrapper-start invocation=%INVID%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0ar-log.ps1" -InvocationId %INVID%
set "RC=%ERRORLEVEL%"
>>"%WLOG%" echo %DATE% %TIME% wrapper-end invocation=%INVID% exit=%RC%
exit /b %RC%
