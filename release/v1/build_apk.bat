@echo off
REM ==============================================================================
REM BAT WRAPPER CHO SCRIPT BUILD APK SHOPPEFAKE MOBILE
REM ==============================================================================
title ShoppeFake Mobile - Build APK Release

echo [INFO] Dang khoi chay script build PowerShell build_apk.ps1...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_apk.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Qua trinh build APK gap loi! Vui long xem log ben tren.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [SUCCESS] Hoan tat! Nhap phim bat ky de dong cua so nay...
pause >nul
