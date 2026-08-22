#DDR #Synopsys 
- 地址映射：逻辑地址到物理地址的映射；
	- 逻辑地址：一个数据端口上显示的事务的命令地址；
	- 物理地址：给 SDRAM 存储器的 rank、bg、ba、row、column 的地址集合；

#### 地址映射大概
- 系统地址映射开启（UMCTL2_A_NSAR > 0），并且地址映射可配置：
	1. 系统地址转换为 AXI 字节地址；
	2. AXI/AHB 字节地址转换为 HIF 字地址 ；
	3. HIF 字地址转换为 SDRAM 地址，映射器位于 DDRC；
![[Pasted image 20241125150228.png]]

#### System Address Regions
- 系统地址区域增加了定义**最多四个不相交**的内存区域作为连续地址映射到DRAM的能力。区域数量和最小块大小由硬件参数 UMCTL2_A_NSAR 和 UMCTL2_SARMINSIZE 决定。
- 内存区域定义：
	- 基本地址：按最小块大小对齐的区域的起始地址，SARBASEn.base_addr；
	- 块数：区域大小以最小块大小的倍数表示，SARSIZEn.nblocks；


| Addr | Reg                                | function                                   |
| ---- | ---------------------------------- | ------------------------------------------ |
|      | ADDRMAP1                           | bank 地址映射关系                                |
|      | ADDRMAP5<br>ADDRMAP6<br>ADDRMAP7   | 行地址位置映射关系，<br>5.addrmap_row_b2_10 决定最终映射关系 |
|      | ADDRMAP9<br>ADDRMAP10<br>ADDRMAP11 |                                            |

# Inline ECC Support
## ECC Address Mapper
- ![[Pasted image 20241125104641.png]]
	- 空间浪费原因：Data:ECC=8:1，但在==存储器中映射关系是7:1==；数据映射后会有 1 bit空间浪费。
	- ![[Pasted image 20241125104928.png]]


# QA
- [x] HIF;
- [x] XPI：；
###### HIF,Host Interface
[[DWC_ddr_umctl2_databook.pdf#page=105&offset=36,725|DWC_ddr_umctl2_databook, 2.4 Host Interface (HIF)]]
- 外部多端口时，umctl2 经过重排序发出一组数据对接端口。
###### uMCTL2 架构
[[DWC_ddr_umctl2_databook.pdf#page=69&offset=36,221|DWC_ddr_umctl2_databook, 2.1.2 Block Descriptions]]
![[Pasted image 20241125165247.png|800]]
uMCTL2 控制器主要部件：
- AXI Port Interface，该模块提供到应用程序端口的接口。
	- 提供总线协议处理、读数据的缓冲和重排序、数据总线大小转换、内存突发地址对齐。
	- 读取数据保存在一个 SRAM （读重排序缓冲），并按照顺序返回到 AXI 端口。SRAM 可以实例化为uMCTL2外部嵌入式存储器，也可以在内部用寄存器实现。
- Port Arbiter（PA），端口仲裁块：
	- 在 XPI 端口发出的地址之间提供延迟敏感、基于优先级的仲裁。
- DDR Controller，DDR 控制器
	- 包含一个可以使用标准单元构成的逻辑 CAM，它保存命令相关的信息，调度算法可以使用这些信息，来基于优先级、bank/rank状态和DDR 时序约束，对要发送到 PHY 的命令进行最佳调度。
	- 提供一个可选的数据旁路。
- APB Register，APB配置寄存器块
	- 这个模块内包含了软件可访问寄存器，可以通过 APB 总线配置这些寄存器。
## ECC
- [ ] Inline ECC mode:当前使用的ECC就是这个模式，每 8byte 数据带 1byte ECC 。
- [ ] Sideband ECC mode
- [ ] No ECC mode:
-  [[#ECC Address Mapper]]：
	- [?] 开启ECC后为何Data:ECC变成了7:1？
	- 是不是因为不开启 ECC 或者开启 Sideband 时，data 正好对应，无需改变；开启 Inline ECC，Mem 不会改变但 ECC 需要保存在数据中。
	- [?] 映射关系？ECC是不是重新计算呢？
# Ref
- 地址概念介绍：[[DWC_ddr_umctl2_databook.pdf#page=152&offset=36,725|DWC_ddr_umctl2_databook, 2.11 Address Mapper]]
- ECC 相关：；