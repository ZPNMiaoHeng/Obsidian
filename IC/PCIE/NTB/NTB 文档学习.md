#PCIe #NTB 

# DS
## 6.7.7

NTB 两种转发方式：数据转发和敲 Doorbell 转发；

- 写对应的 BAR 地址空间，然后会通过 37 号口路由出去。
	- BAR2-BAR5：；
	- BAR1：经过 Switch-> EI->NTE；
	- BAR0：；

- Host 填写 NTB 的地址转换表和 ID 转换表：
	- Host 填写 NT endpoint 的 BAR0 地址空间寄存器；
	- 请求会被 ingress 送给 SoC，SoC 解析 BAR0 的寄存器，并填写 NTB 中地址、ID 表
	- 表填写完成后，若报文命中地址转换表就会自动进行地址和 ID 转换。
- 对于 ==Doorbell==%%当前在 NTB 中实现%% 和 Scratch pad，Host 操作 BAR1 中的寄存器
	- BAR1 请求会经过 N2A->EI->RM 直接送到 NTE 模块；
	- ==NTE 模块响应 Doorbell 请求产生 MSI/MSIX 中断==。

---

# 概要设计方案
## Non-transparent Bridge（NTB）

NTB 端口可以连接两个 host 域，用于冗余备份和 ==failover 失效转移==，正常情况下主 Host 连接到 PCIe switch 的 UP 端口，管理 PCIe Switch 下的所有设备，主 Host 看到的 NT 端口是一个==特殊的 NTB PCIe 设备==，==从 Host 看到 NT 端口也是一个特殊的 NTB PCIe 设备==%%是不是可以理解成从 Host 下面直接连接一个 PCIe 设备，设备之下有个交换机呢？%%。
主 Host 和从 Host 可以通过 NTB 设备进行通信。
NTB 支持的功能如下：
- 地址转换：将地址从一个 Host 域转换到另一个 Host 域；
- Doorbell：Host 之间相互通知对方产生中断等；
- Scratchpad：主从 Host 都可以访问的一块寄存器区域，用于 Host 之间的通信；

![[NTB Switch 大致框图.png]]

### 1+1 passive failover

![[1+1 passive failover NTB.png]]
 
1+1 passive failover 模式下，主 Host 处于正常工作 active 状态，从 Host 处于被动 passive 状态。从 Host 可以通过 ==NTB 端口的心跳协议==等，==检测到主 Host 出现故障，从 Host 配置 NTB 端口产生 fail over 失效转移，NTB 端口转移到主 Host 对应的 switch 端口==%%这个内部怎么实现的呢？更改某些号嘛？？%%，从 Host 成为 PCIe switch 的 UP 端口，重新枚举 PCIe Switch 下的设备，主 Host 被 NT 端口隔离，进行故障恢复。
 
---

### 1+1 active failover（可以通过 Fabric 实现，不支持）

![[1+1 active failover NTB.png]]

![[1+1 active failover 处理故障后.png]]

---



---

# NTB 模块方案

NTB 逻辑上是两个背靠背的 endpoint，分别为 NT Virtual Endpoint 和 NT Link endpoint，==NT Virtual endpoint 在 PCIe Switch 内部连接到 DP 端口，NT Link endpoint 连接到另一个 Host==%%NT Link endpoint 也是在 Switch 内部嘛？%%，两个背靠背的 endpoint 之间需要有跨 Domain 的转换逻辑，主要支持以下功能：
- 地址转换：32-to-32，32-to-64，64-to-32,64-to-64；
- Doorbell：门铃通知机制；
- Scratchpad：数据共享；
- ID 转换：Request ID 和 Completion ID 转换；
- 中断：link 状态通知；
- ==EXP ROM==：加载 NTB 驱动，需要通过驱动加载 NTB 里面的表；
- ==No snoop clear==：从 Host0 到 Host1 报文传输过程中，可以清除报文头某些位。

## NTB 架构
==PCIe Spec：下行口不能多 Function 或者带 EP，因为没办法枚举他们。==

![[图1.5 Non-Transparent Bridge.png]]


如何实现 NTB？
第一种方式是实例化两个完整的 endpoint，中间加上转换逻辑，NT Virtual endpoint ==通过 PIPE 接口与 Switch DP 口连接==%%是下图中上面的 NTE ？？？%%，==NT link endpoint 通过 PIPE 与 PCIe PHY 连接==。
这种方式缺点是 endpoint 占用资源过高%%每个 NTB 需要两个 NTE%%，难以实现大量的 NTB 端口。
第二种方式是 NT Virtual endpoint 不与 Switch DP 连接，而是直接连接到 Switch 内部的 Virtual PCI Bus 上，这种方式可以省略一个 DP 端口，但违反了 PCIe 协议，PCIe 协议规定 Virtual PCI Bus 上只运行有 DP 口，不允许有设备。
第三种方式是为==每个 Switch 端口==%%是指的是 DP 还是 P2P Bridge？%%配置一个 endpoint，做成一个多功能 PCIe 端口，Switch 端口和 endpoint 可以共享硬件资源。背靠背 endpoint 之间的转换功能每个端口实现一份。、
这种方式的优点是==资源占用低==%%相比于第一种实现方式，可以省去一个DP，资源占用率低指的是不是不会进入 switch 内部呢？%%，可以实现大量的 endpoint，缺点是需要 PCIe IP 支持 Switch 端口和 endpoint 合在一起的多功能端口。

![[如何实现 NTB？.png]]

不仅 NT 连接的两个 Host 之间可以通信，多个 NT 之间也要能够互相通信：

![[两个 Host 通信.png]]

![[多 NT 互联.png]]

方案1：
NT 端口采用 ==embeded endpoint （Switch DSP integrated Endpoint）==实现，Switch 端口可以配置为 UP/DP 或者 EP。当端口工作在 NTB 模式时配置为 EP，与 embeded endpoint 背靠背通过 NT Bridge 连接，构成一个 NTB 端口。
优点：借助 embeded endpoint IP 实现，实现较简单直观，资源占用较少，Virtual PCI Bus 交换不需要特殊译码逻辑，embeded endpoint 可以在多个端口间共享，便于裁剪 NTB 端口数量。
缺点：只能支持 1+1，无法支持 N+1；switch 端口必须支持 SW 和 EP 模式切换，embeded endpoint 要在 UP 和 DP 端口之间切换连接，连线复杂，除非每个端口都实现一个 NTB；

![[1-NTB 文档学习.png]]

-  DP 口使用 Embeded endpoint，可以节约资源；
	- 没有事务层以下（没有链路层、物理层），内部实现互联。
- NT LINK EP 完整的 EP，物理端口；

![[方案 5.png]]

方案 4 需要在每个端口实现 NT DP/EP，资源消耗高，方案 5 可以将所有的 NT DP/EP 用 SOC 软件模拟实现，通过截获配置请求，为每个端口虚拟出一个 Virtual DP/Virtual EP，枚举完成后 Virtual DP/Virtual EP 的作用就是 BAR 译码，判断是否访问 NTB 的报文送给 NT Bridge 我们可以将 BAR 译码过程在 NT Bridge 实现，这样 NT Bridge with BAR 模块就可以放在 UP 端口下，而不是放到 Virtual DP/Virtual EP 下面。
优点：不需要 IP 支持嵌入式 NT EP Func，资源消耗少，可以支持 1+1 和 N+1，可以在多个端口间共享 NT Bridge。


### 多级 Switch 通过 NTB 跨 VCS 通信

3 个 Switch 互联，SW0 属于 VS0，SW1 属于 VS1，SW2 被划分成 VS0 和 VS1，Host 0 要访问 VS1 中的设备，或者与 Host1 通信，需要借助 SW2 VS0 UP 口上的 NTB 端口，通过 SW2 的 NTB 做地址转换后，路由到 VS1 的 EP1 出口。

![[多级 Switch 通过 NTB 跨 VCS 通信.png]]

---
## Doorbell 中断

NTB 支持 Doorbell 产生中断，软件写 BAR Doorbell 寄存器时查表将其转换为目的的 VCS 域的 MSI/MSIX 中断。

### NTE 实现会存在 Bug

BUG：中断报文产生与 NTB 数据之间可能会出现乱序。
- Host0 先向 Host1 发送 NTB 数据，数据发完后马上敲一下 Doorbell 寄存器；
- **NTB 数据会直接被路由到 Host1 所在出口的 ==SW OQ buffer0== 里，但是 Doorbell 会被路由到 ==Synthetic Subsystem NT== 模块**；
- NT 模块产生中断报文会送到 Host1 所在出口的另外一个 SW OQ buffer1 里；
- 两个 OQ buffer 虽然都是去同一个出口 station，但是他们之间调度的时候不能保证顺序；
	- Bug：有可能 OQ buffer1 的 Doorbell 会跑到 OQ buffer0 的 data 前面，导致软件出错；


Doorbell 实现在 Ingress NTB 模块实现若干个 Doorbell 寄存器，每个 Doorbell 寄存器对应若干个 MSI/MSIX 寄存器，软件在枚举 NTB 时由 SOC 填写好 MSI/MSIX 地址；Host 敲 Doorbell 的时候产生一个特殊 MSI/MSIX PD，Doorbell 报文被转换为 MSI/MSIX 消息，由 dice 构造 MSI/MSIX 报文发送出去；



## Scatch Pad




# QA

- [ ] tcam 原理以及如何实现？
- [ ] UEP 是什么？
- [ ] VCS 是什么？
- [ ] DP？？
- [ ] PBR 报文？
- [ ] HBR 路由
- [ ] BDF 路由，也被称为 ID 路由。
	-  ![[TYPE 1 编码格式.png]]
	- Primary Bus：switch P2P 端口上游总线号；
	- Secondary Bus：switch P2P 端口的下游第一个总线号；
	- Subordinate Bus：P2P 端口的下游最后一个总线号；
	- ![[PCIe 地址转发.png]]
	- 详细转发参考[[4 地址空间与事务路由#4.6 路由机制的应用方法（Applying Routing Mechanisms）]]


---

# TODO

---
