@echo off
echo ========================================================
echo   Erasmus Student Guide - Flutter Web Release Build
echo   Yusuf Taskin - Week 4 Delivery
echo ========================================================
echo.
cd /d "%~dp0\.."
echo Building Flutter Web (Release mode)...
flutter build web --release
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo   BUILD SUCCESSFUL!
    echo   Output directory: build/web
    echo   Deploy target: Netlify (https://incomparable-dango-1e5aae.netlify.app/)
    echo ========================================================
) else (
    echo.
    echo [ERROR] Web build failed with code %ERRORLEVEL%.
)
pause
