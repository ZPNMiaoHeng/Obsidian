---
status: Doing
start: 🌟🌟🌟🌟🌟
time: 2025-04-12
tags:
  - todo
---
# TODO
- [x] SRAM 规格；
- [x] MSI 报文格式确定； 
- [x] PD 确定 MSI_Data 存放位置与指示字段；
- [x] segment 检查；


- [x] 新PD；
	- [x] PID_valid 删除，查找替代字段；
	- [x] Last_DW_BE/First_DW_BE 字段删除，查找 MSI 报文自带字段；
	- [x] Doorbell 查表 msi_Data 需要确定复用字段；

## 概设
### NT 组播变动--2025年5月12日
- [x] CSR 节点；
- [x] 面积、功耗、延迟评估；
- [x] DS

#### PRE_MC
-  [x] 入口 VCS NTB 功能使能检查；
	- [x] 协议导图对齐；
- 详设
	- [x] 草稿；
	- [x] cg；

#### NTB
- [x] NT 组播
	- [x] 查看协议思维导图；
	- [x] DS：加查 ID 表功能；
	- [x] 修改 PD；
	- [x] 修改图；
	- [x] 对齐其余同事；
	- [x] 下游讲解；
- [x] 场景1：NTB Fabric 路由，DPID 是一个 EP 设备，在 ed-sw Fport 处继续走 PBR 路由，在 Egress mc_overlay 模块才走 HBR 路由，导致在对端中报文 VCS 未修改，无法查找 NTB_bus？
	- [x] 怎么处理呢？


---

### 规格变动---4月
- [x] ID 表添加 segment_valid、segment 匹配字段；
	- [x] ==NTB 携带 Segment 匹配场景：区分报文带不带 Segment、有无 capture？?需要拉会讨论；==
	- [x] 场景1：报文未带 segment，但 ID表 Segment 有效。--- 报文在某个入口会检测，发现没带 Segment，就给补上；
	- [x] 场景2：报文携带 Segment，但 ID 表中 Segment 无效。
- [x] ID 表、地址转换表、Doorbell MSI/MSIX 表、组播中 dst_ntb_bus，使用一个单独 ntb_bus 表实现；
	- [!] 报文经过 NTB 转换后路由到目的 sw/vcs 下，然后发现 FNTB=1，NTB 只会使用 vcs 查找 ntb_bus 表得到 dst_ntb_bus；
		- 注意：FNTB 字段功能改变，改为只进行 ntb_bus 表查找；
		- [?] 之前的问题是：Doorbell MSI/MSIX 表中没有 dst_ntb_bus，转换后的 MSI/MSIX 报文没有进行 BDF 的转换？？？？--不确定，需要讨论。
	- [!] 每个 NTB 内都有一个 ntb_bus 表，表内容保存 vcs 对应 ntb_bus；
		- [!] 使用状态寄存器进行配置此表，；
	- [x] ==会不会带来其他问题，还需要讨论；==
- [x] ID 表为静态配置，未命中送给 SoC处理，SOC 按照报文处理，返回 UR/CA；
- [x] NTB 每条流水线单独配置，同一个 sw 下，支持部分流水线开启 NTB ，部分流水线 bypass NTB；
	- [x] 实现状态寄存器配置 NTB 的使能；
- [x] ==failover 如何做呢？用户可以根据规格自己开发实现，但我们需要确定一条测试方案；---软件实现。==
- [x] 组播添加 clear no snoop 的功能；
	- [x] 需要加入相关状态寄存器；


#### 验证串讲
![[2-Todolist.png]]
1. ![[1-Todolist.png]]


#### QA
- [x] NTB bus 号怎么使用的？？？？
- [x] segment 中的 capture 指的是什么呢？
- [x] 经过 NTB 转换后的 MSI/MSIX 报文走地址路由？
	- [x] MSI/MSIX 报文最终送到哪里呢？是对端的 NTB 嘛？
- [x] Scratchpad 软件实现，需要拉会对其颗粒度！