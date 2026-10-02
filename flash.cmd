@echo off
setlocal EnableExtensions
rem Batch flasher for Xiaomi LYWSD03MMC using pvvx's TLSR825xComFlasher.py.
rem Usage: flash.cmd [PORT] [FIRMWARE]     e.g.  flash.cmd COM5
rem Set TACT to change the activation window in ms (default 2000).

set "ROOT=%~dp0"
set "PY=%ROOT%.venv\Scripts\python.exe"
set "PORT=%~1"
if "%PORT%"=="" set "PORT=COM3"
set "FW=%~2"
if "%FW%"=="" set "FW=%ROOT%firmware\Z03MMC_v0139.bin"
if "%TACT%"=="" set "TACT=2000"

if not exist "%PY%" (echo Python venv missing: %PY% & exit /b 1)
if not exist "%FW%" (echo Firmware not found: %FW% & exit /b 1)

set /a OK=0, FAIL=0
:next
echo.
echo ==== %PORT% ^| %FW% ^| ok: %OK%  failed: %FAIL%
echo Wire up the next device and press any key to flash (Ctrl+C to quit)...
pause >nul
"%PY%" "%ROOT%TLSR825xComFlasher.py" -p %PORT% -t %TACT% -r wf 0 "%FW%"
if errorlevel 1 (
    set /a FAIL+=1
    echo *** FAILED - check wiring, or retry with power-cycle during activation ***
) else (
    set /a OK+=1
    echo *** OK - device rebooted into Zigbee pairing mode ***
)
goto next
