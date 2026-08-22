---
aliases:
  - uart
Done:
tags:
  - SoC
  - spec
---
# Note
## 基本功能
- uart，universal asynchronous receiver and transmitter，通用异步收发传输器；
- uart 空闲时，串行总线上数据为1，当有数据传输时起始位为数值0，停止传输时数值为1；
- 传输格式：数据起始位（位宽为1） + 数据位（位宽大小6、7、8）+ 奇偶校验位（可选）+停止位（位宽大小为1、1.5、2）；
	- 数据传输格式、波特率是在工作前进行配置（内部含有配置寄存器）；
	- 数据最低有效位（LSB）最先被传输；
	- 停止位中1.5是传输 1.5 bit 所需要的时间，通过==波特率计算==；
	- 下图是8个数据位、无校验位、1个停止位的传输格式；
![[Pasted image 20250208111442.png]]

---
- uart 传输未携带时钟信息，接收方和发送方之间的时钟是通过波特率（每秒的位数）计算采样率；
	- 常用波特率为2400、4800、9600、19200等；
	- 波特率为每秒传输的符号数，单位为波特（Baud），理论上`时钟频率=波特率*过采样率`，但实际项目上是通过 pll 分出的系统时钟；
### 过采样：
##### 过采样时钟生成
- 过采样时钟的频率是波特率的16倍（或其他倍数，如8倍或32倍）。
- 例如，如果波特率为9600 bps，过采样时钟频率为 9600×16=153,600 Hz。
##### 起始位检测
- 接收端持续监测RX引脚的电平。
- 当检测到下降沿（从高电平到低电平）时，认为可能是起始位。
- 启动过采样计数器，开始对起始位进行多次采样。
	- 若采样结果不是低电平，则认为**噪声干扰**，忽略该起始位；
#####  数据位采样
- 在每个比特周期内，使用过采样时钟对输入信号进行16次采样。
- 通过多数表决（Majority Voting）或中点采样（Mid-point Sampling）确定数据位的值。
	-  多数表决：在每个比特周期内，对16次采样结果进行统计。如果高电平（逻辑1）的采样次数多于低电平（逻辑0），则判定该比特为1，否则为0。
	- 中点采样：在每个比特周期的中心点（通常是第8次采样）进行采样。可以减少噪声的影响，同时降低计算复杂度。
##### 停止位检测
- 在停止位周期内，同样使用过采样时钟进行多次采样。
- 如果停止位不是高电平，可能触发**帧错误（Framing Error）**。

### 时钟生成过程
##### 1. **用户配置波特率**

uart 初始化时，用户指定特定的**波特率**，并将其写入（一般都是通过 APB 总线）到 uart 的配置寄存器内；
##### 2. **系统时钟**（由PLL生成）

系统时钟是UART模块工作的基础时钟，通常由PLL（锁相环）生成。PLL将外部晶振的低频时钟倍频到较高的系统时钟频率（如16 MHz、50 MHz等）。这个系统时钟是全局的，供整个芯片的外设使用；
##### 3. **计算分频系数**

UART模块根据用户配置的波特率和系统时钟频率，计算出分频系数（N）。分频系数的计算公式为：
N=系统时钟频率/(波特率×过采样率)

其中：
- **过采样率**：通常为16，即每个符号采样16次。
- **系统时钟频率**：由PLL生成的全局时钟频率。
- **波特率**：用户配置的通信速率。

例如：
- 系统时钟频率为16 MHz，波特率为9600，过采样率为16：
N=16,000,000/(9600×16)≈104.1667
    取整后，分频系数为104。

---

##### 4. **生成波特率时钟**

UART模块内部有一个分频器，它根据计算出的分频系数（N）对系统时钟进行分频，生成与波特率匹配的时钟频率。例如：
- 分频系数为104时，生成的时钟频率为：
    波特率时钟频率=16,000,000/104≈153846 Hz
    这个时钟频率用于驱动UART的发送和接收逻辑。
    

---

##### 5. **采样和同步**

在接收数据时，UART模块使用生成的波特率时钟对输入信号进行采样。由于过采样率为16，UART模块会在每个符号周期内采样16次，以确保准确地检测到起始位、数据位和停止位。

---

##### 6. **误差处理**

由于分频系数通常是整数，实际生成的波特率可能与用户配置的波特率略有误差。例如：
- 理论波特率：9600
- 实际波特率：
    实际波特率=16,000,000/(104×16)≈9615 Baud
    误差为：
    误差=(9615−9600)/9600×100%≈0.16%
    通常，误差在±2%以内是可以接受的。
    

---

##### 7. **总结**

- **用户配置波特率**：UART模块根据用户设置的波特率参数工作。
- **系统时钟**：由PLL生成，作为UART模块的基准时钟。
- **分频系数**：根据系统时钟和波特率计算得出，用于生成波特率时钟。
- **波特率时钟**：通过分频系统时钟得到，驱动UART的发送和接收逻辑。
- **采样和同步**：UART模块使用波特率时钟对输入信号进行采样和同步。

---

### 流控机制
![[Pasted image 20250218144409.png]]
![[Pasted image 20250218144422.png]]
#### RTS
- 当 RTS 启用时，只要 nUARTRTS 信号有效，接受 FIFO 就可以不断接受输入数据，直到 FIFO
到达水线；
#### CTS
- 启用 CTS 后，Uart 发送端在发送下一个字节之前会检查 nUARTCTS 信号，只有 nUARTCTS
有效且发送 FIFO 不为空时，数据才会发送；
#### 数据缓冲
![[Pasted image 20250210104019.png]]
- Flag FF；
- Flag FF and one-word buffer；
- FlFO buffer；
#### RTS/CTS
RTS（Request To Send，请求发送）和CTS（Clear To Send，清除发送）是UART（通用异步收发传输器）通信中常用的硬件流量控制机制。它们通过额外的信号线来协调发送方和接收方之间的数据传输，防止因接收方缓冲区满而导致的数据丢失。

---

##### 1. RTS/CTS 的基本原理

RTS和CTS是两条独立的信号线，分别由发送方和接收方控制：

- **RTS（Request To Send）**：由发送方控制，用于通知接收方自己是否准备好发送数据。
- **CTS（Clear To Send）**：由接收方控制，用于通知发送方自己是否准备好接收数据。

通过这两条信号线的交互，发送方和接收方可以动态调整数据传输的节奏，避免数据溢出或丢失。

---

##### 2. RTS/CTS 的工作流程

以下是RTS/CTS硬件流控的典型工作流程：
###### 发送方（Transmitter）的行为：

1. **准备发送数据**：
    - 发送方在发送数据之前，会检查CTS信号的状态。
    - 如果CTS为低电平（表示接收方准备好接收数据），发送方开始发送数据。
    - 如果CTS为高电平（表示接收方未准备好），发送方暂停发送，等待CTS变为低电平。
2. **控制RTS信号**：
    - 发送方通过RTS信号通知接收方自己的状态。
    - 当发送方准备好发送数据时，将RTS置为低电平。
    - 当发送方无法继续发送数据（例如缓冲区满），将RTS置为高电平。

###### 接收方（Receiver）的行为：

1. **准备接收数据**：
    - 接收方通过CTS信号通知发送方自己的状态。
    - 当接收方准备好接收数据时，将CTS置为低电平。
    - 当接收方的缓冲区接近满时，将CTS置为高电平，通知发送方暂停发送。
2. **处理RTS信号**：
    - 接收方会监控发送方的RTS信号。
    - 如果RTS为高电平（表示发送方未准备好），接收方会暂停接收数据。

---

##### 3. RTS/CTS 的信号电平逻辑

- **RTS信号**：
    - 低电平（0）：发送方准备好发送数据。
    - 高电平（1）：发送方未准备好发送数据。
- **CTS信号**：
    - 低电平（0）：接收方准备好接收数据。
    - 高电平（1）：接收方未准备好接收数据。

---

##### 4. RTS/CTS 的硬件连接

在硬件连接中，RTS和CTS信号线需要交叉连接：
- 发送方的RTS信号连接到接收方的CTS信号。
- 接收方的RTS信号连接到发送方的CTS信号。

例如:
- 设备A的RTS连接到设备B的CTS。
- 设备B的RTS连接到设备A的CTS。

---

##### 5. RTS/CTS 的优点

- **高效性**：硬件流控的响应速度比软件流控快，适合高速数据传输。
- **可靠性**：通过硬件信号直接控制，避免了软件流控中字符识别的延迟和错误。
- **实时性**：能够动态调整数据传输，避免缓冲区溢出。

---

##### 6. RTS/CTS 的缺点

- **需要额外信号线**：RTS和CTS需要额外的物理引脚和连接线，增加了硬件复杂度。
- **硬件支持**：并非所有UART设备都支持RTS/CTS硬件流控。

---

##### 7. RTS/CTS 的应用场景

RTS/CTS硬件流控常用于以下场景：

- **高速数据传输**：如调制解调器、工业通信等。
- **缓冲区有限的设备**：如嵌入式系统、微控制器等。
- **长距离通信**：如RS-232通信中，用于防止数据丢失。

---

##### 8. RTS/CTS 的配置

在使用RTS/CTS硬件流控时，需要在UART配置中启用相应的功能。以下是一些常见的配置步骤：

1. **启用硬件流控**：
    - 在UART初始化时，设置硬件流控模式（例如，在STM32中配置`USART_HardwareFlowControl_RTS_CTS`）。
2. **连接信号线**：
    - 确保RTS和CTS信号线正确连接。
3. **设置缓冲区阈值**：
    - 根据接收方缓冲区的容量，设置合适的CTS触发条件（例如，当缓冲区占用率达到80%时，CTS置为高电平）。

---

##### 9. 示例代码（以STM32为例）

以下是STM32微控制器中启用RTS/CTS硬件流控的示例代码：
```c
#include "stm32f4xx.h"

void UART_Init(void) {
    // 启用UART和GPIO时钟
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);

    // 配置UART引脚（TX: PA9, RX: PA10, RTS: PA12, CTS: PA11）
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource9, GPIO_AF_USART1);
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource10, GPIO_AF_USART1);
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource12, GPIO_AF_USART1);
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource11, GPIO_AF_USART1);

    GPIO_InitTypeDef GPIO_InitStruct;
    GPIO_InitStruct.GPIO_Pin = GPIO_Pin_9 | GPIO_Pin_10 | GPIO_Pin_12 | GPIO_Pin_11;
    GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AF;
    GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStruct.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_UP;
    GPIO_Init(GPIOA, &GPIO_InitStruct);

    // 配置UART参数
    USART_InitTypeDef USART_InitStruct;
    USART_InitStruct.USART_BaudRate = 115200;
    USART_InitStruct.USART_WordLength = USART_WordLength_8b;
    USART_InitStruct.USART_StopBits = USART_StopBits_1;
    USART_InitStruct.USART_Parity = USART_Parity_No;
    USART_InitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_RTS_CTS;
    USART_InitStruct.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
    USART_Init(USART1, &USART_InitStruct);

    // 启用UART
    USART_Cmd(USART1, ENABLE);
}

```

---
###
---
### UART DMA 接口

相关寄存器：UARTDMACR
#### 接收端

- UARTRXDMASREQ
	- Single REQ：单字符 DMA 请求；
	- 对于接收操作，一个字符最多由 12 （8+4，数据位和错误位）位组成；
	- 当接收 FIFO 中至少包含一个字符时，此信号有效。
- UARTRXDMABREQ
	- Brust REQ：突发 DMA 请求；
	- ==当接收 FIFO 中字符数量超过水线时，该信号有效==。
- UARTRXDMACLR
	- DMA 请求清除，DMA 控制器发出以清除接受请求信号；
	- ==如果请求了 DMA 突发传输，则在突发传输的最后一个数据传输期间发出清除信号。==
#### 发送端

- UARTTXDMASREQ
	- Single REQ：单字符 DMA 请求；
	- 对于发送操作，一个字符组多由 8 位（只有数据位）组成；
	- 当发送 FIFO 中至少有一个空位时，此信号有效。
- UARTTXDMABREQ
	- Brust REQ：突发 DMA 请求；
	- ==当发送 FIFO 中字符数量低于水线时，该信号有效==。
- UARTTXDMACLR
	- DMA 请求清除，由 DMA 控制器发出以清除传输请求信号；
	- ==如果请求了 DMA 突发传输，则在突发传输的最后一个数据传输期间发出清除信号==。

---

### Interrupts

UART 共有 11 个掩码使能的中断，可以组合成五个中断和一个总中断输出。通过中断屏蔽设置/清除 UARTIMSC 寄存器的屏蔽位来启用（相应的屏蔽位设置高电平）和禁用各个中断。
- UARTRXINTR
- UARTTXINTR
- UARTRTINTR：The receive timeout Interrupt，超时中断。
	- 当接收 FIFO 不为空，且在一个 32-bit 周期内没有接收到更多数据时，此中断置位。
	- 当读取所有数据（或通过读取保持寄存器）使 FIFO 变空，或者想中断清除寄存器的相应位写 1 。
- UARTMSINTR：The modern status Interrupt。所有单独调制解调器状态信号的组合中断
	- UARTRIINTR
	- UARTCTSINTR
	- UARTDCDINTR
	- UARTDSRINTR
- UARTEINTR：接受数据出现错误，会触发此中断；
	- UARTOEINTR：overrun error，数据溢出错误；
	- UARTBEINTR：a break in the reception，接收中断；
	- UARTPEINTR：a parity error in the received character，在接收到字符时出现一个奇偶校验错误；
	- UARTFEINTR：a framing error in the received character，在接收字符时出现一个帧错误；
- UARTINTR：中断汇总后输出的一个 1bit 中断信号；

UARTRXINTR 和 UARTTXINTR 与状态中断分离，可以根据 FIFO 触发级别来读取或写入数据。
#### UARTRXINTR
- 如果使用 FIFO 且接收 FIFO 大于水线，此中断将置为高电平。当接收 FIFO 读取数据直到低于水线或者通过清除中断来清除接收中断；
- 如果禁用 FIFO（变成了深度为 1）且接收到的数据已填满，此中断将置为高电平。通过对接收 FIFO 进行读取操作或通过中断来清除接收中断；

#### UARTTXINTR
- 如果使用 FIFO 且发送 FIFO 低于水线，此中断将置为高电平。当发送 FIFO 写入数据，直到高于水线或者通过清除中断来清除发送中断；
- 如果禁用 FIFO（变成了深度为 1）且发送器的单个存储位置没有数据，此中断将置为高电平。通过对发送 FIFO 进行写操作或通过中断来清除接收中断；

# 名词
- CTS：Clear To Send，清楚发送；
- DCD：Data Carrier Detect，负载数据检测；
- DSR：Data Set Ready，数据准备就绪；
- RI：Ring Indicator，环形指示器；
- RTS：Request To Send，请求发送；
- DTR：Data Terminal Ready，数据终端就绪；
- DTE：Data Terminal Equipment，数据终端设备；
- DCE：Data Communication Equipment，数据通信设备；
- PEN：Parity enable，奇偶校验位使能位；
- SPS：Stick Parity Select，奇偶校验位检查方式（检查0，还是检查1）；
- EPS：Even Parity Select，偶校验选择使能位；



# QA
- [ ] water level，水印：？