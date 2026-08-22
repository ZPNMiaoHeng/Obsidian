# DRAM 原理
### Memory Cell
![[Pasted image 20240924161952.png]]
- DDR每一个Cell由由一个电容和一个晶体管组成；
	- 电容中保存电荷大小表示存储的`0\1`，但会随着时间变化而放电，因此需要DDR定时进行自刷新。
	- 晶体管作为一个开关：需要先进行`ROW LINE`（word，**字线**）有效，激活晶体管，电荷导出到`Sense Amps`（传感放大器）；然后根据`column line`(bit，**位线**)选择需要数据。
### Bank
![[Pasted image 20240924163806.png]]
- ⚠️对DDR读写操作时，首先使用`ACTIVATED`命令激活**字线**（选中某一行），然后通过**位线**选中对应数据；
- 协议中规定：`colum`大小为10 bits，`row`大小根据DDR容量和规格变化；
### Row & column Decoding
![[Pasted image 20240924174746.png]]
1. **内存组织结构**：
    - 内存被组织成多个层级，包括Bank Group、Bank、Row和Column。
    - 用户提供的地址被称为逻辑地址，这个地址在被送到DRAM之前会被转换成物理地址。
2. **行和列的激活**：
    - 当确定了Bank Group和Bank之后，地址的行部分会激活内存阵列中的一行，这被称为“Word Line”（字线）。
    - 激活字线会将数据从内存阵列读入到称为“Sense Amplifiers”（感应放大器）的组件中。
    - 列地址然后从已经加载到感应放大器中的字中读出一部分数据。
    - 列的宽度被称为“Bit Line”（位线）。
3. **列宽度的标准**：
    - 列的宽度是标准的，可以是4位、8位或16位宽。
    - DQ数据总线的宽度与列宽度相同，根据DQ总线的宽度来对DRAM进行分类，x4、x8或x16。
### Bank Group，Bank，Row，Column
![[Pasted image 20240924174611.png]]
![[Pasted image 20240929154905.png]]
- 如果控制器数据位宽为 64bits，那么 CPU 每次操作内存数据为 64bits，如果组件是 8bits，那么就需要 8 个组件凑在一起，他们组成一组，称为一个 Rank。
	- `Rank = DDR_8bits * 8chips`
- Bank是指内存芯片内部的一个存储单元块。每个内存芯片可以包含多个 bank，每个 bank 可以独立地进行读写操作。
	- Bank 的数量通常是固定的，例如 DDR4 内存芯片通常有16个 bank。


# SoC DDR
- DDR4结构框图
![[Pasted image 20240929154006.png]]
- 简单SoC![[Pasted image 20240927094354.png]]
![[Pasted image 20240924164449.png]] 
- 控制器（Controller）可以被看作是逻辑层，它是一个大型的状态机，确保在执行读取、写入或刷新操作时严格遵守DDR协议。控制器负责管理内存的访问和操作，确保数据的准确读写和内存的维护。
- 物理层（PHY）则负责物理层的任务，它包含了所有模拟部分，以确保时钟、地址和数据信号可靠地从内存发射和捕获。PHY层处理的是内存与控制器之间的物理连接和信号传输。
- 写操作举例：
	- 写入DDR内存需要向内存发出多个命令，以激活bank、行和列，然后在一个精确的时间间隔（称为写入延迟）后，数据才被发送。在这个过程中，内存还需要定期刷新，以确保数据不会丢失。
	- 内存控制器抽象了上述所有的复杂性，并提供了一个简单的接口（如AXI），通过这个接口可以发出写入或读取指令。

## DRAM 子系统
![[Pasted image 20240925154225.png]]
- DRAM组成：
	1. DRAM：DDR；
	2. A DDR PHY：与DRAM使用 [[EDEC spec JESD79-4B.pdf]]标准协议；
	3. A DDR Controller：DDC
		1. 与PHY使用[[DDR_PHY_Interface_Specification_v4_0.pdf]]交互；
		2. 用户和DDC之间接口可以使用标准协议（比如：AMBA）或者自定义；
		3. 将逻辑地址转换为物理地址；
		4. 内部包含Cache或者TCAM，可以将用户请求进行重排序；
# Spec
![[Pasted image 20240924165958.png]]
- 蓝色表示：外部输入控制信号；
- 红色表示：外部输入始终信号
- 紫色表示：读写数据和有效标识；
## Input/Output port

| 名字                              | 类型               | 功能                                                                                         |
| ------------------------------- | ---------------- | ------------------------------------------------------------------------------------------ |
| RESET_n                         | Input            | 复位信号，低电平有效。                                                                                |
| CS_n                            | Input            | Chip Select. 片选信号，低电平有效。手册中介绍，CS_n用在命令模式中，只有其低电平有效，其他命令才有意义。                               |
| CKE                             | Input            | Clock Enable. <br>1. 同步信号； <br>2. 高电平有效，低电平无效，低电平下提供预充电和自刷新操作；<br>3. 包含内部时钟信号、设备输入缓冲和输出驱动。 |
| CK_t/CK_c                       | Input            | 差分输入时钟。所有输入地址和控制信号在CK_t上升沿和CK_c下降沿交叉处采样。                                                   |
| DQ/DQS                          | Inout/<br>Output | Data Bus & Data Strobe. Data bus控制数据读写，strobe标识有效数据。                                       |
| RAS_n/A16 CAS_n/A15<br>WE_n/A14 | Input            | 1. 当 `ACT_n & CS_n` 低电平时, 这三位为行地址位.<br>2. `ACT_n` 低电平有效时，这三个信号表示命令操作；                      |
| ACT_n                           | Input            | Activate 命令有效端口，低电平有效；                                                                     |
| BG0-1 BA0-1                     | Input            | Bank Group, Bank Address                                                                   |
| A0-13                           | Input            | Address端口                                                                                  |

## DRAM Sizing & Addressing
![[Pasted image 20240924185523.png]]
- 读写操作使用BL8（Brust Length 8）模式，每次传输`列宽度 * 8`bits数据；
- `Page Size=2^(Column Address Bits) × Data Width`;
- **DRAM 颗粒的容量 = 地址数量 x 位宽**
- 举例：其中“文件柜大小”代表内存的总容量，而“纸张大小”代表内存的数据宽度
	- ROW address（行地址）：这相当于确定文件柜中哪个抽屉包含文件。在内存中，行地址帮助定位数据存储在内存阵列的哪一行。
	- COLUMN address（列地址）：这相当于确定抽屉中文件的具体位置。在内存中，列地址帮助定位数据在行中的具体列。
	- DDR4 DRAM不同的容量表示容量不同的文件柜，比如4Gb中等大小的文件柜；
	- 文件柜大小可以根据能存放的“纸张大小”（即数据宽度）有不同的形式因素：A5大小纸张（x4）、A4大小纸张（x8）、A3大小纸张（x16）；
### Rank(Depth Cascading) & Width Cascading
![[Pasted image 20240925093315.png]]
- 举例1：假如你需要一个16Gb的DDR，你可以选择使用两个8Gb的DDR，外部通CS_n信号选择；
![[Pasted image 20240925141608.png]]
- **width cascading**：在宽度级联中，两个DRAM（动态随机存取存储器）都连接到相同的ChipSelects（芯片选择信号）、Address（地址总线）和Command bus（命令总线）。但使用数据总线（DQ & DQS）的不同部分。；
- 举例2：假如你需要一个`8Gb x8`的存储器，可以选择两个`4Gb x4`的存储器，使用**width cascading**方式连接。

## Command Truth Table
| **Function**                  | **Shortcode** | **CS_n** | **ACT_n** | **RAS_n/A16** | **CAS_n/A15** | **WE_n/A14** | **A10/AP** |
| ----------------------------- | ------------- | -------- | --------- | ------------- | ------------- | ------------ | ---------- |
| Refresh                       | REF           | L        | H         | L             | L             | H            | H or L     |
| Single Bank Precharge         | PRE           | L        | H         | L             | H             | L            | L          |
| Bank Activate                 | ACT           | L        | L         | Row Address   |               |              |            |
| Write                         | WR            | L        | H         | H             | L             | L            | L          |
| Write with <br>Auto-Precharge | WRA           | L        | H         | H             | L             | L            | H          |
| Read                          | RD            | L        | H         | H             | L             | H            | L          |
| Read with <br>Auto-Precharge  | RDA           | L        | H         | H             | L             | H            | H          |
- 其余命令，参考《section 4.1 of the [[JEDEC spec JESD79-4B]]》；

### 读写操作
1. **读写操作**：
	1. 首先，通过发出`ACTIVATE`命令，将ACT_n（行地址选通信号）和CS_n（片选信号）在时钟周期内拉低，来激活特定的行。
	2. 然后，紧接着发出读（RD）或写（WR）命令。
2. **行地址选通（RAS）**：在激活命令发出的同时，使用地址位选择要激活的BankGroup、Bank和Row。（x4、x8使用BG0和BG1，x16使用BG0选择 Bankgroup；BA0-BA1选择bank；A0-A17选择行）
3. **列地址选通（CAS）**：在读或写命令发出的同时，会使用地址位用于选择突发操作的起始列位置。（BL8 mode，突发传输8次数据）
4. **感测放大器（Sense Amps）**：每个Bank只有一组感测放大器。如果要对同一Bank中不同的行进行读写操作，必须先使用预充电命令（PRECHARGE）来关闭当前打开的行。（预充电命令类似于关闭文件柜中的抽屉，它会导致感测放大器中的数据被写回到行中。）
5. **自动预充电命令**：除了发送预充电命令来关闭行之外，还可以使用带有自动预充电功能的读（RDA）和写（WRA）命令。这些命令告诉DRAM在读写操作完成后自动关闭/预充电行。由于列地址仅使用地址位A0-A9，因此在CAS期间未使用的**A10位被用来表示自动预充电**。
#### Read
![[Pasted image 20240925150413.png]]
- 突发传输：BL8；
- 读操作：
	1. 首先执行`ACT`，激活对应行；
	2. 然后执行`RDA`，将会通过突发传输方式读取在激活行中对应数据；
	3. `RDA`命令将会在读取操作完成后自动执行`PRE`命令，将`Sense Amplifiers`中保存的数据写回内存过程；
#### Write
![[Pasted image 20240925150419.png]]
- 写操作：
	1. 首先执行`ACT`，激活对应行；
	2. 然后执行`WR`，将会通过突发传输方式将数据写入在激活行；
	3. 然后执行`WRA`命令将会在写操作完成后自动执行`PRE`命令（因为两次写操作对应的行相同，无需执行再执行`PRE`、`ACT`），将`Sense Amplifiers`中保存的数据写回内存过程；


## Initialization, Calibration, Train
![[Pasted image 20240927093615.png]]
### Initialization
![[Pasted image 20240927094512.png]]
- DRAM初始化流程：
	1. DRAM 打开电源；
	2. 将`RESET`置为低电平（有效），`CKE`置为高电平（有效，时钟使能信号）；
	3. 时钟开始工作：`CK_t/CK_c`；
	4. 发出`MRS`相关命令，设置模式寄存器的值；
	5. 执行ZQ校准`ZQCL`；
	6. 将`DRAM`置于`IDLE`状态；
- 初始化完成后，`DRAM` 得到`工作频率`、`CL`、`CWL`和一些其他的时序参数;
- `MRS`设置的详细细节请参考：[[EDEC spec JESD79-4B.pdf#page=20&offset=71,509|EDEC spec JESD79-4B, 3.3 RESET and Initialization Procedure]]
### Calibration
#### ZQ Calibration
![[Pasted image 20240927101036.png]]
- **`ZQCL`是校正数据引脚`DQ`的电压**，保证输入和输出数据的稳定性；
#### ZQCL 校正DQ原理
![[Pasted image 20240927102448.png]]
- 从电路图得知，每一个`DQ`都是由一组`240Ω`的电阻并联组成，为何？
	1. A1：因为`CMOS`物理原因，这一组电阻不可能精准达到`240Ω`；
	2. A2：电阻大小会受到**电压**和**温度**影响；
	3. A3：每个PCB布局是不相同的，需要电阻校正，保证数据完整性；
- DRAM如何保证电阻能够精确到240Ω？
	- 内部设置一个`DQ calibration control block`；
	- 一个ZQ引脚额外接入一个偏差在`（+/-1%）240Ω`的**参考电阻**，能够保证在任何温度下都稳定在`240Ω`；
	- 在初始化时，如果得到`ZQCL`命令，`DQ calibration control block`模块开始工作，会得到一个参数（`tuning value`），然后将此参数复制到每一个`DQ`引脚内部电路；
#### 240Ω电阻电路原理
1. 在DQ电路中，存在一种特殊的电阻，称为**Poly Silicon Resistor**。
	1. 多晶硅电阻：是一种CMOS工艺互补的电阻；
2. 多晶硅电阻器的阻值通常略大于240欧姆。
3. 为了精确调整阻值到240欧姆，会将多个p沟道器件并联到这个多晶硅电阻器上。
##### 举例：
- 下图放大了DQ电路的一个240欧姆的分支，上面连接了5个P沟道晶体管，这些晶体管的设置是由输入信号`VOH[0:4]`控制的。
![[Pasted image 20240927104555.png]]
1. **电路连接**：DQ校准控制块连接的电路本质上是一个电阻分压器电路。这种电路由两个电阻组成，一个电阻是多晶硅（poly），另一个是精确的240欧姆电阻。
2. **ZQCL命令**：在初始化过程中，当发出`ZQCL`命令时，DQ校准控制块被激活。
3. **内部比较器**：DQ校准控制块内部有一个比较器，它会调整p沟道器件（p-channel devices），使用`VOH[0:4]`（一个5位的电压输出高电平）来调整电压。
4. **电压调整目标**：内部比较器会持续调整，直到电压精确达到VDDq的一半（VDDq是数据总线供电电压）。这里VDDq/2是一个经典的电阻分压器的输出电压。
5. **校准完成**：一旦电压调整到VDDq/2，校准过程就完成了。
6. **VOH值传递**：校准完成后，VOH的值会被传递到所有的DQ引脚。
 
![[Pasted image 20240927105342.png]]

#### Verf DQ Calibration
#### MRS 配置
- `MR1[2:1]`来控制来自DRAM的信号驱动强度；
- 而终止电阻（==上拉电阻==）可以通过模式寄存器`MR1`、`MR2`和`MR5`中的`RTT_NOM`、`RTT_WR`和`RTT_PARK`的组合来控制。

#### Vref DQ Calibration
![[Pasted image 20240927110005.png]]
- 在DDR4内存技术中，数据线路（DQ）的终止方式发生了变化，从`CTT/SSTL`变为了`POD`。这种变化的目的是为了在高速传输时提高信号完整性，并节省输入输出（IO）的功耗。如下图所示：
![[Pasted image 20240927111519.png]]
- DDR3使用Vdd/2作为电压参考来判断数据信号，而DDR4使用内部的`VrefDQ`（初始化时，通过MR6设置）作为电压参考，并且需要在初始化过程中进行校准。
### Read/Write Training
- 初始化程序已经完成，`DRAM`处于`IDLE`，但`DRAM`仍然不能正常工作。控制器和物理层（PHY）需要执行`Read/Write Training`，对`DRAM`进行细致的调整和校准，以确保数据能够可靠地写入或读取。
	1. 运行算法以在DRAM中对齐`clock[CK]`和`data strobe [DQS]`：为了确保数据时钟和数据存取信号在正确的时间对齐，从而允许数据正确地写入或从内存中读取。
	2. 运行算法并确定正确的读和写延迟到`DRAM`；
    3. `Centers the data eye for reads`：
	    1. `data eye`是指在数据信号波形中，数据可以被正确读取的区域；
	    2.  `Center the data eye`：调整读取操作，以便数据在`data eye`的中心被读取，从而提高读取操作的可靠性。
    4. 如果信号完整性差且数据不能可靠地写入或读取，则报告错误；
#### 为啥需要Training？
![[Pasted image 20240927140246.png]]
- 上图展示了`SoC`和`DRAM`之间如何通过`data signal` 和 `address/command signals`连接在一起；
	- `DQ&DQS`使用**星型拓扑结构**连接到每个内存模块，因为每个内存模块的连接到72个数据线的不同部分，独立连接以确保数据传输的准确性和效率；
	- `DIMM`上的`A/CK/CKE/WE/CSn`（地址、时钟、时钟使能、读使能、片选信号）使用`fly-by routing topology`（**飞线路由拓扑**）。因为在`DIMM`上的所有`DRAM`使用相同的地址线，飞线路由可以达到更完整的信号和更快的速度；
	- 从SoC的角度看，**DIMM上的每一块DRAM之间的距离是不相同的**，一条读写命令发出后，所有的DRAM接收的时间是不相同的。
		- 因此`DDR Ctrl`需要考虑`PCB走线延迟`和`fly-by routing topology`带来的延迟。
		- **解决方法**：**在初始化矫正中，`Asic/Processor`需要计算DRAM之间的延迟；然后根据延迟调整其内部电路，以确保在正确的时刻锁存（latch）来自不同DRAM芯片的数据。**
		- **Q：读写训练是计算DRAM之间的CWL？**
#### Write Leveling
⚠️：`tDQSS`指的是`DQS`相对于`CK`的位置。
	- `tDQSS`必须在规格书中定义的最小值`tDQSS(MIN)`和最大值`tDQSS(MAX)`之间。
	- 如果违反了`tDQSS`，可能会导致错误的数据被写入到内存中。
![[Pasted image 20240927145530.png]]
1. 将模式寄存器 MR1 的比特 7 设为 1，使 DRAM 进入 Write Leveling 模式。在该模式中，DRAM 在数据有效 DQS 信号上升沿采样时钟信号 CK，并将采样值通过数据信号 DQ 返回给控制器；
2. 控制器发送一系列 DQS 信号，在 Write Leveling 模式中，DRAM 根据 DQS 信号采样 CK 信号，返回采样值 1 或者 0；
3. 控制器接下来
	1. 观察 DRAM 返回的 CK 采样值；
	2. 根据采样值增加或者减少 DQS 信号的延迟；
	3. 继续发送更新延迟的 DQS 信号，继续观察 CK 采样值；
4. DRAM 在 DQS 信号有效时，采样 CK 信号并返回；
5.  重复步骤 2 至 4，直到控制器检测到返回值从 0 变化到 1。此时，DQS 与 CK 上升沿对齐，控制器锁定当前的 DQS 延迟，当前 DRAM 的 Write Leveling 完成；
6. 重复步骤 2 至 5，直到 DIMM 的所有 DRAM 颗粒都完成 Write Leveling；
7. 通过向模式寄存器 MR1 的比特 7 写 0，退出 Write Leveling 模式；
#### MPR Pattern Write
![[Pasted image 20240927145956.png]]
- DDR4 DRAM中包含四个8bits的可编程寄存器（MPR，多用途寄存器），用于DQ比特训练；
- 通过向模式寄存器`MR3[2]` 写 1，进入 MPR 访问模式，在该模式下所以向 DRAM 进行的读写操作都会同 MPR 进行，而不是真正的存储介质。
#### Read Centering
- 目的是**训练控制器（或者PHY）内的读采样电路，在读数据眼图的中央进行采样**。
	1. `MR3[2]==1` ，进入 MPR 访问模式，从 MPR 而不是 DRAM 存储介质中读取数据。
	2. 发起一系列读请求，此时返回的是在 `MPR Pattern Write` 步骤中预先写入 MPR 的 pattern。假设 pattern 是交替变化的 `1-0-1-0-...`。
	3. 在读数据进行过程中,增加或者减少采样电路相对于时钟的采样延迟，来确定读数据眼图的左右边界。（译注：即保证读取数据正确，与 pattern 一致时，最小以及最大采样延迟）。
	4. 在确定眼图的左右边界后，将读延迟寄存器设置为眼图的中央。
	5. 对每一条数据信号 DQ 重复上述操作。
#### Write Centering
与 Read Centering 类似，**Write Centering 的目的是设定每条数据信号线上写数据的发送延迟，使 DRAM 端能够根据对齐数据眼图的中央的 DQS 采样数据信号 DQ**。

在 Write Centering 的过程中，控制器不断执行`写-读-延迟变化-比较 （Write-Read-Shift-Compare）`的流程：
1. 发出一系列的写，读请求
2. 增加写数据时的发送延迟
3. 将读取的数据与发送数据进行比较

通过上述流程，控制器判断出正常读写数据时能容忍的最大发送延迟。因此可以推断出写数据的左右有效边界，并在 DRAM 端将写数据的中央与 DQS 边沿对齐。

### 周期性校准 Periodic Calibration

交换机或者路由器等网络设备，**运行过程中的温度和电压可能发生变化**。为了确保信号完整性，以及读写的稳定性，一些在初始化阶段进行训练的参数必须重新训练更新。控制器 IP 通常会提供下列两项周期性校准流程。
- **周期性 ZQ 校准**，也被称为 ZQCS （ZQ Calibration Short），用于定期校准 240 欧姆电阻；
- **周期性 Read Centering**，重新计算读取延迟以及其他相关的参数；

周期性校准是一项可选的功能，因为如果你可以确定你的设备只会工作在稳定的温度环境下，那么初始化时进行的 ZQ 校准以及读写训练就已经足够了

一般来说控制器可以通过设定一个计时器，来进行周期性校准，在计时器计满中断发生后进行周期性校准。

## Timing Parameters
·本小节介绍常用的时序参数，后续继续补充；
### ACTIVATE Timing
- ACT命令是将选中的行放在传感放大器中。

| Parameter | Full Name                                       | Function                                                                            |
| --------- | ----------------------------------------------- | ----------------------------------------------------------------------------------- |
| tRRD_S    | `row-to-row delay--short`                       | 不同`Bank group`的`ACT`之间的行与行最小延迟间隔。                                                   |
| tRRD_L    | `row-to-row delay--long`                        | 相同`Bank group`之间`ACT`之间最长时间间隔。                                                      |
| tFAW      | `Four Activate Window`或者`Fifth Activate Window` | 1. 定义：时间限制，定义了一个时间窗口，在这段时间内只能发出四个`ACT`。<br>2. 功能：这个限制确保了内存操作的顺序性和时间管理，以避免潜在的冲突和性能问题 |
![[Pasted image 20240929093948.png]]
![[Pasted image 20240929093137.png]]
- 举例：`DDC`可以连续不断地发出`ACT`，每个命令之间有`tRRD`的间隔。一旦在`tFAM`时间窗口内发出了四个激活命令，就不能发出另一个激活命令，需等待`tFAW`时间窗口结束。
### REFRESH Timing
| Parameter | Name                    | Function                                                               |
| --------- | ----------------------- | ---------------------------------------------------------------------- |
| tREFI     | Interval time<br>刷新周期   | `DDC`需要以平均间隔`tREFI`时间执行`REF`。<br>- 物理因素：与电容器漏电时间相关；                    |
| tRP       | Precharge time<br>预充电时间 | 在`REF`发送之前，`bank`需要预充电并保持空闲的最小时间。并保持`tRP`时间的`IDLE`.                    |
| tRFC      | <br>刷新恢复时间              | - 除了`DES`命令之外，发出`REF`之后，需要等待tRFC才能发送下一条有效命令。<br>- 物理因素：与器件刷新电容的物理时间相关； |
![[Pasted image 20240929094024.png]]
![[Pasted image 20240929094031.png]]
- `tREFI` 是`REF`的平均刷新时间，允许`REF`命令在之前或者之后执行，
	- 只需要保证平均刷新时间满足`tREFI`和两条刷新命令之间大于等于`tRFC`；
	- 在高密度的内存中，如果严格按照固定的tREFI执行REF，可能会导致性能损失，因为REF会占用内存的带宽；
- REF命令更具Refresh Mode设置。
### READ Timing
  
| Parameter        | Full Name                     | Function                                                                                                     |
| ---------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------ |
|                  |                               | ==**Read Timing**==                                                                                          |
| CL               | CAS Latency                   | 1. CAS，列地址选用信号。当列地址被放位线时，此信号有效；<br>2. CAS延迟。当`READ`发出后，到第一个输出数据位之间的延迟信息。<br>3. 通过`MR0`设置大小，与`SDRAM`运行频率息息相关； |
| AL               | Additive Latency              | 1. 允许`ACT`有效后立即发出`READ`，但`AL`间隔时间之后才有效；<br>2.可以支持更高的带宽                                                       |
| RL               | Read Latency                  | 读延迟，`RL = CL + AL`                                                                                           |
| tCCD_S & tCCD_L  | column-to-column short & long | 访问不同`BG`需要的时间延迟比相同`BG`时间要少；<br>1. 不同`BG`之间，所需`tCCD_S`延迟；<br>2. 相同`BG`之间，所需`tCCD_L`延迟；                        |
|                  |                               | ==**Clock to Data Strobe relationship**==                                                                    |
| tDQSCK (MIN/MAX) | DQS to CK_t/CK_c              | 描述DQS上升沿与CK_t、CK_c有效范围。                                                                                      |
| tDQSCK           |                               | DQS上升沿在在CK真实位置。                                                                                              |
| tQSH             |                               | DQS的高电平脉冲宽度。                                                                                                 |
| tQSL             |                               | DQS的低电平脉冲宽度。                                                                                                 |
|                  |                               | ==**Data Strobe to Data relationship**==                                                                     |
| tDQSQ            |                               | 1. 相关DQ数据引脚的最新有效转换。<br>2. DQS翻转与DQ data-eye左边沿之间延迟。                                                          |
| tQH              |                               | 1. 相关DQ数据引脚最早无效转换；<br>2. 下图中DQS到DQ data-eye 的右边缘时间；                                                          |
- Q：为什么访问相同BG需要的延迟大于不同BG呢？（tCCD_L>tCCD_S）
	- A:跟DDR4设计相关；
	- 详细请参考[(1 封私信 / 10 条消息) 同一bank group page hit的时间是tccd_S还是tccd_L? - 知乎 (zhihu.com)](https://www.zhihu.com/question/59944554)
- Q：DATA-eye？？


![[Pasted image 20240929113952.png]]
- 不同`BG`连续的`READ`；
- 连续读操作：`tCCD_S=4`；
- RL=AL+CL=0+11=11. 

![[Pasted image 20240929114004.png]]
- 不同`BG`不连续的`READ`；
- ==不连续读操作：`tCCD_S=5`？==


![[Pasted image 20240929114014.png]]
![[Pasted image 20240929112519.png]]
### WRITE Timing
与读操作类似；
  
| Parameter       | Full Name         | Function                                                                                                                                                      |
| --------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                 |                   | ==**Write timing**==                                                                                                                                          |
| CWL             | CAS Write Latency | 1. `WRITE`命令和`the first bit of input data`（==输入数据第一位之间？==）的时钟延迟。<br>2. 使用`MR2`配置；                                                                             |
| AL              | Additive Latency  | 1. 在`ACT`命令有效后，允许`WIRTE`命令立即发出，在`AL`时钟周期后开始执行；<br>2. 优点：获得更高的带宽或速度；                                                                                           |
| WL              | Write Latency     | 写延迟时间，`WL = CWL + AL`                                                                                                                                         |
| tCCD_S & tCCD_L |                   | 同`READ`。                                                                                                                                                      |
|                 |                   | ==**Clock to Data Strobe relationship**==                                                                                                                     |
| tDQSS (MIN/MAX) |                   | 同`READ`。                                                                                                                                                      |
| tDQSS           |                   | 同`READ`。                                                                                                                                                      |
| tDQSH           |                   | 同`READ`。                                                                                                                                                      |
| tDQSL           |                   | 同`READ`。                                                                                                                                                      |
| tWPST           | post-write        | 时间间隔开始于最后一个有效的数据脉冲信号有效，结束于脉冲信号变为高电平且不是驱动级别的时候                                                                                                                 |
| tWPRE           | pre-write         | 1. 数据写入之前需要的时间。<br>2. It is the time between when the data strobe goes from non-valid (HIGH) to valid (LOW, initial drive level). <br>       从DQS无效变为有效之间的时间； |
![[Pasted image 20240929114656.png]]
### Mode Register Timing

| Parameter | Full Name               | Function                                       |
| --------- | ----------------------- | ---------------------------------------------- |
| tMRD      | MRS command cycle time. | 1. 数据到模式寄存器写操作的时间；<br>+<br>2. 两条MRS命令之间最小时间延迟； |
| tMOD      |                         | `MRS`到`非MRS`之间最小时间，除`DRS`之外。                   |
![[Pasted image 20240929114738.png]]
![[Pasted image 20240929114744.png]]
# Reference
- [DDR4 SDRAM - Initialization, Training and Calibration - systemverilog.io](https://www.systemverilog.io/design/ddr4-initialization-and-calibration/)
- [译文：DDR4 - Initialization, Training and Calibration - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/261747940)
- [DDR4 SDRAM - Understanding Timing Parameters - systemverilog.io](https://www.systemverilog.io/design/understanding-ddr4-timing-parameters/)
- [DDR4 SDRAM - Timing Parameters Cheat Sheet - systemverilog.io](https://www.systemverilog.io/design/ddr4-timing-parameters-cheatsheet/)
- [嵌入式硬件-Xilinx FPGA DDR4 接口配置基础（PG150）_ddr4接口-CSDN博客](https://blog.csdn.net/DongDong314/article/details/140504137)