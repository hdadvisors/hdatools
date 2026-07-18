@echo off
setlocal
cd /d "%~dp0"
set "PY=python"
where python >nul 2>nul || set "PY=C:\Python313\python.exe"
"%PY%" generate_dashboard.py %*
if errorlevel 1 (
    echo.
    echo Dashboard generation FAILED. See message above.
    pause
    exit /b 1
)
start "" "%~dp0dashboard.html"
endlocal
