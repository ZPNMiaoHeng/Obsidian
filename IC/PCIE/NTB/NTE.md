
- NTE 寄存器会被很多 Host 共享访问，需要单独==串链==；
	- 当前 Doorbell 在 NTB 中实现，但 Scratch pad 在 NTE 内，这时地址如何划分呢？
	- BAR0 Scratchpad，BAR1 Doobell，BAR2-BAR5 NTB；
	- ~~BAR0：配置表；~~
		- ~~Host 写 NTE BAR0 地址空间寄存器，请求会被 Ingress 送到 SOC，SOC 解析 BAR0 寄存器，填写 NTB 的地址转换表、ID 转换表。~~
- 系统中最多实现 8 个 NTE，具体数量由 SoC 配置虚拟决定的；
- 系统中只有一个 Scratch pad，大概率使用寄存器搭建实现（目测不是很大，等待张老师对标）；
- NTE 地址空间命中判断：
	- NTE 地址空间是 SOC 虚拟分配的，多个地址空间不连续；
	- 地址高位表示命中某个 NTE，低位表示对应 Scratchpad 中的寄存器；
- 最终穿过多个模块到达 RM，RM 通过 csr 串联进行访问；
- mem.read 需要返回 CPL 报文，N2A 模块构建 CPL 报文，但需要知道 RID（请求带了）、CID（SOC 给）信息。
- 多 Host 访问：
	- 不同 Host 发出报文命中不同 NTE，但偏移量都是指向 Scratchpad 中的寄存器。
## 记录
###  NTE Mem.Write 过程

1. mem.write 报文若命中 NTE 的地址空间；
2. 当地址命中某个 NTE 的地址空间（地址高位判断）时，地址低位作为偏移量经过 SW 送到 vPPB=37 端口；
3. 经过 N2A 模块，将报文转换为 AXI 数据格式；
4. AXI 数据传输给 EI 模块，EI 通过 PIO 接口与 RM 模块通信；
5. RM 通过 csr 数据链访问 Scratchpad；

### Mem.Read
mem.read 需要返回 CPL 报文，在 mem.write 基础上多了以下步骤：
1. Scratch pad 通过串联返回 RM 读数据；
2. 读数据通过 PIO 返回 EI，EI 将数据返回 A2N；
3. A2N 需要根据读数据构建 CPL 报文；
	1. RID；CID；
	2. Q：SoC 怎么给呢？


# scratchpad Memory
- 便签式存储器；
- 与 Cache 不同的是，其内部 SRAM 数据需要软件控制（通过 DMA）；
	- 但受限于保存空间大小；
- 允许所有设备访问；




# Ref
- [What is Scratchpad Memory? - UMA Technology](https://umatechnology.org/what-is-scratchpad-memory/)---墙裂推荐
- [What is Scratchpad Memory? - Technipages](https://www.technipages.com/what-is-scratchpad-memory/)
- [Scratchpad Memory & Cache - 知乎](https://zhuanlan.zhihu.com/p/554096262)
