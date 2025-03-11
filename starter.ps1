# 🚀 Starter 服务管理脚本
# 🎯 该脚本用于在 Windows 上注册并运行一个自定义 PowerShell 服务，并提供任务管理功能

# 定义服务名称和路径
$ServiceName = "Starter"
$ScriptPath = "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"
$ServiceExePath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

# 任务运行时间存储
$Global:TaskStartTime = @{}
$Global:TaskProcesses = @{}

# 检查服务是否已经存在
if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
    # 检查是否以管理员身份运行
    $WindowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($WindowsIdentity)
    $AdminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    if (-not $WindowsPrincipal.IsInRole($AdminRole)) {
        Write-Host "⚠️ 当前进程未以管理员身份运行，正在尝试提升权限..." -ForegroundColor Yellow
        Start-Process -FilePath $ServiceExePath -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptPath`"" -Verb RunAs
        exit
    }

    Write-Host "🛠️ 服务未注册，正在注册服务..." -ForegroundColor Cyan
    
    # 创建 Windows 服务
    $ServiceArgs = "-ExecutionPolicy Bypass -File `"$ScriptPath`""
    New-Service -Name $ServiceName -BinaryPathName "$ServiceExePath -WindowStyle Hidden $ServiceArgs" -DisplayName "Starter Service" -Description "Starter: 一个用于快速启动和管理任务的 Windows 服务。" -StartupType Automatic
    
    Write-Host "✅ 服务已注册，请手动启动或重启系统后自动启动。" -ForegroundColor Green
    Read-Host "🔄 按 Enter 键退出..."
    exit
}

# 在新终端窗口中运行命令的函数
function NewTerminalRun {
    param (
        [string]$Name,
        [string]$Command,
        [string]$WorkingDirectory
    )

    # 记录任务启动时间
    $Global:TaskStartTime[$Name] = Get-Date
    
    # 启动任务进程
    $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-Command", $Command -WorkingDirectory $WorkingDirectory -PassThru
    
    Write-Host "🚀 任务 [$Name] 已启动，PID: $($process.Id), 运行目录: $WorkingDirectory" -ForegroundColor Green
    return $process
}

# 运行任务
function RunTask {
    Write-Host "✨ Starter 服务正在运行..." -ForegroundColor Blue
    
    # 定义任务列表，每个任务在新的终端窗口运行
    $tasks = @{
        "PathTask" = @{ Command = "while (`$true) { Write-Host (Get-Location) -ForegroundColor Cyan; Start-Sleep -Seconds 3 }"; Path = "C:\" }
    }

    # 启动所有任务
    foreach ($task in $tasks.Keys) {
        Write-Host "⏳ 正在启动任务 [$task]..." -ForegroundColor Cyan
        $Global:TaskProcesses[$task] = NewTerminalRun -Name $task -Command $tasks[$task].Command -WorkingDirectory $tasks[$task].Path
        Start-Sleep -Seconds 1  # 延迟以避免高负载
    }

    # 监控任务进程状态，并在停止后自动重启
    while ($true) {
        foreach ($task in $Global:TaskProcesses.Keys) {
            $process = $Global:TaskProcesses[$task]
            if ($process -and ($process.HasExited -eq $false)) {
                $elapsed = (Get-Date) - $Global:TaskStartTime[$task]
                Write-Host "✅ 任务 [$task] 正在运行 (已运行: $($elapsed.ToString('hh\:mm\:ss')))，PID: $($process.Id)" -ForegroundColor Green
            } else {
                $elapsed = (Get-Date) - $Global:TaskStartTime[$task]
                Write-Host "❌ 任务 [$task] 已停止 (运行时长: $($elapsed.ToString('hh\:mm\:ss')))，正在重启..." -ForegroundColor Red
                $Global:TaskProcesses[$task] = NewTerminalRun -Name $task -Command $tasks[$task].Command -WorkingDirectory $tasks[$task].Path
            }
        }
        Write-Host "🔄 正在等待 5 秒后重新检查任务状态..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 5
    }
}

# 运行任务管理逻辑
RunTask