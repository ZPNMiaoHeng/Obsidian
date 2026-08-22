---
epoch: 1785928352224
modelKey: "deepseek-v4-flash|deepseek"
topic: "对于单 bank 的 Memory，DFT 测试通常依靠 Memory BIST（MBIST） 完成"



tags:
  - copilot-conversation
---

**user**: 如果一个mem一个bank，DFT如何测试呢？
[Context: Notes: Note/Daily/SRAM_Bank经验记录.md]
[Timestamp: 2026/08/05 19:12:32]

**ai**: 对于单 bank 的 Memory，DFT 测试通常依靠 **Memory BIST（MBIST）** 完成，这也是最简单的一种存储测试场景 [^1]。

### 测试方式：单 MBIST 控制器直连

单 bank 下不需要处理 bank 选择、多 bank 并行调度等问题，只需**一个 MBIST 控制器**直接连接唯一的 bank：

- **March 算法遍历**：MBIST 通过 March 算法对存储阵列进行读写遍历，检测 stuck-at、transition、coupling 等故障
- **全地址覆盖**：单 bank 地址空间连续，无 bank 边界问题，测试模式可直接遍历全部地址
- **无配置复杂度**：不需要 bank 级测试调度、跨 bank 数据比对等逻辑

### 相比多 Bank 的优势

多 Bank 拆分时，**每个 Bank 需要独立的 BIST 测试接口和控制器**，这是拆分的代价之一 [^2]。单 bank 只需一套 BIST 接口，面积和 DFT 复杂度均为最低。

### 需要注意的边界情况

- **小容量单 bank**：若深度 < 2K，按工程经验更适合用 Reg Table 实现 [^3]，此时不再走 MBIST，而是通过**扫描链（scan chain）**测试。
- **DFT 网表验证**：DFT 网表回来后需关注 SRAM 读数据 X 态问题——已有案例表明根因可能是 IP 与仿真工具版本编译冲突，规避方法包括调整 SRAM 初始化赋值方式（如从 0 改为 x）[^4]。

#### Sources:

[^1]: [[对于单_bank_的_Memory，DFT_测试通常依靠_Memory_BIST（MBIST）_完成@20260805_191232]]
[^2]: [[后仿+DFT_BUG_NTB-SRAM读数据为x态]]
[^3]: [[7000N测试结果对齐]]
[^4]: [[跨Bank搬移操作周期说明@20260731_114402]]
[^5]: [[Register_TCAM_SRAM_Training@20260728_092042]]
[^6]: [[测试规格]]
[^7]: [[仿真测试.smm]]
[^8]: [[培训思路]]
[^9]: [[SRAM_Bank经验记录]]
[^10]: [[Fabric测试场景.excalidraw]]
[^11]: [[What_is_Standby_Power_Consumption@20260805_094333]]
[^12]: [[NTB 变动 IT 测试点评审]]
[^13]: [[IP EX中波形和测试波形]]
[^14]: [[Latch_memory]]
[^15]: [[NTB 控制寄存器无复位设计，导致 CSR 寄存器产生 X 态]]
[^16]: [[后仿+DFT_BUG_复位cbb输出为x态]]
[Timestamp: 2026/08/05 19:13:14]

**user**: 如果拆分多bank，dft会有什么影响呢？
[Context: Notes: Note/Daily/SRAM_Bank经验记录.md]
[Timestamp: 2026/08/05 19:14:48]

**ai**: 拆分多 Bank 对 DFT 的影响主要体现在**测试电路的面积开销**和**测试复杂度**两个维度：

### 1. BIST 测试电路面积显著增加（核心影响）

- **每个 Bank 需要独立的 BIST 测试接口和控制器** [^1][^2]
- 拆分越多，BIST 逻辑的复制开销越大，进一步推升面积 [^2]
- 单 bank 只需一套 BIST 接口，面积和 DFT 复杂度均为最低 [^1]

这是 Bank 拆分"面积增大三来源"之一（另两个是 Memory 外围电路复制和 PR 间隙开销），且随 Bank 数量**线性增长** [^2]。

### 2. DFT 测试调度与资源配置复杂度上升

拆分多 Bank 后，DFT 需要考虑：

- **测试调度策略**：多 Bank 之间是串行测试（共享一个控制器分时复用）还是并行测试（每 Bank 独立控制器），需要额外的调度/选择逻辑
- **Bank 间数据比对**：跨 Bank 数据比对、故障隔离定位等逻辑比单 Bank 复杂
- **测试向量与地址映射**：需要处理 Bank 选择逻辑，测试地址需要先译码到对应 Bank，验证时需要覆盖 Bank 边界场景

### 3. 设计取舍建议

- **DFT 角度单 bank 最优**：如果没有拆分需求，单 bank 的 DFT 成本最低
- **多 Bank 拆分收益与 DFT 代价需权衡**：Bank 拆分带来的功耗/带宽收益往往大于 DFT 代价，但拆分数不宜过多（N > 4 时负面效应非线性加剧），BIST 复制开销也随之恶化 [^2]

> 工程上，BIST 电路是 Bank 拆分的固定代价之一，评估拆分方案时应将其计入面积预算，并在 Memory Compiler 数据中体现。

#### Sources:

[^1]: [[对于单_bank_的_Memory，DFT_测试通常依靠_Memory_BIST（MBIST）_完成@20260805_191232]]
[^2]: [[后仿+DFT_BUG_NTB-SRAM读数据为x态]]
[^3]: [[SRAM_Bank经验记录]]
[^4]: [[Latch_memory]]
[^5]: [[What_is_Standby_Power_Consumption@20260805_094333]]
[^6]: [[跨Bank搬移操作周期说明@20260731_114402]]
[^7]: [[SD和SLP术语解释@20260724_135039]]
[^8]: [[SRAM 定制规则]]
[^9]: [[Register_TCAM_SRAM_Training@20260728_092042]]
[^10]: [[7000N测试结果对齐]]
[^11]: [[搬移地址判断规则@20260730_154855]]
[^12]: [[培训思路]]
[^13]: [[存储架构]]
[^14]: [[文档优化分析@20260707_170926]]
[^15]: [[Digital_Circuit_Optimization_Analysis@20260713_114511]]
[^16]: [[linear table.smm]]
[^17]: [[TCAM_ECC校验方案@20260713_114511]]
[^18]: [[table_文档]]
[^19]: [[Parity_and_ECC_Protection@20260728_112818]]
[^20]: [[状态图2K语法问题@20260730_150948]]
[Timestamp: 2026/08/05 19:15:34]

**user**: 总结结论
[Context: Notes: Note/Daily/SRAM_Bank经验记录.md]
[Timestamp: 2026/08/05 19:18:03]

**ai**: ## 总结结论

### 单 Bank Memory 的 DFT 测试

- 通过**一个 MBIST 控制器直连**即可完成测试，无需处理 bank 选择、并行调度等逻辑 [^1]
- 使用 March 算法遍历全部地址，覆盖 stuck-at、transition、coupling 等故障 [^1]
- 单 bank 只需一套 BIST 接口，面积和 DFT 复杂度均为最低

### 多 Bank 拆分对 DFT 的影响

**核心影响一：BIST 测试电路面积显著增加**

- 每个 Bank 需要独立的 BIST 测试接口和控制器，拆分越多，复制开销越大 [^1][^2]
- 该代价随 Bank 数量线性增长，与 Memory 外围电路复制、PR 间隙开销共同构成拆分的面积代价 [^2]

**核心影响二：DFT 测试调度与资源配置复杂度上升**

- 需决策多 Bank 串行测试（共享控制器分时复用）还是并行测试（每 Bank 独立控制器）[^1]
- 跨 Bank 数据比对、故障隔离定位逻辑更复杂 [^1]
- 需处理 Bank 选择逻辑，测试地址需先译码到对应 Bank，验证需覆盖 Bank 边界场景 [^1]

### 设计取舍建议

- **DFT 角度单 bank 最优**，若无可拆分需求则成本最低
- Bank 拆分带来的功耗/带宽收益往往大于 DFT 代价，但**拆分数不宜过多（N > 4 时负面效应非线性加剧）**[^1][^2]
- BIST 电路是 Bank 拆分的固定代价，评估拆分方案时应将其计入面积预算 [^1]

> 一句话总结：**单 bank 是 DFT 最优场景；多 bank 拆分的核心 DFT 代价是 BIST 电路复制面积与测试调度复杂度，需在面积预算中显式计入。**

#### Sources
[^1]: [[对于单_bank_的_Memory，DFT_测试通常依靠_Memory_BIST（MBIST）_完成@20260805_191232]]
[^2]: [[What_is_Standby_Power_Consumption@20260805_094333]]
[Timestamp: 2026/08/05 19:18:37]

**user**: 如果一个bank规格超过SRAM IP定制规格，实际bank定制包含多个sram ip，这时候DFT怎么实现呢？
[Context: Notes: Note/Daily/SRAM_Bank经验记录.md]
[Timestamp: 2026/08/05 19:20:08]

**ai**: ## 逻辑 Bank 由多个 SRAM IP 组成的 DFT 实现

这一场景属于"逻辑 Bank 级"与"物理 SRAM macro 级"的映射问题。核心原则是：**DFT 测试的对象是物理 SRAM macro，而非逻辑 Bank**。具体实现如下：

### 1. 每个物理 SRAM macro 独立接入 BIST

- 逻辑 Bank 是由多个物理 SRAM IP 实例拼合而成，每个物理 macro 都需要**独立的 BIST 测试接口**[^1]
- 测试时逐个（或分组并行）对每个物理 macro 跑 March 算法，而不是把整个逻辑 Bank 当作一个整体来测[^1]

### 2. 控制器共享策略

- 若组成逻辑 Bank 的物理 macro 规格一致（均匀规格），BIST 逻辑可以**参数化复用**，一个控制器分时串行调度多个 macro[^2]
- 串行测试：共享一个 MBIST 控制器，依次测试各 macro，面积开销小
- 并行测试：每个 macro 独立控制器，测试时间短但 BIST 电路面积翻倍

### 3. 逻辑地址映射逻辑需要额外覆盖

- 逻辑 Bank 地址需要译码选择对应的物理 macro，这套**地址选择/数据选择逻辑不在 MBIST 覆盖范围内**
- 需要通过 Logic BIST 或功能测试模式，覆盖 Bank 内 macro 选择、数据拼接（宽度扩展时）或深度译码（深度扩展时）的边界场景[^1]

### 4. 关键工程判断

> 逻辑 Bank 内含多少物理 macro，DFT 就按多少个独立存储体来规划 BIST——**物理上不透明，DFT 上不可合并**[^1]。

这也意味着：当一个逻辑 Bank 需要靠多个 SRAM IP 拼合时，其 BIST 开销与多 Bank 拆分类似（每个物理 macro 一份 BIST 接口），评估面积预算时应按物理 macro 数量显式计入[^1]。

#### Sources
[^1]: [[对于单_bank_的_Memory，DFT_测试通常依靠_Memory_BIST（MBIST）_完成@20260805_191232]]
[^2]: [[What_is_Standby_Power_Consumption@20260805_094333]]
[Timestamp: 2026/08/05 19:21:03]

**user**: 那是不是可以理解一个table DFT开销与bank拆分数量关系不大，和实际macro数量相关呢？
[Context: Notes: Note/Daily/SRAM_Bank经验记录.md]
[Timestamp: 2026/08/05 19:22:33]

**ai**: 你的理解**方向正确，但需要精确化**：DFT 开销与 bank 拆分数量本身**无直接关系**，真正决定因素确实是**物理 macro 数量**，但两者在特定场景下会表现重合。

### 精确表述

| 场景 | DFT 开销的决定因素 |
|:-----|:-----------------|
| 一个 bank = 一个 macro | 按 bank 数计（此时 bank 数 = macro 数，两者重合） |
| 一个 bank 内含多个 macro（位宽切片/端口扩展） | 按 macro 数计，与 bank 数无关 |
| 一个 macro 划分子存储区（地址高位译码等效多 bank） | 按物理 macro 数计（共享外围电路，BIST 只需一份）|

核心原则是：**每个物理 SRAM macro 都需要独立的 BIST 测试接口，DFT 按物理上需要独立测试的存储体数量来规划，这个数量就等于 macro 数量** [^1]。

### 两个重要补充

**1. 均匀规格可参数化复用**
若组成 table 的多个 macro 规格一致，BIST 逻辑可参数化复用，一个控制器分时串行调度多个 macro [^1]。此时虽然接口数随 macro 数增长，但控制器逻辑可共享，实际开销小于"逐 macro 独立控制器"。

**2. 面积核算口径**
从存储架构分层看，table → channel → bank 是**逻辑划分**，bank → macro 是**物理实现** [^2]。DFT 关注的是物理层，因此面积核算应看 macro 总量。定制面积公式 `table 定制面积 = bank数量 × SRAM面积` [^3] 中的 SRAM 面积在概念上即对应物理 macro 的实例面积，一个 bank 内含多个 macro 时需按 macro 数折算。

### 一句话结论

> **DFT 开销 ∝ 物理 macro 总数**，而非 bank 逻辑拆分数量。只有当 bank 与 macro 一一对应时，两者才表现等价。

#### Sources:

[^1]: [[对于单_bank_的_Memory，DFT_测试通常依靠_Memory_BIST（MBIST）_完成@20260805_191232]]
[^2]: [[SRAM 定制规则]]
[^3]: [[What_is_Standby_Power_Consumption@20260805_094333]]
[^4]: [[linear table.smm]]
[^5]: [[umctl2 Address Mapper]]
[^6]: [[table_文档]]
[^7]: [[SD和SLP术语解释@20260724_135039]]
[^8]: [[Optimize_Document_Without_Tables@20260629_175140]]
[^9]: [[文档优化分析@20260707_170926]]
[^10]: [[table_training_slide]]
[^11]: [[SRAM_Bank经验记录]]
[^12]: [[Register_TCAM_SRAM_Training@20260728_092042]]
[^13]: [[Parity_and_ECC_Protection@20260728_112818]]
[^14]: [[仿真测试.smm]]
[^15]: [[数字电路设计优化建议@20260331_114741]]
[^16]: [[table公共事务]]
[^17]: [[存储架构]]
[^18]: [[跨Bank搬移操作周期说明@20260731_114402]]
[^19]: [[优化文档@20260529_114036]]
[^20]: [[Table实现方案对齐纪要@20260709_195036]]
[Timestamp: 2026/08/05 19:23:32]

**user**: 总结上述结论，并输出笔记文档
[Context: Notes: Note/Daily/SRAM_Bank经验记录.md]
[Timestamp: 2026/08/05 19:25:24]

**ai**: # DFT 测试开销：物理 Macro 数量驱动模型

#IC

> **核心结论**：DFT 开销 ∝ **物理 macro 总数**，而非 bank 逻辑拆分数量。只有当 bank 与 macro 一一对应时，两者才表现等价。

## 1. 场景一：一个 Bank 一个 Macro（单 Bank）

最简 DFT 场景，通过 **Memory BIST（MBIST）** 一个控制器直连即可完成：

- **March 算法遍历**：检测 stuck-at、transition、coupling 等故障
- **全地址覆盖**：地址空间连续，无 bank 边界问题
- **无配置复杂度**：不需要 bank 级测试调度、跨 bank 数据比对逻辑

> 单 bank 只需一套 BIST 接口，面积和 DFT 复杂度均为最低 [^1]。

## 2. 场景二：逻辑 Bank 拆分为多个物理 Bank

拆分多 Bank 对 DFT 的代价集中在两个维度：

### 维度 A：BIST 测试电路面积显著增加

- 每个 Bank 需要**独立的 BIST 测试接口和控制器**，拆分越多复制开销越大
- 该代价随 Bank 数量**线性增长**，是 Bank 拆分"面积增大三来源"之一 [^1]

### 维度 B：DFT 测试调度与资源配置复杂度上升

- **测试调度策略**：串行（共享控制器分时复用）vs 并行（每 Bank 独立控制器）
- **Bank 间数据比对**：跨 Bank 数据比对、故障隔离定位逻辑更复杂
- **测试向量与地址映射**：需处理 Bank 选择逻辑，验证需覆盖 Bank 边界场景 [^1]

## 3. 场景三：一个 Bank 包含多个 SRAM IP（规格超限）

当逻辑 Bank 规格超过 SRAM IP 定制上限，需多个物理 macro 拼合时：

> **核心原则：DFT 测试的对象是物理 SRAM macro，而非逻辑 Bank** [^1]。

- **每个物理 macro 独立接入 BIST**：逐个（或分组并行）跑 March 算法
- **控制器共享策略**：均匀规格可**参数化复用**，一个控制器分时串行调度多个 macro [^1]
  - 串行测试：面积开销小
  - 并行测试：测试时间短但 BIST 面积翻倍
- **逻辑地址映射逻辑额外覆盖**：Bank 内 macro 选择、数据拼接/深度译码边界场景，需通过 Logic BIST 或功能测试模式覆盖 [^1]

### 关键工程判断

> 逻辑 Bank 内含多少物理 macro，DFT 就按多少个独立存储体来规划 BIST——**物理上不透明，DFT 上不可合并** [^1]。

## 4. 统一结论模型

| 场景 | DFT 开销的决定因素 |
|:-----|:-----------------|
| 一个 bank = 一个 macro | 按 bank 数计（bank 数 = macro 数，两者重合）|
| 一个 bank 内含多个 macro | **按 macro 数计，与 bank 数无关** |
| 一个 macro 划分子存储区 | 按物理 macro 数计（共享外围电路，BIST 只需一份）|

### 面积核算口径

从存储架构分层看，table → channel → bank 是**逻辑划分**，bank → macro 是**物理实现**。DFT 关注的是物理层，因此面积核算应看 **macro 总量** [^1]。

## 5. 工程建议

- 评估拆分方案时，BIST 电路开销应**按物理 macro 数量计入面积预算** [^1]
- 实际贡献中，多 Bank 拆分的功耗/带宽收益往往大于 DFT 代价，但**拆分数不宜过多**（N > 4 时负面效应非线性加剧）
- 若组成 table 的 macro 规格一致，优先采用**参数化复用 + 串行调度**策略，控制 BIST 面积开销 [^1]

---

#### Sources

[^1]: [[对于单_bank_的_Memory，DFT_测试通常依靠_Memory_BIST（MBIST）_完成@20260805_191232]]
[Timestamp: 2026/08/05 19:26:08]