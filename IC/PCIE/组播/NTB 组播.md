#PCIe #NTB 
# 文档学习

## 项目文档

- NT endpoint 也有 multicast capability 配置空间。
	- 如果 NT endpoint 通过配置 MC_Receive 加入了某些组播组 MCG；
	- 当 Host 发出一个组播报文，命中了 NT endpoint 的 MC_Receive 组播组；
	- 要向 NT endpoint 组播（并不是把报文发送给 NT endpoint，而是通过 NT endpoint 向其他 Host 所在的 VCS 组播）
	- ![[SW NTB 组播示意图.png]]

## 组播类型

1. 向本 VCS 内的端口进行组播复制（普通 PCIe 组播）；
2. 向本 SW 内的其他 VCS 的端口进行组播复制（跨 VCS 复制，不需要出 SW 进入 Fabric 网络）；
3. 向其他 SW 的 NT endpoint 进行组播复制（出 SW 进入 Fabric 网络）；
4. 其他 NT endpoint 向它所在的 VCS 端口进行组播复制（普通 PCIe 组播）；

![[组播类型示意图-NTB 组播.png]]

## NT 组播实现步骤

1. 配置 NT endpoint multicast capbility，使能 NT endpoint 组播；
2. NTB 收到 Host 的组播报文，检测组播报文的地址，==如果命中 NT endpoint 组播地址说明要进行 NT 组播，计算组播组 MCG 号==；
3. NTB 内有一个 NT_MCG 表，包含 64 个 64bit 的 NT_Receive[63:0] 寄存器；
	1. 每个 **NT_Receive** 寄存器的值，表示**这个 NT endpoint 加入了哪些组播组**；
	2. 64 个寄存器对应 64 个 NT endpoint，NT_Receive 的每一位表示加入了这个组播组，需要向这个 ==MCG== 组播；
	3. NT_Receive 寄存器的内容在所有的 SW Ingres 流水线中都相同，由软件事先填好；
4. NTB 根据组播组 MCG 号判断 NT_Receive[MCG]是否为 1，为 1 说明要向这个 NT endpoint 组播；
	1. 64 个 NT_Receive 同时判断，最后得到 64 位的 NT_bitmap[63:0]；
	2. 每 1 bit 表示是否要组播到对应的 NT endpoint；
5. NTB 中有 8 个 VCS-> NT endpoint 编号寄存器，表示 VCS 号与 NT endpoint 编号之间的对应关系；
	1. 由软件事先填好，用 VCS 号索引得到 NT_num（ 6 bit 的 NT endpoint 编号）；
	2. 如果 NT_bitmap[NT_num]=1，则要在本 SW 内组播到该 VCS，记录到 NT_VCS_bitmap[7:0]；
		1. 这样得到 8bit 的 NT_VCS_bitmap[7:0]，然后清除对应的 NT_bitmap[NT_num]=0;
		2. 表示这些 NT endpoint 在本 SW 内组播，不需要通过 FPort 向其他 SW 的 NT endpoint 组播；
	3. 将 NT_VCS_bitmap[7:0] 和 NT_bitmap[63:0] 添加 PD，并设置 NT 组播标志 NT_MC=1.
6. NTB 将 PD 送到 PCIe 组播模块，
	1. PCIe 组播模块看到 NT_MC=1，则==根据 NT_VCS_bitmap[7:0] 对组播表输出的 256bit 进行过滤==%%怎么过滤呢%%；
	2. 只选择 NT_VCS_bitmap 为 1 的 VCS 进行组播，这样得到 SW 内跨 VCS 的组播 MC_bitmap[255:0];
	3. 每一位对应一个组播 vPPB 出口，将 MC_bitmap[255:0] 添加到 PD，最终写入 DAMQ，NT_MC=0 则为普通组播；
7. Slice 从 DAMQ 读出组播报文，根据 MC_bitmap[255:0] 复制报文到 vPPB 出口，并在 Egress 流水线进行 ==Overlay 地址转换==，完成本 SW 内的 VCS 间组播；
8. Slice 根据 NT_bitmap[63:0] 每一位以此查 DPID 表，得到 DPID/Dst_NT_Bus/NT_overlay/PPB，对报文进行 ==NT 组播复制==，然后做 ==NT Overlay 地址转换==和 ==NT Request ID 转换==（组播复制的 SPID 仍然由 ID 转换表得到，已知由 NTB 填到 PD 中），组播复制后的 NT 组播报文根据 PPB 送给 SW 模块交换到 Dice，最终经过 FPort 端口送出去（要设置 FNTB 标记，用来判断组播报文是否要组播给其他 NT endpoint，防止报文在 NT endpoint 间来回组播）；
9. 其他 Switch 的 FPort 收到 NT 组播报文后，NTB 检查组播报文 Requester ID 的 NT_Bus 等于自己的 VCS NT endpoint Bus 号并且 FNTB=1，
	1. 说明是其它 NT endpoint 发过来的组播报文，只需要在本 VCS 内组播，
	2. 设置 NT_MC=0 交给 PCIe 组播模块在本 VCS 内进行组播；

### 表
- NT_MC 表![[NT_MC 表.png]]
- NT_MCG 表![[NT_MCG表.png]]
- ![[NT_Bitmap-2-DPID表.png]]





