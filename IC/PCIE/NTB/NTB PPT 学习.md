#PCIe #NTB 

# PCIe NTB
## 两个 Host 之间的报文传输

两个 Host 之间传输过程

![[1-NTB PPT 学习.png]]
- 两个 Host 之间通信的前提是，中间有个 Switch 包含两个 NTB 的信息。==比如 Switch0 或者 Switch1 都只有自己信息，不会进行跨 vcs 通信==。


##### 传输过程
1. Host0 发出一个 Req，通过 ID 路由，包含 RID 信息：VCS0、H0Bus、Dev、Func、H0addr；（Req 目的地址不是 Switch0，因此不会在 Switch0 中吸收掉，继而向下路由）
2. Req 路由传递给 switch2（内部包含 NT0、NT1 信息的交换机）时，Req 会在 NTB 首先进行 BAR 地址检查（判断路由地址是交换机下面的 EP，还是路由到 NTB？），
3. 当 Req 路由给 NTB 时，需要根据 Req 携带的报文信息去查表（TCAM 表，可以根据输入数据匹配最合适的结果），得到在 NT1 中路由信息：
	1. VCS0/H0Bus/Dev/Func 去查 ID 转换表（TCAM），得到 H0index；
		1. 原因：Req 携带的 Host0 信息其实在 Host1 交换机路由过程中不会使用，但返回的 cpl 报文需要 Host0 信息指明返回目的位置；
		2. ![[NTB ID、VCS 转换表.png]] 不同 Switch 之间的 BDF 可能相同，使用 Switch ID 进行标识。
	2. VCS0/H0addr 查地址转换表，得到 VCS1/H1addr/NT1Bus；
		2. 地址转换表是 TCAM+RAM，通过 Src 基地址和掩码在 TCAM 中得到 index，然后将 index 送到 RAM 中进行索引，得到目的地址。
			1. ![[NTB Mem、VCS mapping表.png]]
			2. ![[TCAM+SRAM.png]]
			3. 计算公式：![[NTB 地址映射表公式.png]]
		3. 在 Switch1 中路由方式中只会使用到 Bus 号，因此可以将 Req 报文编码格式转变，Switch0 中的信息通过 index 保存（后续 cpl 报文通过 index 恢复源地址）；
	3. RID 携带的信息就变为 VCS1/NT1Bus/H0index/H1addr；
4. 更改信息后的 Req 发送给 Host1；
5. Host 1 返回一个 CPL 报文，其中包含 RID：VCS1、NT1Bus、H0index；CID：VCS1、H1Bus、Dev、Func；
6. CPL 报文路由到 Switch2，在 NT1 table 中进行 BAR 译码，判断是否命中 NTB；
7. VCS1、NT1Bus 等于 NTB 自身的 Bus 号（命中 NTB）：使用 H0index 查 ID 转换表，得到 VCS0、H0Bus、Dev、Func 和 NT0Bus；
	1. CPL 报文当前信息是 Host1 的信息，需要转换为 Host0 的信息；
	2. 前面通过查 ID 表得到 Host0 报文信息，直接使用查表得到 Src NTB Bus 号替换即可。
8. CPL 报文路由到 Switch0；
9. CPL 报文继续路由到 Host0；


- **NTB Mem/VCS mapping 表**是用户准备好，静态配置；
	- 记录报文目的的信息，由 Host 制定，不同 Host 是不相同的。
	- 每个 Host 决定的，可能会不一样。
	- 只有命中这个表，才会正真的转换。

- **ID 表**是自动填。
	- 记录**源报文的信息**，CPL 报文回来时需要使用。
	- 全局表。
	- **Fabric Manager** 进行配置，多交换架构中，ID 表内容也是统一的。

- 第一次查表未命中，报文转发给 SoC，SoC 直到转发的目的地址，转发出去并填表，后续的报文进行查表操作。
	- NTB Mem/VCS mapping 表是静态配置，报文查表会得到一个目的地址。当报文查 ID 表未命中时，SoC 可以根据 Mem表得到目的地址转发出去。

- Doorbell 表：匹配的信息。
## Doorbell

- 特殊 PD：发给 NTB 的一报文，在 NTB Bar0；
	- 地址是写给 Doorbell，我们将它转换为 MSI 地址。 

## Scatch Pad
- 共享 memory 空间；
- 所有 Host 都可以访问，NTE 实现。

# PCIe Fabric NTB
## 两个 Host 通信
![[Synthetic Mode View.png]]
1. Host0 发出 Req 报文；
2. Req 报文路由；
3. Req 报文在 NTB 中判断是否命中，命中后查 ID/地址转换表，设置 ==SPID、DPID、FNTB 信息==，更新 Req 报文信息；
	1. SPID=PID0，DPID=PID1，FNTB=1，以及 DPID_Valid（指示 Fabric 路由是否有效）；
4. 通过 DPID 路由找到 FPort 出口转发；
5. 去掉 SPID/DPID，虽然 RID 的 VCS1、NT1BUS 等于自己的 BUS 号，但是 FNTB=1 不处理 FPort 收到的 NTB 报文；
6.  Req 报文继续路由到 Host1；
7. Host1 发出 CPL 报文；
8. CPL 报文向下路由；
9. RID 的 VCS1、NT1BUS 等于自己的 BUS（NTB 命中）；
	1. 用 H0index 查 ID 转换表：
		1. RID：得到 VCS0/H0Bus/Dev/Func ；
		2. CID：
			1. 使用 RID Index 索引，NT0Bus，当前 ID 表保存的 SPID 实际上是 CPL 的 DPID（PID0）；
			2. **RID** 信息 TCAM 方式，CPL 的 SPID 通过 查找 ID 表得到 SPID；
	2. 用 VCS1/H1Bus/Dev/Func 查 ID 转换表得到 SPID=PID1；
	3. 修改 CPL 报文信息，准备进入 Fabric 路由；
10. 通过 DPID 路由找到 FPort 出口转发；
11. 去掉 SPID/DPID 进行 HBR 路由，虽然 RID 的 VCS1/NT1BUS 等于自己的 BUS 号，但是 FNTB=1 不处理 FPort 收到的 NTB 报文。
12. 继续路由，直到 Host0；






# QA






