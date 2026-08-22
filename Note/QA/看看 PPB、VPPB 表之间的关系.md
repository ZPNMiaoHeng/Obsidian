
- PPB_context 是一个全局表，保存了 sw 内 40 个端口基本信息（链路状态、是否触发 DPC、端口电源状态、链路模式）；
- PPB_context_local 对应 station 的 4 个Port 详细状态，在 PPB_context 上添加了更多端口信息；
	- UP、DP；
	- 是否为 IO_share 口；
	- 有没有绑定 VPPB；
		- ?如果绑定了，那如何查看对应 VPPB 信息呢？---使用 {VCS,vPPB} 查找 vPPB_CONTEXT 表
			- VCS 怎么来的呢？
			- vPPB 
	- 是否为 Fprot 口，并分配 PID信息；

