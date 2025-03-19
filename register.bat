@echo off
setlocal

:: 定义计划任务名称和描述
set TaskName=StarterTask
set TaskDescription=Starter: 一个用于快速启动和管理任务的计划任务
set BatFilePath=%~dp0run.ps1.bat

:: 检查是否以管理员身份运行
fltmc >nul 2>&1 || (
    echo 需要管理员权限，正在重新以管理员模式运行...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

:: 检查计划任务是否存在并且路径是否正确
schtasks /Query /TN "%TaskName%" /FO LIST 2>nul | findstr /C:"TaskName:" >nul
if %errorlevel% equ 0 (
    schtasks /Query /TN "%TaskName%" /FO LIST | findstr /C:"%BatFilePath%" >nul
    if %errorlevel% equ 0 (
        echo 计划任务 "%TaskName%" 已正确存在，无需更新。
    ) else (
        echo 计划任务 "%TaskName%" 存在，但路径错误，正在更新...
        schtasks /Delete /TN "%TaskName%" /F
        goto CreateTask
    )
) else (
    echo 计划任务 "%TaskName%" 不存在，正在创建...
    :CreateTask
    schtasks /Create /TN "%TaskName%" /TR "\"%BatFilePath%\"" /SC ONLOGON /RL HIGHEST /F /RU "%USERNAME%" /DELAY 0000:10
    echo 计划任务创建完成！
)

endlocal
pause
