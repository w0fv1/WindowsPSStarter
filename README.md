# **Starter 任务管理脚本**

## **📌 项目简介**
**Starter** 是一个用于 **Windows** 的 **轻量级任务管理脚本**，可以自动运行和管理 **后台 PowerShell 任务**，并在进程意外退出时自动重启。  

本项目适用于：
- **运行定时任务**
- **管理后台进程**
- **监控和重启关键任务**
- **提供 Windows 开机自启的任务支持**

### **🚀 主要功能**
✅ **自动注册 Windows 计划任务**，在开机后自动运行  
✅ **支持多任务管理**，可以并行运行多个 PowerShell 任务  
✅ **任务异常退出时自动重启**，确保长期运行  
✅ **后台静默运行**，不会弹出干扰用户的窗口  
✅ **简单轻量**，无需额外安装复杂的软件  

---

## **🛠️ 安装与使用**

### **1️⃣ 下载或克隆本项目**
```sh
git clone https://github.com/your-username/starter-service.git
cd starter-service
```
或者直接[下载 ZIP](https://github.com/your-username/starter-service/archive/refs/heads/main.zip)，然后解压到任意目录。

---

### **2️⃣ 配置任务**
所有任务配置均在 `starter.ps1` 中。打开 `starter.ps1`，按照以下格式 **添加你的任务**：
```powershell
$tasks = @(
    @{ Name = "任务1"; Command = "while ($true) { Write-Host '运行任务1'; Start-Sleep -Seconds 5 }" }
    @{ Name = "任务2"; Command = "Write-Host '执行一次性任务2'" }
)
```
**示例解释：**
- **任务 1** 会持续运行，每 5 秒输出 `"运行任务1"`。
- **任务 2** 只是执行一次 `"执行一次性任务2"`，然后退出。

**⚠️ 重要**：所有任务都必须用 `@{}` 结构定义，`Command` 中写 **PowerShell 代码**。

---

### **3️⃣ 注册并运行任务**
**⚠️ 重要**：**必须以管理员身份运行！**

#### **方法 1：运行 `register.bat`**
- **右键 `register.bat`** → 选择 **"以管理员身份运行"**。
- 这将注册一个 Windows 计划任务，使 `starter.ps1` 在每次开机后自动运行。

#### **方法 2：手动运行命令**
```powershell
Start-Process cmd.exe -Verb RunAs -ArgumentList "/c register.bat"
```
如果你只是想手动测试 `starter.ps1`，可以直接运行：
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\starter.ps1
```

---

### **4️⃣ 确保任务正常运行**
检查任务是否已注册：
```sh
schtasks /Query /TN "StarterTask"
```
如果输出如下，则说明任务已注册成功：
```
任务名称: StarterTask
下次运行时间: 2025/03/19 10:00:00
任务状态: 准备就绪
```

**检查 Starter 是否在后台运行**
```powershell
Get-Process -Name powershell
```
如果 `starter.ps1` 在运行，会看到多个 `powershell.exe` 进程。

---

## **🔄 任务管理**

### **✅ 如何修改任务？**
1. 打开 `starter.ps1`，找到 `$tasks` 变量。
2. 添加、删除或修改任务内容，例如：
   ```powershell
   $tasks = @(
       @{ Name = "NewTask"; Command = "while ($true) { Write-Host '新任务'; Start-Sleep -Seconds 10 }" }
   )
   ```
3. 重新启动 Starter：
   ```powershell
   Restart-Service -Name Starter
   ```

---

### **🛑 如何停止或删除 Starter？**
如果不再需要 `Starter`，可以删除计划任务：
```sh
schtasks /Delete /TN "StarterTask" /F
```
这样 `starter.ps1` 将不会在系统启动时运行。

---

### **🔄 任务崩溃后自动重启**
`run.ps1.bat` 采用了 **进程检测机制**，确保任务意外退出后自动重启：
```batch
:check
timeout /t 5 >nul
tasklist | findstr /i "powershell.exe" >nul
if %errorlevel% neq 0 (
    echo PowerShell process not found, restarting...
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%PowershellFilePath%" -WindowStyle Hidden
)
goto check
```
你无需任何额外操作，**Starter 会自动确保任务持续运行**。

---

## **📜 常见问题 (FAQ)**

### **❓ `starter.ps1` 没有运行怎么办？**
1. **检查任务是否正确注册**
   ```sh
   schtasks /Query /TN "StarterTask"
   ```
   如果任务不存在，运行 `register.bat` 重新注册。

2. **手动运行 Starter**
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\starter.ps1
   ```

---

### **❓ `starter.ps1` 运行后自动关闭**
- **可能是任务脚本结束了**，如果任务是一次性的（非循环运行），Starter 可能会退出。确保 `Command` 内部有 `while ($true)` 这样的循环逻辑：
  ```powershell
  @{ Name = "Task1"; Command = "while ($true) { Write-Host '保持运行'; Start-Sleep -Seconds 5 }" }
  ```

- **检查任务计划日志**
  ```sh
  wevtutil qe Microsoft-Windows-TaskScheduler/Operational /f:text /c:10
  ```

---

## **📜 许可证**
本项目遵循 **MIT License**，可以自由使用、修改和分发。

---

## **🙌 贡献**
欢迎大家提出 **issues** 或 **pull requests**，一起完善这个项目！🚀

---
#### **📧 联系方式**
如果有问题，欢迎在 GitHub 上提交 Issue 或联系作者。