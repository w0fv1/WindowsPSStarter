
# 任务运行时间存储
$Global:TaskStartTime = @{}
$Global:TaskProcesses = @{}

# 在新终端窗口中运行命令的函数
function StartTaskInNewTerminal {
    param (
        [string]$Name,
        [string]$Command,
        [string]$WorkingDirectory,
        [hashtable]$EnvironmentVariables
    )

    # 记录任务启动时间
    $Global:TaskStartTime[$Name] = Get-Date

    # 构建环境变量参数（已修复转义问题）
    $envCommands = $EnvironmentVariables.Keys | ForEach-Object { "`$env:$($_)='$($EnvironmentVariables[$_])';" } | Out-String

    # 启动任务进程
    $FullCommand = "$envCommands $Command"
    $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-Command", $FullCommand -WorkingDirectory $WorkingDirectory -PassThru

    Write-Host "🚀 任务 [$Name] 已启动，PID: $($process.Id), 运行目录: $WorkingDirectory" -ForegroundColor Green
    return $process
}

# 运行任务
function RunTask {
    Write-Host "✨ Starter 服务正在运行..." -ForegroundColor Blue

    # 定义任务列表，每个任务在新的终端窗口运行
    $tasks = @{
        "PathTask"  = @{ 
            Command = "while (`$true) { Write-Host (Get-Location) -ForegroundColor Cyan; Start-Sleep -Seconds 3 }";
            Path = "C:\";
            Env = @{}
        }
    }

    # 启动所有任务
    foreach ($task in $tasks.Keys) {
        Write-Host "⏳ 正在启动任务 [$task]..." -ForegroundColor Cyan
        $taskInfo = $tasks[$task]
        $Global:TaskProcesses[$task] = StartTaskInNewTerminal -Name $task -Command $taskInfo.Command -WorkingDirectory $taskInfo.Path -EnvironmentVariables $taskInfo.Env
        Start-Sleep -Seconds 1  # 延迟以避免高负载
    }

    # 监控任务进程状态，并在停止后自动重启
    while ($true) {
        foreach ($task in $Global:TaskProcesses.Keys) {
            $process = $Global:TaskProcesses[$task]
            if ($process -and ($process.HasExited -eq $false)) {
                $elapsed = (Get-Date) - $Global:TaskStartTime[$task]
                Write-Host "✅ 任务 [$task] 正在运行 (已运行: $($elapsed.ToString('hh\:mm\:ss')))，PID: $($process.Id)" -ForegroundColor Green
            }
            else {
                $elapsed = (Get-Date) - $Global:TaskStartTime[$task]
                Write-Host "❌ 任务 [$task] 已停止 (运行时长: $($elapsed.ToString('hh\:mm\:ss')))，正在重启..." -ForegroundColor Red
                $taskInfo = $tasks[$task]
                $Global:TaskProcesses[$task] = StartTaskInNewTerminal -Name $task -Command $taskInfo.Command -WorkingDirectory $taskInfo.Path -EnvironmentVariables $taskInfo.Env
            }
        }
        Write-Host "🔄 正在等待 5 秒后重新检查任务状态..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 5
    }
}

# 运行任务管理逻辑
RunTask
