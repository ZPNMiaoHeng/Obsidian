#DDR #FPGA 
# 规格 
## DDR4 
 ![[Pasted image 20241107113452.png]]
1. **DDR4-1600 颗粒**选取最大延迟 **12-12-12**，[[EDEC spec JESD79-4B.pdf#page=206|Table 114 — Timings used for IDD, IPP and IDDQ Measurement-Loop Pattern]]；
2. POI 频率比是**1:4**，DFI频率比是**1:2**；
3. 单 phase，或者说是对齐的；
4. **AXI** 接口处**4字节对齐**；
### 时序参数介绍
![[Pasted image 20241107103859.png]]
[深入理解DDR：DDR的时序参数 (qq.com)](https://mp.weixin.qq.com/s/fCQ4SnnkRcJ7K2KmzYMPgg)
## DFI
### 数据传输
1. AIX 事务的**地址对齐**；
2. DFI 协议中 phase0 和 phase1 是**对齐传输**；
	1. ⚠️此波形传输是未对齐。![[Pasted image 20241108141415.png]]
3. 包含 **ECC 校验码**：一次传输数据为 512 bit 数据和 64 bit 校验码；
	1. ECC 校验码由 DDRC IP 产生：AXI 传输 512 bit 数据，DFI 上就是 576 bit 数据；
	2. 数据格式：每 64 bits 数据会紧跟对应 8 bits ECC 校验码。
	3. 因此在波形上观察是 dfi_wrdata_en 是按照 9 bit 为一个块传输。 ![[Pasted image 20241108141129.png]]
### 时序参数
![[Pasted image 20241107154840.png]]
- tphy_wrcslat：DFI 写命令有效到 cs 有效的时间间隔；
- tphy_wrlat：DFI 写命令有效到 en 使能信号；
- tphy_wrcsgap：此参数指定在更改 dfi_wrdata_cs_n 信号驱动的目标片选时，命令之间所需的额外 DFI PHY 时钟（或 DFI PHY 时钟）周期的最小数量；
- tphy_wrdata：dfi_wrdata_en 信号到 dfi_wrdata 信号之间的 PHY 时间间隔；
## TODO
### DFI2POI
- [x] 数据通路；
### 时序参数
- 频率比不同需要对POI命令进行延迟处理（为了在DRAM颗粒上延迟单元一致）；
	- [x] 端口加入时序参数 parameter，延迟单元在内部计算，模块内部使用 generate 进行延迟处理（为了实现参数化配置）；
	- **举例**：颗粒上 tRCD=12，在 DFI 协议上 tRCD=6，FPGA 上 tRCD=3，因此需要对 POI 命令进行在 PHY 时钟域下打 3 拍延迟；![[Pasted image 20241107114717.png]]

## 2564
- soc存放路径：![[Pasted image 20241116163939.png]]