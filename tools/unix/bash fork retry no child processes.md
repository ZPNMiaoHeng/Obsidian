#linux  #bug 

- BUG：某天 vscode 突然远程连不上服务器![[1-bash fork retry no child processes.png]]
- 原因：频繁在服务器上退出 vscode 远程，会导致进程不会被 kill，会占用后台进程；![[2-bash fork retry no child processes.png]]
	- 之前在自己电脑上不会出现此问题：本地电脑每天都会重启，进程会被 kill；
- 解决方法：kill vscode 相关进程即可；
```bash
ulimit -u 10000 # 临时扩大线程数
ps ux   # 查看当前用户下的线程
ps -u $USER -o pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -20 # 查看可能的异常进程
pkill -f "/data153/miaoheng/.vscode-s"  # 使用 `pkill` 精确结束
```

# 优雅退出 vscode 远程
### 方法1：通过VS Code界面关闭（推荐）
1. **保存所有文件**：`Ctrl+S` 或 `Cmd+S`
2. **关闭远程窗口**：
    - 点击 VS Code 左上角菜单：`文件(File)` → `关闭远程连接(Close Remote Connection)`
    - 或点击左下角的 **绿色远程连接指示器** → 选择 `关闭远程连接`
3. **完全退出VS Code**：`文件(File)` → `退出(Exit)` 或 `Cmd/Ctrl+Q`

### 方法2：通过命令面板
1. 按 `F1` 或 `Ctrl+Shift+P`
2. 输入：`Remote-SSH: Close Remote Connection`
3. 按回车