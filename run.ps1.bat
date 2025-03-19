@echo off
:: 设置脚本目录
cd /d "%~dp0"

:: 定义 PowerShell 脚本路径
set "PowershellFilePath=%~dp0starter.ps1"

:: 确保 PowerShell 脚本存在
if not exist "%PowershellFilePath%" (
    echo Error: PowerShell script not found at %PowershellFilePath%
    pause
    exit /b 1
)

:: 启动 PowerShell 脚本，保持后台运行，避免窗口自动关闭
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%PowershellFilePath%" -WindowStyle Hidden

:: 确保 PowerShell 进程持续运行
:check
timeout /t 5 >nul
tasklist | findstr /i "powershell.exe" >nul
if %errorlevel% neq 0 (
    echo PowerShell process not found, restarting...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%PowershellFilePath%" -WindowStyle Hidden
)
goto check
