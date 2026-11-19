@echo off
echo ========================================================
echo   Erasmus Student Guide - Android APK Release Build
echo   Yusuf Taskin - Week 4 Delivery
echo ========================================================
echo.
cd /d "%~dp0\.."
echo Building Flutter Android Release APK...
flutter build apk --release
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo   BUILD SUCCESSFUL!
    echo   Output APK: build\app\outputs\flutter-apk\app-release.apk
    echo ========================================================
) else (
    echo.
    echo [ERROR] Android APK build failed with code %ERRORLEVEL%.
)
pause
