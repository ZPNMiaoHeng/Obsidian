#IC #SoC #DDR #FPGA 
![[Pasted image 20241009144302.png]]
# Chapter 2
##### Idle Latency Categories ：空闲延迟
- **缺页损失**`Page Miss`：`DRAM bank` 打开的行地址与传入读事务和`tRAS`的行地址不匹配；
- **关闭页面**`Closed Page`：所有的`DRAM bank`已预充电并且`tRP`已过时；
- **页面命中**`Page Hit`：`DRAM bank` 打开的行地址与传入读事务行地址匹配，但`tRCD`已过时；

##### Port Description：端口描述
- 对于一个完整的MC设计方案，在内存接口核的顶层有三种端口类别，称为**用户设计**；
	- 与SDRAM直接相连的**内存接口信号**，使用JEDEC规范；
	- **应用接口信号**，[[pg150-ultrascale-memory-ip_ddr.pdf#page=23&annotation=462R|pg150-ultrascale-memory-ip_ddr, 页面 23]]；
	- **核不可缺少的信号**，包括`clocks、reset、核的状态信号`；
- 其余信号：
	- 高电平有效的 `init_calib_complete` 表示初始化和矫正已完成，他的接口已准备接受`Command`；
	- PHY接口：[[pg150-ultrascale-memory-ip_ddr.pdf#page=23&annotation=463R|pg150-ultrascale-memory-ip_ddr, 页面 23]]；
	- 直接与SDRAM相连的信号和时钟复位信号是与MC设计相同的。

# Chapter 3
![[Pasted image 20241009145805.png]]
## Memory Controller
![[Pasted image 20241009150308.png]]
- MC主要组成部分：
	1. **Groups FSMs**：负责事务队列排序、检查`DRAM`时序、决定什么时候请求`PRE`、`ACT`、`CAS DRAM`命令；
	2. **Safe Logic and Reorder Arbitration**：将`Groups FSMs`之间的事务重排序，需要额外的DRAM时序检查，并且也要确保所有DRAM命令请求前递进程；
	3. **Final Arb**：最终决定哪个命令传递给PHY，并将前一阶段结果反馈；
- 控制器命令路径的维护块包括：
	1. 生成`refresh`和`ZQCS`命令的模块；
	2. 需要`VT Tracking`命令；
	3. 为72-bit宽度的数据总线实现的一个`SECDED ECC`，可选；
### Native Interface
### Control and Datapaths
#### Control path
#### Datapath
### Read and Wirte Coalescing
### Reordering
### Group Machine

## ECC
可选，目前不关注；2024年10月9日15:45:26
### Address Parity
地址奇偶校验，目前不关注；2024年10月9日15:45:21

## PHY
使用Xilinx ip，不关注内部实现细节；