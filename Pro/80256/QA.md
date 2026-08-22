---
status: Doing
start: 🌟🌟🌟🌟🌟
tags:
  - todo
---
# 未解决

- [x] NTB 配置寄存器需要确定！--周文刚，会上或会后。
	- [x] 自身的 bus 号保存的位置；
- [?] 确定 non-post 报文的 req、cpl Farbric 路由路径是否保持一致；
	- [!] 硬件可以实现：需要将地址转换表中 PID 信息映射到 ID 表中 PID 保存；
		- ID 表中 PID 扩充为8组；
			- 一条流水线中最多支持 8 个 VCS，最多有 8 个 NTB；
		- 将每组 NTB 地址转换表中唯一一组 PID 信息映射到 ID 表中；
			- VCS0-->ID PID0;
			- VCS1-->ID PID1；
- [?] 跨 Swicth 访问 Scratchpad 是否支持；
	- [!] 硬件可以实现：用户在本 Swicth vcs 内的地址转换表添加对应 Swicth 地址转换信息；
	- 就可以实现先将报文在本 sw 内地址转换，通过 Fabric 路由到目的 sw vcs；
	- 转换后的报文命中 NTE 的地址空间，就可以访问 Scratchpad 了；
- [?] NP 报文中 req 正常路由，在 cpl 返回之前，ID 表内容被修改，cpl 无法正确路由；


---

# 解决
- [x] MSI 在之前的项目中怎么使用的？
- 确认：Doorbell 支持的报文类型，
	- [x] DMWr、MWr、MRd、MRdLk;--苗恒：Mwr
	- [x] MRd 类型的报文会出发 Doorbell 功能嘛？
	- [x] 32、64 会转换嘛？--苗恒：不会改变。

- [x] Flit 模式下，Doorbell 中 mem.wirte 变的 MSI/MSIX mwr？--苗恒，会前。
- [x] msg 地址路由经过 NTB，为什么不处理呢？-规格
- [x] NTB 是否支持 IO 报文呢？软件会不会发出跨 VCS 的IO 报文呢？-规格
- [x] SOC 发出的报文会不会 bypass Ingress 流水线？如果 bypass 流水线，是否可以配置不 bypass？-- CIU确定
- [x] 是否支持 SOC 报文访问 NTB 呢？
	- [x] SOC 报文类型的？什么场景下会发出这种报文？---支持，SOC可以构建任意报文，但效率很低，只能验证模块功能，不能验证性能。
- [x] NTE 中 BAR 寄存器是否硬件实现？--xp：NTE 访问不频率不是很高，改为 SOC 实现，现在报文走 SOC 路径
- [x] ID 表模块有八组信号，需要评估 fanout；--孟伟，会上
	- 不会出现这种情况；
	- [[ID mapping table#会不会出现 8 个 NTB 同时访问 ID 表的场景？]]