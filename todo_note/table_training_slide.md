# Table（硬件表项）入门培训 

---

## 1. 什么是"表（Table）"？

--

在数字芯片中，Table 是核心数据结构的硬件载体，用于存储配置信息、查找规则或中间结果。 <!-- element class="fragment" -->

--

```
          Input Key (Index)
                |
                v
        +---------------+
        |   Table       |
        |  +---+---+    |
        |  | 0 | A |    |
        |  +---+---+    |
        |  | 1 | B |    |
        |  +---+---+    |
        +-------+-------+
                |
                v
      Return Data (Result)
```

---

## 2. 存储类型

---

### Step 1：最基本的实现 — Reg Table

问题： “芯片里有一个表，只需要存 8 条规则，每条 10 bit。你会怎么实现它？” <!-- element class="fragment" -->

解答： 用最基本的 D 触发器（Flip-Flop） 搭一个存储阵列，即 Reg Table。 <!-- element class="fragment" -->

--

```
  Reg Storage Cell (D Flip-Flop)
  +----------------------------+
  |   D ------+---- Q          |
  |  CLK -----+                |
  |  RST -----+                |
  |  ~20-24 Transistors        |
  +----------------------------+
```

--

Reg Table 特点：

| 特性       | 说明                                                |
| :------- | :------------------------------------------------ |
| **查表延迟** | 1-cycle，无额外校验延迟 <!-- element class="fragment" --> |
| **面积效率** | 小容量场景尚可，大容量场景差 <!-- element class="fragment" -->  |
| **校验保护** | 通常无需校验 <!-- element class="fragment" -->          |
| **写操作**  | 可逐 bit 独立更新 <!-- element class="fragment" -->     |

---

### Step 2：SRAM

问题： “现在需求变了，表需要存 100K 条规则。刚才你用的 Reg 方案，现在还好吗？” <!-- element class="fragment" -->

思考后果：<!-- element class="fragment" -->

--

| 问题       | 后果                                                                               |
| :------- | :------------------------------------------------------------------------------- |
| **面积失控** | Reg 每 bit 约 20-24 个晶体管，100K×64bit → 近 1.5 亿晶体管 <!-- element class="fragment" --> |
| **功耗爆炸** | 每个时钟周期所有 Reg 同时翻转，动态功耗不可接受 <!-- element class="fragment" -->                     |
| **布局拥塞** | Reg 分散在逻辑区域，大量 Reg 会导致后端布局布线困难 <!-- element class="fragment" -->                 |

--

 SRAM： 存储单元使用 **6T**，面积约为 Reg 的 **1/3** [^1] <!-- element class="fragment" -->

```
  SRAM Storage Cell (6T Structure)
  +------------------------------+
  |          VDD                 |
  |       +---+---+              |
  |       +---+---+              |
  |       +---+---+              |
  |          GND                 |
  |      ~6 Transistors          |
  +------------------------------+
```

--

**项目经验规则：** 

| 容量范围     | 推荐媒介          | 核心理由                                                |
| :------- | :------------ | :-------------------------------------------------- |
| ≤ **2K** | **Reg Table** | 硬性规则，Reg 面积尚可接受<!-- element class="fragment" -->    |
| < **4K** | **Reg Table** | 实际项目推荐，Reg 延迟优势更关键<!-- element class="fragment" --> |
| > **2K** | **SRAM**      | 面积优势开始显现<!-- element class="fragment" -->           |
| > **4K** | **SRAM**      | 建议批量使用 SRAM<!-- element class="fragment" -->        |

---

### Step 3： SRAM 端口类型

-- 

问题： “现在业务流水线和软件配置都要同时访问这张表，一个表只有一个接口，怎么办？” <!-- element class="fragment" -->

--

SRAM 端口类型对比：

| 类型        |      端口数       | 典型场景   | 优缺点          |
| :-------- | :------------: | :----- | :----------- |
| **SPRAM** |    1R 或 1W     | 单访问源表  | 面积最小，功耗最低    |
| **TPRAM** |    1R + 1W     | 业务读、写表 | 读写可同时进行，面积适中 |
| **DPRAM** | 2R 或 2W 或 1R1W | 高并发场景  | 面积最大，灵活度最高   |

---

### Step 4：特殊需求 — 内容匹配 vs. 地址匹配

--

问题： “输入的是数据，想得到的是匹配结果。能直接用 SRAM 吗？” <!-- element class="fragment" -->

思考 SRAM 的局限性： <!-- element class="fragment" -->

- SRAM 是“你给我地址，我返回数据” <!-- element class="fragment" -->

- 这里需要的是“你给我数据，我返回是否匹配” <!-- element class="fragment" -->


--

CAM： Content Addressable Memory，输入数据，并行比较所有条目，返回匹配结果。只能做**精确匹配**。 

```
          +---------------+
  Key --->|  CAM Array    |
          |  +---+---+    |
          |  | A | 1 |    |
          |  +---+---+    |
          |  | B | 0 |    |
          |  +---+---+    |
          |  | C | 1 |    |
          |  +---+---+    |
          +-------+-------+
                  v
          Match / Mismatch
```

---

### Step 5：模糊匹配需求

-- 

问题： “ACL 规则中有‘允许 192.168.1.0/24’（前 24 位固定，后 8 位任意），CAM 能实现吗？” <!-- element class="fragment" -->

发现： CAM 只能精确匹配，无法处理 X（Don't Care）状态。 <!-- element class="fragment" -->

--

 TCAM： 每个 bit 可存三种状态：`0`、`1`、`X`。内部由 **Data 阵列 + Mask 阵列** 实现。 <!-- element class="fragment" -->

```
  TCAM Bit Entry
  +---------------------+
  |  Data=0, Mask=0 → 0 |
  |  Data=1, Mask=0 → 1 |
  |  Data=X, Mask=1 → X |  ← Don't Care
  |  Data=1, Mask=1 →   |  ← Prohibited
  +---------------------+
```

--

TCAM 的工程代价：

- 面积大：每 bit 约 16 个晶体管（vs SRAM 6T） <!-- element class="fragment" -->
- 功耗高：并行比较导致大电流 <!-- element class="fragment" -->
- 需要 ECC 保护：Data/Mask 双阵列都需校验 <!-- element class="fragment" -->

---

### Step 1-5 总结：存储类型速查表

--

| 需求场景           | 推荐媒介            | 核心理由          |
| :------------- | :-------------- | :------------ |
| 小容量（< 2K），延迟敏感 | **Reg Table**   | 1-cycle，无校验开销 |
| 大容量（> 4K），精确匹配 | **SRAM**        | 面积最优，ECC 保护   |
| 多访问源共享         | **TPRAM / 仲裁器** | 读写分离或时分复用     |
| 内容匹配，无通配符      | **CAM**         | 并行内容查找        |
| 内容匹配，需要通配符     | **TCAM**        | 唯一支持模糊匹配的介质   |

---

## 3. 功能专题

--

### 3.1 仲裁器：当端口数 > 2 时

问题： “你设计的 SRAM 表只有一个物理接口，但业务查表、CSR 配置、ECC 巡检三个源都要访问它。同一时刻只有一个源能用这个接口，怎么办？” <!-- element class="fragment" -->

--

仲裁器： 

```
         Source A (Lookup)
         Source B (CSR Config)
         Source C (ECC Writeback)
                |
                v
        +---------------+
        |   Arbiter     |
        | (Priority)    |
        +-------+-------+
                |
                v
           SRAM / TCAM
```

--

仲裁优先级（7000N策略）：

| 优先级 | 源        | 延迟容忍度  |
| :-: | :------- | :----- |
| 最高  | ECC 硬件回写 | 不可等待   |
|  中  | 业务查表     | 可等待数周期 |
| 最低  | CSR 配置   | 完全容忍   |

---

### 3.2 当单块 SRAM 规格过大

问题： “现在有一张深 32K 的 SRAM 表，单块 SRAM IP 不支持这么深的定制。该怎么办？” <!-- element class="fragment" -->


--

解决方案：按深度拆分为多个 Bank 

```
  Address ---+---+---+---+---+
             |B0|B1|B2|B3|      ← Bank Select (addr[high])
             +---+---+---+---+
               |   |   |   |
               v   v   v   v
            +-+ +-+ +-+ +-+
            | | | | | | | |     ← 4 SRAM Banks
            +-+ +-+ +-+ +-+
              Only selected Bank activated
```

--

Bank 拆分的收益：

| 收益维度       | 说明                                                   |
| :--------- | :--------------------------------------------------- |
| **绕开IP限制** | 突破单块 SRAM 的深度/宽度上限 <!-- element class="fragment" --> |
| **降低动态功耗** | 每次操作仅激活目标 Bank <!-- element class="fragment" -->     |
| **提升工作频率** | 更小的 Bank 尺寸缩短位线长度 <!-- element class="fragment" -->  |
| **提升访问带宽** | 不同 Bank 可并行响应请求 <!-- element class="fragment" -->    |

--

地址映射策略： 

| 方案       | 说明             | 适用场景                                     |
| :------- | :------------- | :--------------------------------------- |
| **低位交叉** | 用地址低位选择 Bank   | 顺序流式访问 <!-- element class="fragment" --> |
| **高位交叉** | 用地址高位选择 Bank   | 分区管理 <!-- element class="fragment" -->   |
| **哈希映射** | 多位异或生成 Bank 选择 | 随机查表 <!-- element class="fragment" -->   |

---

## 4. 安全与可靠性专题

--

### 4.0 校验保护方式对比

问题： “为什么有些表用奇偶校验，而另一些表用 ECC？” <!-- element class="fragment" -->

--

| 对比维度     | 奇偶校验              | ECC                                                          |
| :------- | :---------------- | :----------------------------------------------------------- |
| **检测能力** | 仅检测奇数位错误          | 可纠正1bit错误，检测2bit错误（SEC-DED）<!-- element class="fragment" --> |
| **纠正能力** | 无，错误不可恢复          | 单比特自动纠正，双比特上报<!-- element class="fragment" -->               |
| **硬件开销** | 每字节/字1bit校验位，逻辑简单 | 校验位更多，硬件复杂度更高<!-- element class="fragment" -->               |

--

| 对比维度     | 奇偶校验             | ECC                                                           |
| :------- | :--------------- | :------------------------------------------------------------ |
| **时序影响** | **几乎无影响**，纯异或树实现 | 引入额外延迟，是SRAM查表3-cycle的主要原因之一<!-- element class="fragment" --> |
| **恢复策略** | 上报后需软件重新配置整表     | CE场景硬件自动纠正+回写，UE场景触发高级别中断<!-- element class="fragment" -->    |
| **适用场景** | 寄存器表或可软件重新配置的表项  | 数据不可丢失的关键表项<!-- element class="fragment" -->                  |

--

**项目实践经验：**

- 奇偶校验：适用于寄存器表或可通过软件重新配置的表项。出错时软件通过 CSR 重配整张表。 <!-- element class="fragment" -->
- ECC：适用于SRAM表项，数据是业务运行的直接依赖，硬件自动纠错确保业务不中断。 <!-- element class="fragment" -->
- 举例：在8002项目中，Port表使用ECC保护，其余表使用奇偶校验。 <!-- element class="fragment" -->

---

### 4.1 SRAM ECC 校验

--

SRAM 在先进工艺下容易受粒子撞击导致数据翻转（SEU），需要 ECC 保护。 <!-- element class="fragment" -->

- ECC 校验逻辑在 SRAM IP 外部实现，通过 Wrapper 封装 <!-- element class="fragment" -->
- 校验延迟是 SRAM 查表 3-cycle 的主要原因之一 <!-- element class="fragment" -->
- 1bit 错误 → 硬件自动纠正 + 回写 + 上报错误 Bank 号 <!-- element class="fragment" -->
- 2bit 错误 → 触发高级别中断，等待软件介入 <!-- element class="fragment" -->



---

## 5. 项目避坑经验

1. 小表不要强行定制 SRAM：容量 < 2K 时，SRAM 相对 Reg 无面积优势，直接用 Reg 更稳妥<!-- element class="fragment" -->
2. SRAM 必配校验：这是芯片稳定性的基本保障<!-- element class="fragment" -->
3. TCAM 编码安全：软件需绝对避免写入 Data=1, Mask=1 的禁止编码<!-- element class="fragment" -->
4. 地址合法性：读写表地址不能超过规格深度，超限访问可能返回 X 态<!-- element class="fragment" -->
5. 初始化：所有 Table 上电后需软件初始化，完成前读返回 0<!-- element class="fragment" -->


---

#### Sources
[^1]: [[linear table.smm]]
[^2]: [[linear_table]]
[^3]: [[TCAM]]
[^4]: [[TCAM_Data、Mask 双阵列架构]]
[^5]: [[TCAM_ECC校验实现方案]]
[^6]: [[致 TCAM IP Vendor 咨询问题]]
[^7]: [[tcam 多端口评审]]
[^8]: [[SRAM_Bank经验记录]]