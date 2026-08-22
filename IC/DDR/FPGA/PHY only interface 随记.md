#spec #FPGA 
- PHY：讲一个事务转换为一个或者多个符合DRAM协议和时序要求的DRAM命令；不做DRAM协议或者定时检查；
- PHY运行频率是DRAM时钟频率的1/4，==PHY在每个系统时钟上接受四个DRAM命令，并在DRAM总线上连续的DRAM时钟周期上串行发送==。
	- 相当于：PHY接口有4个`command slot`，它可以接受每个系统时钟
	- PHY频率低，周期长，那如何接受四个DRAM命令？？
- `PHY FPGA`接口在每个DDR4总线上有一个输入端口，每个`PHY` `command/address` 输入端口位宽是其对应DRAM总线引脚位宽的8倍；
	- 比如：`DDR4`总线上有1-bit的`act_n`引脚，PHY对应8-bits `mc_ACT_n`输入端口；`mc_ACT_n`**每2比特**对应一个`command slot`；
		- A：由于`PHY`底层设计以及对双数据速率数据总线的支持，但`DRAM CA` 总线是单数据速率，需要对应 `PHY command slot` 的`2 bits`保持相同的值；
	- 因此`DDR`存在18个地址引脚，`PHY FPGA`地址输入端口对应144-bits。
- 

- MC需要等待**calDone**有效之后才会接受DRAM 命令，表示PHY以初始化、训练DDR；
- 系统时钟配置内部没有`buffer`，不允许`MMCM`驱动其他的`MMCM/PLL`。
- sys_rst：系统复位信号，高电平有效，需要5ns保持。


# PHY Only Interface
## Command and Address
### DDR4 接口：
- 为了与`1N timing`的DRAM时钟的中心对齐，应该将给定位对的两个位断言为**相同的值**。
- mc转换为DRAM处理过程：
	- `mc_BA/mc_BG/mc_CS_n`需要翻转处理，详细使用参考[[#EX3：PHY接口如何反转DRAM CA总线；]]
	-  `mc_ACT_n/mc_ADDR`：`mc_ACT_n[1:0]`对应第一个DRAM时钟周期，`Bits[3:2]`对应第二个，`Bits[5:4]`对应第三个，`Bits[8:7]`对应第四个。`mc_ADDR`信号处理相同。
		- 但其实是DRAM会先使用`slot 0`端口数据，其次`slot 1`；

| Signal                        | I/O | Description                            |
| ----------------------------- | --- | -------------------------------------- |
| mc_ACT_n[7:0]                 | I   | DRAM 激活命令信号。                           |
| mc_ADR[ADDR_WIDTH*8–1:0]      | I   | DRAM 地址信号。                             |
| mc_BA[BANK_WIDTH*8-1:0]       | I   | DRAM bank地址。<br>                       |
| mc_BG[BANK_GROUP_WIDTH*8-1:0] | I   | DRAN bank group地址。                     |
| mc_CKE[CKE_WIDTH*8-1:0]       | I   | DRAM CKE，                              |
| mc_CS_n[CS_WIDTH*8-1:0]       | I   | DRAM CS_n。标识哪个对应 slot 数据有效，使用规则查看 EX2。 |
| mc_ODT[ODT_WIDTH*8-1:0]       | I   | DRAM ODT。                              |
#### EX 1 ：PHY Command/Address Input Signal with DDR4 Command/Address Bus
![[Pasted image 20241012113443.png]]
1. 在系统时钟 `Cycle N`时，`slot1`位置发出一个`ACT`。
	1. `mc_ACT_n[3:2]`和`mc_CS_n[3:2]`在Cycle时刻为低电平，其余位为高电平；
	2. 大致在**两个系统周期**后`slot1`位置发出`ACT`，其余位置发出`NOP/DES`；
2. 在`Cycle N+3`时，`mc_ADR[121:120]`和`mc_CS_n[1:0]`为低电平，其余为高电平；
	1. 在**两个系统周期**后，在s`lot 0`处生成一个`READ`，其余位置生成`NOP/DES`；
3. ACT和READ之间间隔三个系统时钟周期，并需要考虑其系统时钟周期内的 `command slot`的位置，预计在DDR4总线上的间隔为`11 *DRAM cycle`。
	1. ==command slot按照顺序发出命令？==`ACT`在`slot 1`位置发出，`READ`在`slot0`中间间隔`3+4*2个 DRAM cycyle`；
		1. 读写命令通过必须在 **slot 0、2** 上发送，其余命令随机发送；
#### EX2：PHY Command/Address with All Four Command Slots
- 在`Cycle N`时刻， 三条命令是对`rank0`，一条命令对`rank1`。
	- 图中显示：`rank 0` 对应的`CS_n == 2'b01`；`rank 1` 对应的`CS_n == 2'b10`；为何不是从0开始呢？`CS_n == 2'b0`保留是为什么呢？
		- A：不是编码，是采用位对应rank；
- 为了不违反DRAM协议，BG和BA地址引脚分配不同命令到不同bank；

![[Pasted image 20241012174122.png]]
![[Pasted image 20241012174157.png]]
- `Cycle N`：
	- `slot 0`发出`READ`命令：==端口如何配置地址引脚？？==；
	- `slot 1`发出`ACT`命令；
	- `slot 2`发出`PRE`命令；
	- `slot 3`发出`REF`命令；
- `Cycle N+1`：剩下时刻的值全为1，代表什么命令呢？ NOP

#### EX3：BA/BG反转采样
- PHY接口信号转换为DRAM信号，BA和BG处理过程相同：
	- PHY信号按照**每一字节内 bit 顺序翻转**采样。![[Pasted image 20241014094644.png]]
	- **最简单的直观的方法**： ![[Pasted image 20241015102055.png]]

- 高八位为`BA[1]`，低八位为`BA[0]`;
	- 最后匹配到的值为0，3，1，0；![[Pasted image 20241014093827.png]]

### DDR4 未使用接口

| Signal               | I/O | Description                                     |
| -------------------- | --- | ----------------------------------------------- |
| mc_RAS_n[7:0]        | I   | DDR4不涉及。                                        |
| mc_CAS_n[7:0]        | I   | DDR4不涉及。                                        |
| mc_WE_n[7:0]         | I   | DDR4不涉及。                                        |
| mc_C[LR_WIDTH*8-1:0] | I   | 1、DDR4 DRAM Chip ID 引脚。<br>2、只有3DS RDIMMs 有效。   |
| mc_PAR[7:0]          | I   | 1、DRAM address parity。<br>2、只有RDIMMs和LRDIMMs有效。 |

## DATA bus
### Write Data
- `wrDataEn/`输出信号在**正常情况下有效一周期**或者**在开启`ECC`条件下的两周期**后，wrData/wrDataMask有效。
- **Q**：wr_data说==PHY里面没有**data buffer**==，但wrDataAddr表示存储返回==data buffer addr==；

| Signal                                   | I/O | Description                                                                                                                                                    |
| ---------------------------------------- | --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| wrData[DQ_WIDTH × 8 – 1:0]               | I   | 1、DRAM写数据；在DRAM总线上每`8 bits`对应一个`DQ lane`；在每一个系统时钟周期，端口传输整个 `BL8` 方式的写数据。                                                                                       |
| wrDataMask[DM_WIDTH × 8 – 1:0]           | I   | 1、DRAM write DM/DBI端口。每`1 bit`对应`wrData`的 `1 Byte`，对应于BL8传输的每个突发的每个字节一个比特。<br>2、对于`DDR4`接口，`wrDataMask`端口在`Vivado IDE`通过`DM_NO_DBI`和`DM_DBI_RD`的值可选配置。         |
| wrDataEn                                 | O   | 1、写数据使能信号。PHY中每个`wrDataEn`对应一个`write CAS`命令；                                                                                                                   |
| wrDataAddr[DATA_BUF_ADDR_WIDTH<br>– 1:0] | O   | 1、**可选**数据地址信号。<br>2、==PHY存储并返回每个运行中的写入CAS命令的**Data buffer**地址。`wrDataAddr`信号返回存储在buffer的地址。它仅在PHY断言wrDataEn时有效。==<br>3、可以使用此信号来管理将写数据发送到PHY以执行写CAS命令的过程，是可选的。 |
| tCWL[5:0]                                | O   | 1、**可选**控制信号，表示在`PHY`中`CAS write latency`。                                                                                                                     |
| dBufAdr[DATA_BUF_ADDR_WIDTH –<br>1:0]    | I   | Reserved. Should be tied Low.                                                                                                                                  |
### Read Data

| Signal                                   | I/O | Description                                                                                                                                                            |
| ---------------------------------------- | --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| rdData[DQ_WIDTH × 8 – 1:0]               | O   | 1、DRAM读数据。这个端口传输数据为整个BL8读取每个系统时钟周期。<br>2、只有当断言了`rdDataEn`、`per_rd_done`或`rmw_rd_done`时，`rdData`才有效。<br>3、PHY中没有数据buffer。                                               |
| rdDataEn                                 | O   | 1、读数据有效信号。有效时表示`rdData`和`rdDataAddr`是有效信号。<br>2、对于每个BL8读操作，rdDateEn在一个==系统时钟周期==内为高，除非被标记为特殊类型的读操作。                                                                    |
| rdDataAddr[DATA_BUF_ADDR_WIDTH<br>– 1:0] | O   | 1、**可选**控制信号。PHY存储并返回每个正在运行的 `READ CAS命令`的数据缓冲区地址。rdDataAddr信号返回存储的地址。<br>2、仅在PHY断言`rdDataEn`、`per_rd_done`或`rmw_rd_done`时有效。<br>3、设计可以使用该信号来管理捕获和存储PHY提供的读取数据的过程，可选的。 |
| per_rd_done                              | O   | 1、可选读数据有效信号，用于一**种特殊类型的读操作已经完成**，并且`rdData`和`rdDataAddr`是有效的。<br>2、当`PHY`输入`winInjTxn`与`mcRdCAS`同时断言为`High`时，读取被标记为特殊类型的读取，并且在返回数据时`per_rd_done`而不是`rdDataEn`断言。       |
| rmw_rd_done                              | O   | 1、可选读取数据的有效信号。该信号表示**一种特殊类型的读操作**已经完成，其关联的`rdData`和`rdDataAddr`信号是有效的。<br>2、当PHY输入`winRmw`与`mcRdCAS`同时断言为`High`时，读取被标记为特殊类型的读取，并且在返回数据时`rmw_rd_done`而不是`rdDataEn`断言    |
| rdDataEnd                                | O   | Unused. Tied High.                                                                                                                                                     |
### PHY Control

| Signal                               | I/O | Description                                                                                                                                                                                                                                                                                                               |
| ------------------------------------ | --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| calDone                              | O   | 有效表示DRAM已完成上电、初始化、矫正，PHY可以向DRAM发送命令；                                                                                                                                                                                                                                                                                      |
| mcRdCAS                              | I   | 1、Read CAS command issued。<br>2、当 `PHY CA`输入端口的一个`command slot`上 `READ CAS` 有效时，必须在一个系统时钟内响应该信号。<br>3、`calDone`有效（初始化完成）之前，此数据一直为`0x0`。                                                                                                                                                                                   |
| mcWrCAS                              | I   | 1、Write CAS command issued。<br>2、`mcWrCAS`同理；                                                                                                                                                                                                                                                                             |
| winRank[1:0]                         | I   | 1、Target rank for CAS commands，表示CAS命令对应的`rank`。<br>2、当`mccrdcas`或`mcWrCAS`有效时，必须有效。<br>3、PHY将该输入的值传递给==XIPHY==，以在多 `RANK` 系统中为`CAS`命令的目标`rank`选择校准结果。在单RNAK系统中，这个输入端口可以为`0x0`。                                                                                                                                           |
| mcCasSlot[1:0]                       | I   | 1、`CAS command slot select`。==**PHY只支持偶数命令槽的CAS命令**==。`mcCasSlot`表示在这`slot 0`或者`slot 2`上发出了读CAS或写CAS。<br>2、==PHY使用`mcCasSlot`来生成`XIPHY`控制信号，如DQ输出使能，需要相对于用于CAS命令的命令插槽的DRAM时钟周期分辨率。==<br>3、初始化完成后的有效值为`0x0`和`0x2`，初始化完成前为`0x0`。如果`mcRdCAS`或`mcWrCAS`，则该信号必须有效。                                                             |
| mcCasSlot2                           | I   | 1、`CAS slot 2 slect`。`mcCasSlot2`与`mcCasSlot2[1:0]`信号的作用类似，但`mcCasSlot2`用于PHY中的时序关键逻辑。<br>2、理想情况下，`mcCasSlot2`应该从`mcCasSlot[1:0]`的单独`flops`中驱动，以允许合成/实现更好地优化时序。<br>3、如果`mcRDCAS`或`mcWrCAS`有效， `mcCasSlot2`和`mcCasSlot[1:0]`必须始终一致。<br>3、为了保持一致，以下内容必须为TRUE: `mcCasSlot2==mcCasSlot[1]`。<br>保持在0x0直到calDone断言。Active-High。 |
| winlnjTxn                            | I   | 1、**可选**读命令类型指示。<br>2、当`winInjTxn`在与`mcRDCAS在同周期内有效时，**读取完成**时不会在`rdDataEn`有效，而是使用`per_rd_done`信号指示**特殊类型的读**已经完成，并且它的数据在`rdData`输出上是有效的。<br>3、在DDR3/DDR4 SDRAM控制器设计中，`winInjTxn/per_rd_done`信号仅在为`VT`跟踪而发出的读命令上断言`winInjTxn`，用于跟踪非系统读流量。                                                                                 |
| winRmw                               | I   | 1、**可选**读命令类型指示。<br>2、当`winRmw`和`mcRdCAS`在同周期中有效时，读完成标志使用`rmw_rd_done`，表明**特殊类型的读**已经完成，并且其数据在rdData输出上是有效的。<br>3、在`DDR3/DDR4 SDRAM`控制器设计中，`winRmw/rmw_rd_done`信号用于**跟踪作为读-修改-写流的一部分发出的读**。DDR3/DDR4 SDRAM控制器仅在`RMW`序列的读阶段发出的读命令上断言`winRmw`。                                                                              |
| winBuf[DATA_BUF_ADDR_WIDTH<br>– 1:0] | I   | 1、**可选**控制信号。<br>2、当`mcRDCAS`或`mcWrCAS`有效时，PHY将值存储在`winBuf`信号上。该值在`rdDataAddr`或`wrDataAddr`上返回，取决于是否使用`mcRDCAS`或`mcWrCAS`捕获`winBuf`。<br>3、在`DDR3/DDR4 SDRAM`控制器设计中，这些信号用于跟踪用于源写入数据或接收读取返回数据的数据缓冲区地址。                                                                                                                      |
| gt_data_ready                        | I   | 1、update VT Tracking。<br>2、该信号触发`PHY`读取`XIPHY中`的`RIU`寄存器，该寄存器测量**DQS门信号**与**读DQS前导的中心对齐**的程度，然后在需要时调整对齐。当电压和温度漂移时，必须周期性地断言该信号以保持DQS门对齐。有关更多信息，请参见VT跟踪，第178页。保持在0x0直到calDone断言。Active-High。                                                                                                                                |
- ==Q1==：为何需要单独实现`mcCasSlot2`表示呢？
- Q2：VT？？？
- Q3：关于 rdDataAddr、wrDataAddr、winBuf使用功能还不太熟悉；
	- 通过 vivado 波形和 tb，感觉这两个信号就是为了追踪读写命令，读写命令有效时进行计数，然后在与 en 信号同时生效，无其他功能；

### limtation
#### CAS Command Timing Limitations
- **PHY 只支持在偶数命令槽发出 CAS 命令**，比如 slot0，slot2；
- 原因：减少 PHY 设计的复杂性，具体跟 XIPHY 有关；
#### Minimum Write CAS Command Spacing
- **Write CAS to Write CAS 的最小命令间距为 8 个 DRAM 时钟**。
	- 若是在 1:4 的频率比条件下，==最小命令是不是 2 个系统时钟呢==？
	- ==但在手册 4-16 中举例不适用了，违反限制了；==
- 原因：物理限制，违反将会导致 PHY 可能没有足够的时间来切换其内部延迟设置，并以正确的定时在 DDR 总线上驱动写 DQ/DQS。
	- 内部延迟设置是在校准时确定的，随系统布局而变化。

#### System Considerations for CAS Command Spacing
- 根据 DRAM 手册计算之间延迟，不太懂呢。CAS 命令间隔统一 8 或以上 DRAM 时钟；
- 

#### Additive Latency
- 在 MRS 中使用 Additive Latency，对 mcWrCAS 有效之后 wrDataEn 的有效延迟。

#### VT Tracking


### EX
#### EX1： write command 
![[Pasted image 20241015091106.png]]
- 如何实现 BL8 数据传输的？？
- 控制信号是根据 CA 中数据得到的嘛？？？
#### EX2：Read Command
![[Pasted image 20241015091915.png]]
	==Q1==： 为何是在Cycle M+1时，返回读相应？Cycle M的意义在哪里呢？


# DDR 颗粒
- FPGA ip 只支持BL8
## 与 ASIC IP 不同：
### 读写到颗粒的数据
- 同样传入`0x0123_4567_89ab_cdef * 9`的数据 ，phy 读写时的数据是相同的，但在颗粒行为不同；
	- FPGA 先传入每个 8 Byte 的后 1byte，一次排序；![[Pasted image 20241030200242.png]]
	- ASIC 串行传入数据；

# QA
1. FPGA mc 中没有 buffer，PHY 协议呢？
2. mc slot如何控制？
	1. 是通过顺序发送？还是控制信号选择呢？
3. 项目接口频率一个是1：2，一个是1:4，还要注意频率转换
	1. 否，同相位，直接使用--wwf；