#NTB #todo 

![[1-NT 组播 EMU工程调试.png]]
- 今天把 NT组播报文 sw2sw 调通了，edge-sw 可以收到 NT组播报文。
- 问题：NT组播配置打流后，sw 之间链路断开；
- 原因：PCIE-route 模块触发了 rx_adrt_src_dp_bus_master_disable_drop 中断，然后汇聚到 slice，slice会给 station 传一个信号，导致触发 DPC。
	- 中断原因：DUT2 sw 未配置 vppb_local 表中 bus_master_en；![[2-NT 组播 EMU工程调试.png]]
	- ![[3-NT 组播 EMU工程调试.png]]