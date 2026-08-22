---
aliases:
  - uart
Done:
tags:
  - SoC
  - todo
---
## Deepseek 推荐学习计划
### 一、学习计划（建议6-8周）

---

#### **阶段1：理论基础（1-2周）**
1. **UART协议核心**
    - [x] 异步通信原理（无时钟同步机制）
    - [x] 数据帧结构（起始位/数据位/奇偶校验/停止位）
    - [x] 波特率计算与误差容忍度（重点掌握±2%规则）
    - [x] 流量控制机制（RTS/CTS硬件流控）
2. **数字IC设计基础**
    - 同步电路设计原则
    - 跨时钟域处理（CDC）技术：两级触发器/握手协议
    - FIFO设计原理（深度计算、空满标志生成）
**推荐实验**：用Excel计算不同波特率下的时钟分频系数

---

#### **阶段2：RTL设计与验证（2-3周）**
1. **UART模块分解设计**
    - 发送模块（TX）：
        - 并行转串行处理
        - 波特率时钟生成（BRG模块）
        - 状态机设计（IDLE/START/DATA/PARITY/STOP）
    - 接收模块（RX）：
        - 过采样技术（16x采样时钟）
        - 起始位检测（多数表决算法）
        - 数据恢复中点采样
2. **验证方法**
    - 自验证Testbench构建
    - 覆盖率驱动验证（功能覆盖率/断言覆盖率）
    - 边界条件测试（极值波特率/错误注入）
**实战项目**：实现支持自适应波特率检测的UART接收机

---

#### **阶段3：系统集成（1-2周）**
1. **SoC集成技术**
    - APB/AXI总线接口设计
    - 寄存器配置空间规划（波特率寄存器/控制寄存器/状态寄存器）
    - 中断机制实现（接收完成中断/发送空中断）
2. **时序收敛**
    - 建立/保持时间分析
    - 关键路径优化（波特率时钟路径）
    - 门级仿真注意事项

**进阶课题**：设计支持DMA传输的UART控制器

---

#### **阶段4：项目实战（2周）**
1. **FPGA验证平台**
    - 搭建PC-FPGA双向通信系统
    - 使用SignalTap进行实时调试
    - 眼图测试（使用示波器观测信号质量）
2. **ASIC设计流程**
    - 综合约束编写（波特率时钟约束组）
    - DFT考虑（扫描链插入）
    - 后仿真实例（SDF反标）

---

### 二、推荐资料清单

---

#### **核心教材**

1. 《FPGA Prototyping by Verilog Examples》- Pong P. Chu（第14章UART实现）
2. 《Advanced Chip Design》- Kushagra Vaid（第5章接口设计）
3. 《The Designer's Guide to Verilog AMS》- Ken Kundert（混合信号验证）

#### **实践工具**

1. **EDA工具**：
    - 仿真：Modelsim/VCS+Verdi
    - 综合：DC/Genus
    - FPGA：Vivado Quartus
2. **调试工具**：
    - 串口调试助手（Teraterm/PuTTY）
    - 逻辑分析仪（Saleae/Sigrok）
#### **开源资源**

1. **参考设计**：
    - OpenCores UART项目（Verilog实现）
    - RISC-V SoC中的UART实现（PULP项目）
2. **验证IP**：
    - UVM验证框架（VIPT验证方法学）
    - Cocotb验证框架（Python-based）

#### **技术文档**

1. 16550 UART规格书（工业标准参考）
2. ARM PrimeCell UART (PL011)技术参考手册
3. PCI Express UART IP核设计文档（商业IP参考）

---

### 三、学习建议

1. **波形分析**：使用Verdi/WaveDrom绘制并分析典型通信场景波形
    
2. **代码重构**：尝试用不同架构实现（状态机 vs 移位寄存器）
    
3. **标准对标**：对比16550 UART功能差异
    
4. **协议扩展**：研究UART变种（单线半双工/RS485差分）
    

建议每周进行设计评审（可结对编程），重点培养模块划分能力和验证思维。进阶可研究UART在汽车电子（LIN总线）和物联网设备中的特殊应用场景。**


## TODO
### book & manual 
- [x] [[FPGA Prototyping By Verilog Examples.pdf]]
### pro
- [x] 查看 tinyriscv uart使用：代码简单可以学习 uart 基本功能，数据转换；
- [-] [PUPL](https://github.com/pulp-platform/pulpino)：流片项目，更加标准；--- uart 只实现了基本功能；