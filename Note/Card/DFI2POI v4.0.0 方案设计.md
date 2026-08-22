#card 

# dfi-axi
---
- dfi-axi 架构图![[Pasted Image 20250211101026_930.png]]
	- 初始化时，将 SoC Memory Controller 中的配置寄存器信息同步到 FPGA_DDRC；

---

- dfi-axi bridge 架构思维导图：[[dfi-axi mindmap]]

---

验证架构图：![[Pasted image 20250211183415.png]]

---

![[Pasted image 20250211182132.png]]
- 将 DFI 数据、地址和延迟信息打包成数据包格式，写入到异步 FIFO；
- 优点：
	- dfi-axi bridge 只关注 DFI 的读、写命令和数据通道，特殊命令被过滤；
	- ddrc 频点可以达到 10MHz 以下；
	- 状态机控制可以实现参数化；
- 缺点：
	- 需要验证人员搭建测试平台；
	- 需要使用部分 VIP:

---
# dfi2poi
---

- dfi2poi 同步方案改为使用异步FIFO、FSM 控制；
	- write FIFO、write FSM；
	- read FIFO、read FSM;

---

- FPGA_PHY 规格
	- 频点范围：160MHz~1333MHz；
	- 与 DDR 频率比为 1:4；
	- 支持 MR 配置、时序参数固定不可修改；
	- 内部集成 pll，可以根据外部输入时钟和配置参数，输出时钟；
![[Pasted image 20250212090814.png]]

---

- 时钟方案：
	- ddrc 25MHz，使用系统参考时钟；
	- fpga_phy 200Mhz，使用 FPGA 外部输入时钟；

---

- 风险点：
	- 1、特殊命令如何保证时序？比如两个 ref 之间时序间隔；
	- 2、umctl2处于低频时钟域，若出现连续 READ，读异步 FIFO 会被写爆；

---