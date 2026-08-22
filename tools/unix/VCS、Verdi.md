#tools #Synopsys
# VCS
## 编译选项
- `–sverilog` :支持`systemverilog` 语法;
- `+V2K`: 支持`verilog 2001` 特性;
- `-R` 编译完后立刻运行;
- `-fsdb` 调用`Verdi PLI` 库，支持`fsdb` 波形;


# Verdi
## 编译选项
- `-f`: 指定的设计文件;
- `-ssf`: 自动打开的fsdb文件;
- `-sswr`: 制定rc文件;
	- 在verdi中选中波形界面，使用`S`保存波形格式；
- `-nologo`: 关掉烦人的欢迎界面;
## 基本操作
- 波形窗口 file->reload：波形文件变化后重新加载；
- 主窗口 File-> reload design：设计代码变化后重新加载；
## 快捷键
- 鼠标左键为**黄色时刻**，鼠标滚轮是**粉色时刻**，点击波形中 View/Signal Event Report，就会先上升沿、下降沿次数。
	- ![[Pasted image 20241023200131.png]]
- f：波形全部显示；
- z/Z：缩小/放大波形；
- h：显示信号全路径/只显示信号名；
- t：使选中信号变色；
	- c：弹出颜色选择页面；
- C+w：在代码模块中加入某信号
- C+c、C+v：复制粘贴信号；
- delete：删除信号；
- x：代码页面显示黄色虚线位置，各个信号的值；
- rc文件加载
	- file->save signal保存；
	- file->restore signal批量添加；
- 为信号设置不同颜色
	- ![[Pasted image 20241016142315.png]]

## 骚操作
### 同时打开多个波形
![[Pasted image 20240813103536.png]]
### bus操作
![[Pasted image 20240813103626.png]]
### 逻辑信号组合
![[Pasted image 20240813103653.png]]
### 波形值搜索
- 选中信号，点击红圈内的下三角，选中Bus Value，输入搜索值，再点击“左，右” 三角进行搜索;
![[Pasted image 20240813103809.png]]
### 添加Maker线
- 填写maker 的名称，选择好maker线的位置，颜色，点击“create” 后即可添加Marker线;
- ![[Pasted image 20240813103904.png]]
## 信号追踪
具体参考《verdi使用》ppt；
- 波形双击追踪；
- ![[Pasted image 20240813104035.png]]
- ![[Pasted image 20240813104356.png]]