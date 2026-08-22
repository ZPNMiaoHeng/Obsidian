---
status: ""
tags:
  - todo
  - spec
---
##### P/NP/CPL 报文的发送不能依赖 P/NP/CPL 报文的接收
- 错误场景：Swicth4 中报文源进源出![[1-PCIE SPCE.png]]
	- 同一报文的转发也会在入口和出口之间产生了依赖关系；
- 解决方法：拓扑、配置上应该避免这种情况；
	- Host0 和 Host1 通信，应该直接从 Swicth3 的 Fabric 口出去，去 EP4 才会走 Swicth4 的 FPort；
	- Host1 和 EP4 有不同的 DPID，配置路由时候就不应该出现这种走回头路的情况；
- 项目规格：不支持集中式网关形式的 NTB，只支持分布式；
	- 要访问哪个区域的设备，就要在那块儿去配一个 NTB；
