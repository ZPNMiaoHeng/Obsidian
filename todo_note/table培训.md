好的，根据你的要求，我将文档中所有示意图的中文标注替换为英文文字，确保格式对齐与版面整洁。

---

# Table（硬件表项）入门培训（英文图示版）

## 1. 培训目的

- 了解芯片设计中"表（Table）"的概念和用途。
- 掌握三种核心存储实现方式：**Reg Table（寄存器表）**、**SRAM Table（静态随机存取存储器表）**、**TCAM（三态内容寻址存储器）** 的基本原理、特点及适用场景。
- 了解项目中的基本设计规则和定制经验，避免后续开发踩坑。

---

## 2. 什么是"表（Table）"？

在数字芯片中，**Table** 是核心数据结构的载体，用于存储芯片运行的配置信息、查找规则或中间结果。它和我们日常编程使用的"数组"或"哈希表"类似。

```
          Input Key (Index)
                │
                ▼
        ┌───────────────┐
        │   Table       │
        │  ┌───┬───┐    │
        │  │ 0 │ A │    │
        │  ├───┼───┤    │
        │  │ 1 │ B │    │
        │  ├───┼───┤    │
        │  │ 2 │ C │    │
        │  └───┴───┘    │
        └───────┬───────┘
                │
                ▼
      Return Data (Result)
```

**核心三要素：**
- **容量（Depth × Width）**：表能存放多少条目，以及每个条目的数据位宽。
- **访问延迟**：从发出查找请求到拿到结果需要的时钟周期数。
- **功耗与面积**：在芯片上物理实现的成本。

---

## 3. Reg Table（寄存器表）

### 3.1 什么是 Reg Table？

Reg Table 就是用基本的 **D 触发器（Flip-Flop）** 搭建出来的存储阵列。

```
  Reg Storage Cell (D Flip-Flop)
  ┌────────────────────────────┐
  │                            │
  │   D ────┬──── Q            │
  │         │                  │
  │  CLK ───┤                  │
  │         │                  │
  │  RST ───┘                  │
  │                            │
  │  ~20-24 Transistors        │
  └────────────────────────────┘
```

### 3.2 核心特点

- **延迟低**：查表延迟固定为 **1 Cycle**，速度极快。
- **访问灵活**：可以任意读写任意比特，非常自由。
- **无校验成本**：通常情况下，Reg Table 不需要复杂的 **ECC** 逻辑来保证数据可靠性。
- **面积劣势**：与 SRAM 相比，同等容量下 Reg Table 的面积要大得多（约 **3倍**）。

### 3.3 什么时候用？——小容量表

**项目中的经验准则：**

- **硬性规则**：容量 ≤ **2K** 时，强制使用 Reg Table。
- **实际参考**：在项目中，通常容量 < **4K** 时，比较推荐使用 Reg Table。

---

## 4. SRAM Table（静态随机存取存储器）

### 4.1 什么是 SRAM？

SRAM 是一种标准的存储单元阵列，由专用的 **SRAM IP 编译器** 生成。

```
  SRAM Storage Cell (6T Structure)
  ┌──────────────────────────────┐
  │                              │
  │          VDD                 │
  │           │                  │
  │       ┌───┴───┐              │
  │       │       │              │
  │       └───┬───┘              │
  │           │                  │
  │       ┌───┴───┐              │
  │       │       │              │
  │       └───┬───┘              │
  │           │                  │
  │          GND                 │
  │                              │
  │      ~6 Transistors          │
  └──────────────────────────────┘
```

### 4.2 核心特点

- **大容量，面积优**：SRAM 是存储大容量数据最经济的硬件实现方式。
- **延迟中等**：查表延迟通常为 **3 Cycles**。
- **结构固定**：SRAM 有固定的物理结构，地址、数据、控制信号必须按照规定时序驱动。
- **需要校验**：SRAM 在先进工艺下容易受 **SEU** 影响，需要 **ECC** 保护。
- **支持写掩码**：SRAM 通常支持 **写掩码**，即可以只更新一个字中的某几个比特。

### 4.3 晶体管级面积对比：SRAM vs Reg

```
Area Ratio = 3 : 1 (Reg : SRAM, same capacity)

  Reg Cell                         SRAM Cell
  ┌──────────────────┐          ┌──────────────┐
  │ D Flip-Flop      │          │   6T SRAM    │
  │ ┌──────────┐     │          │ ┌──┐ ┌──┐   │
  │ │ 20-24    │     │          │ │  │ │  │   │
  │ │ Trans.   │     │          │ └──┘ └──┘   │
  │ └──────────┘     │          │ Cross-Coupled│
  │ Storage+Control  │          │ Latch        │
  └──────────────────┘          └──────────────┘
```

### 4.4 SRAM Bank 拆分与选 Bank 操作

```
  Address ───┬───┬───┬───┬───┐
             │B0│B1│B2│B3│      ← Bank Select (addr[high])
             └─┬─┴─┬─┴─┬─┴─┬─┘
               │   │   │   │
               ▼   ▼   ▼   ▼
            ┌─┐ ┌─┐ ┌─┐ ┌─┐
            │ │ │ │ │ │ │ │     ← 4 SRAM Banks
            └─┘ └─┘ └─┘ └─┘
              Only selected Bank activated
```

- 查表请求到达时，硬件根据查表地址的高位进行译码，生成 Bank 选择信号，仅激活对应的 Bank。
- **未被选中的 Bank 保持休眠状态**，实现动态功耗降低。

**Bank 拆分的收益与代价：**

| Advantage                                | Cost                       |
| ---------------------------------------- | -------------------------- |
| Lower dynamic power (only 1 Bank active) | Slightly larger total area |
| Higher frequency (shorter bitlines)      | Increased leakage power    |
| Bypass IP limits                         | Added Bank-select logic    |

**经验值：** "拆一半"（N=2）通常是效果不错的折中点。

### 4.5 多访问源仲裁

```
         Source A (Lookup)
         Source B (CSR Config)
         Source C (ECC Writeback)
                │
                ▼
        ┌───────────────┐
        │   Arbiter     │
        │ (Priority)    │
        └───────┬───────┘
                │
                ▼
           SRAM Table
```

---

## 5. TCAM（三态内容寻址存储器）

### 5.1 什么是 TCAM？

```
  Normal Memory Lookup:              TCAM Lookup:
  ┌──────────────────┐              ┌──────────────────────┐
  │ Input: Address   │              │ Input: Key (Data)    │
  │  ↓               │              │         ↓            │
  │ SRAM Array       │              │  ┌────────────┐     │
  │  → Return Data   │              │  │ Entry 0    │──┼──→ Hit/Miss
  │    at address    │              │  │[D0|M0]     │     │
  └──────────────────┘              │  ├────────────┤     │
                                    │  │ Entry 1    │──┼──→ Hit/Miss
                                    │  │[D1|M1]     │     │
                                    │  ├────────────┤     │
                                    │  │   ...      │     │
                                    │  ├────────────┤     │
                                    │  │ Entry N-1  │──┼──→ Hit/Miss
                                    │  │[DN-1|MN-1] │     │
                                    │  └────────────┘     │
                                    │ Parallel comparison │
                                    └──────────────────────┘
```

### 5.2 工作原理：Data/Mask 双阵列架构

```
         TCAM Dual-Array Architecture
      ┌────────────────────────────┐
      │   Data Array               │
      │  ┌───┬───┬───┬───┐        │
      │  │ 1 │ 0 │ 1 │ 0 │        │
      │  ├───┼───┼───┼───┤        │
      │  │ 0 │ 1 │ 0 │ 1 │        │
      │  └───┴───┴───┴───┘        │
      │                            │
      │   Mask Array               │
      │  ┌───┬───┬───┬───┐        │
      │  │ 1 │ 0 │ 1 │ 1 │        │
      │  ├───┼───┼───┼───┤        │
      │  │ 0 │ 1 │ 1 │ 0 │        │
      │  └───┴───┴───┴───┘        │
      └────────────────────────────┘
```

编码方式：

| Data | Mask | Meaning | Description |
|:----:|:----:|:--------|:-----------|
| 0 | 0 | **X (Don't Care)** | Ignore during compare |
| 0 | 1 | **0** | Must match 0 |
| 1 | 0 | **1** | Must match 1 |
| 1 | 1 | **Prohibited** | Forbidden state |

匹配逻辑：

```verilog
Match = (Data ^ Key) & Mask;
// Mask=0 → auto-match (ignore this bit)
// Mask=1 → must equal Data
```

### 5.3 Valid Bit

```
  ┌──────────────────────────────────────┐
  │         TCAM Entry Structure         │
  ├──────┬──────────────┬───────────────┤
  │Valid │   Data       │   Mask        │
  │ 1bit │    N bits    │   N bits      │
  ├──────┼──────────────┼───────────────┤
  │  1   │ 1010...      │ 1110...       │
  │  0   │ 0101...      │ 1011...       │  ← Invalid, skip
  │  1   │ 1100...      │ 0111...       │
  └──────┴──────────────┴───────────────┘
```

### 5.4 什么时候用？

```
  Requirement → Recommended Medium
  ┌────────────────────────┬──────────┐
  │ Capacity < 2K, 1-cycle │ Reg Tbl  │
  ├────────────────────────┼──────────┤
  │ Capacity > 4K, exact   │  SRAM    │
  ├────────────────────────┼──────────┤
  │ Wildcard match (ACL)   │  TCAM    │
  ├────────────────────────┼──────────┤
  │ Multi-source shared    │ SRAM M-Port│
  └────────────────────────┴──────────┘
```

### 5.5 多访问源仲裁

```
         Lookup Request
         CSR Config R/W
         ECC Scrub/Writeback
         Data Move/Flush
                │
                ▼
        ┌───────────────┐
        │  TCAM Arbiter │
        │  (serial)     │
        └───────┬───────┘
                │
                ▼
           TCAM IP
```

### 5.6 TCAM ECC 校验：外部实现

```
  +────────────────────────────────────────+
  |           ECC Wrapper (External)        |
  |  ┌──────────────┐  ┌───────────────┐  |
  |  │ ECC Enc/Dec  │  │ Scrub Ctrl    │  |
  |  │ (Data+Mask)  │  │ (FSM)         │  |
  |  └──────┬───────┘  └───────┬───────┘  |
  +─────────┼─────────────────┼───────────+
            │                 │
            ▼                 ▼
    ┌───────┴────────┐  ┌────┴──────┐
    │  TCAM IP       │  │ ECC       │
    │  Data+Mask     │  │ Parity    │
    │  Array         │  │ SRAM      │
    └────────────────┘  └───────────┘
```

**巡检流程：**

```
IDLE → [Timer] → READ_DATA → CHECK_DATA → READ_MASK → CHECK_MASK → ADDR_INC → IDLE
                    ↓ (CE)              ↓ (CE)
                 [WRITE_BACK]        [WRITE_BACK]
```

---

## 6. 总结与关键设计原则

1. **目标导向**：能用 Reg 就不用 SRAM，能用 SRAM 就不用 TCAM。
2. **延迟与流水**：Reg 1-cycle，SRAM 3-cycle，TCAM 搜索 1-2 cycle。
3. **安全第一**：SRAM 必配 ECC，TCAM 避免 Data=1, Mask=1 禁止编码。
4. **初始化**：所有 Table 上电后需初始化，完成前读返回 0。
5. **地址合法性**：读写地址不能超过规格深度。