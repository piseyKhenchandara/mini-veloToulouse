@echo off
setlocal

set ADB="C:\Users\ASUS\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo [1/4] Killing any old emulator session...
%ADB% emu kill >nul 2>&1
timeout /t 3 /nobreak >nul

echo [2/4] Starting emulator (cold boot + SwiftShader)...
start "" flutter emulators --launch Medium_Phone_API_36.1

echo [3/4] Waiting for emulator to come online...
:wait_device
%ADB% devices 2>nul | find "emulator" >nul
if errorlevel 1 (
    timeout /t 3 /nobreak >nul
    goto wait_device
)

:wait_boot
%ADB% shell getprop sys.boot_completed 2>nul | find "1" >nul
if errorlevel 1 (
    echo    Still booting...
    timeout /t 4 /nobreak >nul
    goto wait_boot
)

echo [4/4] Emulator ready! Launching app...
timeout /t 2 /nobreak >nul
flutter run
