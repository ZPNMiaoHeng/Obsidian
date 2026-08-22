#SoC #DDR 
PS：v5.0和中接口不太相同，先以v4.0为主。
- [ ] 重点学习2-4章；

# 1.0 Overview
##### interface group

| Interface Group     | Description                                   |
| ------------------- | --------------------------------------------- |
| Command             | 需要驱动地址和命令信号到`DRAM`设备                          |
| Write Data          | 用于通过`DFI`发送写和接受读有效数据。                         |
| Read Data           |                                               |
| Update              | `MC`或者`PHY`可以使`DFI`总线空转。                      |
| Status              | 用于系统初始化、特性支持和控制到`DRAM`接口的有效时钟的存在。             |
| PHY Master          | 用于允许`PHY`控制`DFI`总线。                           |
| Disconnect Protocol | 允许正在进行的握手信号被断开。                               |
| Error               | 用于从`PHY`传输错误信息到`MC`。                          |
| 2N Mode             | 使用`DRAM`的`2N`功能（也被称为减速模式，`the geardown mode`） |
| Low Power Control   | 允许PHY进入 `power-saving` 模式。                    |
| MC to PHY Message   | 用于从`MC`给`PHY`发送定义信息。                          |
| WCK Control         | 控制`WCK`开断和时钟同步。                               |
# 2.0 Architecture

## 2.1 Clocking
详细时钟域关系请查看[[DDR_PHY_Interface_Specification_v5_1.pdf#page=16&offset=54,353|DDR_PHY_Interface_Specification_v5_1, 2.1 Clocking]]
1. DFI总线不包括时钟信号，使用的MC的时钟；
	1. DFI时钟和命令时钟是**同频**；
2. DFI包含三个时钟域：
	1. 控制时钟域（`the control clock domain`）![[Pasted image 20241008154207.png]]
	2. 命令时钟域（`the Command  ****`）
	3. `数据时钟域`（`the data  ****`）![[Pasted image 20241008154230.png]]
3. MC和PHY必须是同频，频率比仅适用于**PHY频率比**（命令和DFI数据时钟域）和**数据频率比**（DFI数据时钟域==？？？单独一个？？==）
4. `DFI clock domain signals do not operate at a clock ratio, they are always DFI clock based.` 
	1. 意思应该是DFI基于DFI使用？？？
## 2.2 DFI协议可选功能
- DBI
- CRC
- 频率改变
- CA
- 低功耗
- 错误信息
- 2N模式
- WCK控制接口
## 2.3 DFI特性要求
### 2.3.1全局特点
- DFI频率比；
- 频率可变；
- 低功耗控制；
- 错误信号；
- Update 接口；
- PHY master 接口；
- 时钟可禁用；
- 数据位使能；
- DFI断开；
- 独立通道支持；
- MC to PHY message；

### 2.3.2 内存特定功能
重点介绍DDR4，其余类型DDR[[DDR_PHY_Interface_Specification_v5_1.pdf#page=20&annotation=824R|DDR_PHY_Interface_Specification_v5_1, 页面 20]]；

| Memory | Topologies   | Applicable Features                                                  |
| ------ | ------------ | -------------------------------------------------------------------- |
| DDR4   | 分离式、无缓冲的DIMM | - 训练时DFI断开；<br>- 读、写数据翻转；<br>- 写数据CRC和错误；<br>- CA奇偶校验和错误；<br>- 2N模式； |
|        | 寄存器 DIMM     | 同上                                                                   |
|        | 减载 DIMM      | 同上                                                                   |
### 2.3.3 DFI信号
- DFI信号需要的参数，略过，使用时再查看：[[DDR_PHY_Interface_Specification_v5_1.pdf#page=24&annotation=833R|DDR_PHY_Interface_Specification_v5_1, 页面 24]]

## 2.4 Slice定义

| Parameter            | Defined By | Description                                                                             |
| -------------------- | ---------- | --------------------------------------------------------------------------------------- |
| phy data_slice_width | PHY        | 1. PHY数据切片宽度。定义通用PHY数据片组件的宽度。<br>2. 所有切片都定义为具有相同的宽度。可以使用`dfi data_bit_enable`参数禁用未使用的位。 |
- PHY 切片数量=`DFI data width`/`phy data_slice_width`；

# 3.0 Interface Signal Group
## 3.1 Command interface
- 为DRAM设备传输时序参数、地址和命令信号；
	- 保证DFI上的信号之间以定时关系的方式传递；




# 时序参数定义

| Parameter              | Defined By                | Description                                                                             |
| ---------------------- | ------------------------- | --------------------------------------------------------------------------------------- |
| `phy data_slice_width` | PHY,<br>2.4 Slice define  | 1. PHY数据切片宽度。定义通用PHY数据片组件的宽度。<br>2. 所有切片都定义为具有相同的宽度。可以使用`dfi data_bit_enable`参数禁用未使用的位。 |
| `t ctrl_delay`         | <br>3.1 Command Interface | 定义了`DFI`接口和`DRAM`接口之间的延迟；                                                               |

# Term
| Term   | Definition                                                                                                                   |
| ------ | ---------------------------------------------------------------------------------------------------------------------------- |
| CA Bus | 1. 手册定义一条包含**命令**、**地址**和**行列缓冲信息**的总线。<br>2. `CA Bus`在`LPDDR2`和`LPDDR3`系统中工作在双倍数据传输速率，在`LPDDR4`、`DDR5`和`LPDDR5`系统中单倍数据传输速率； |
| CAS    |                                                                                                                              |
| LPDDR  |                                                                                                                              |

# QA
1. Q：SPEC中使用uses，其余接口组为used。
	1. A：uses：使用某个功能；
	2. used：用于；