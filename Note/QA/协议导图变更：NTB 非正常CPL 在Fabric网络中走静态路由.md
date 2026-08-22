#todo #NTB #QA 

	NTB 协议同事提出 NTB CPL报文如果UR/CA的话，在Fabric网络中走静态路由（HIE=1）。具体原因还没搞懂。当前阶段代码更改只能走 ECO 流程，不过看 NTB 代码只需要改动一行，并且是1bit的值变化。
	问了下孟哥，需要和 BES 同事讨论下 ECO 实现流程，可以跟进下，有点 ECO 的经验呢。

	哈哈哈哈，问了金山 Fabric 处理流程，感觉还是乱乱的，没理清楚。
	
- [x] Edge-swicth 绑定了 spid/dpid 在 Fabric 网络中怎么走的呀？
- [x] spid/dpid 在 Fabric 网络中会不会更新呢？
- [x] NTB CPL ECO 处理跟踪；
