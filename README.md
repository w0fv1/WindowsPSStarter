# Starter 服务管理脚本

## 📌 项目简介
**Starter** 是一个用于 **Windows** 上的 **PowerShell 服务管理脚本**，可以自动注册并运行一个自定义的 Windows 服务，并且提供任务管理功能，支持任务自动重启，方便用于各种后台进程管理。

本项目的主要功能包括：
- **自动注册 PowerShell 作为 Windows 服务**
- **支持多个任务的启动和管理**
- **任务异常退出时自动重启**
- **日志和状态监控**
- **无需手动干预，即可后台运行**

## 🚀 快速开始

### 1️⃣ 克隆或下载本项目
```sh
 git clone https://github.com/your-username/starter-service.git
 cd starter-service
```

### 2️⃣ 运行 PowerShell 脚本
> **注意**：首次运行需要以管理员权限执行！
```powershell
Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File .\starter.ps1"
```

### 3️⃣ 启动服务
如果服务已经注册，可通过以下命令启动：
```powershell
Start-Service -Name Starter
```

如果需要停止服务：
```powershell
Stop-Service -Name Starter
```

如果想要移除服务：
```powershell
sc.exe delete Starter
```

## 🛠️ 详细功能

### 🌟 服务注册
- **自动检查是否已注册服务**，如果未注册，则以管理员权限创建服务。
- **以隐藏窗口方式运行**，不会弹出额外窗口。
- **服务描述**: “Starter: 一个用于快速启动和管理任务的 Windows 服务。”
- **开机自启**: 设定为 `Automatic` 启动类型。

### 🎯 任务管理
- **支持多个任务并行执行**。
- **每个任务在单独的 PowerShell 终端中运行**。
- **如果任务异常退出，将自动重新启动**。
- **任务运行时间监控**，每隔 5 秒检查一次任务状态。

### 📜 任务示例
默认情况下，服务会自动启动以下任务：
- `PathTask`: 每 3 秒输出当前路径。

可以根据需求修改 `starter.ps1` 脚本中的 `tasks` 变量，添加自定义任务。

## 🔧 高级用法

### 自定义任务
如果想要添加新的任务，可以在 `starter.ps1` 中修改如下部分：
```powershell
$tasks = @{
    "NewTask" = @{ Command = "while (`$true) { Write-Host '🔧 Custom Task' -ForegroundColor Magenta; Start-Sleep -Seconds 5 }"; Path = "C:\" }
}
```
然后重启 `Starter` 服务：
```powershell
Restart-Service -Name Starter
```

### 以普通脚本模式运行
如果不希望注册为 Windows 服务，可以直接运行脚本：
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\starter.ps1
```

## 📜 许可证
本项目遵循 **MIT License**，可以自由使用、修改和分发。

## 🙌 贡献
欢迎大家提出 **issues** 或 **pull requests**，一起完善这个项目！