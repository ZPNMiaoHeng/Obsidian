---
epoch: 1786516916141
modelKey: "deepseek-v4-flash|deepseek"
topic: "What is a corner list"



tags:
  - copilot-conversation
---

**user**: corner list 是什么呢？
[Context: Notes: IC/Reference/Manuals/TMTCAMS012AAA_Specification_V0.1.pdf]
[Timestamp: 2026/08/12 14:41:56]

**ai**: 根据目前提供的笔记内容，没有找到 **corner list** 的明确定义。在 [[TCAM_instance_list]] 中看到一个表格，其中有“corner list”和“corner signoff”两列，但这两列目前都是空的，也没有相关的解释文字[^1]。

如果你能提供 TCAM 规格书（如 `TMTCAMS012AAA_Specification_V0.1.pdf`）中关于 corner list 的具体段落，我可以帮你进一步解读。从名称上猜测，它可能指 TCAM 在不同工艺角（PVT corner）下的签核（signoff）列表，但这需要更多上下文来确认。

#### Sources
[^1]: [[TCAM_instance_list]]
[Timestamp: 2026/08/12 14:42:07]

**user**: 指 TCAM 在不同工艺角（PVT corner）下的签核（signoff）列表。这两个是什么？我不太了解，vendor需要这些信息
[Context: Notes: IC/Reference/Manuals/TMTCAMS012AAA_Specification_V0.1.pdf]
[Timestamp: 2026/08/12 14:45:25]

**ai**: 在您的 [[TCAM_instance_list]] 表格中，**corner list** 和 **corner signoff** 是两列目前为空的字段，Vendor 需要您补充这些信息 [^1]。从 IC 设计流程的通用概念来看：

- **PVT corner**：指 **Process（工艺）、Voltage（电压）、Temperature（温度）** 的极端组合。芯片在不同工艺角下，晶体管速度、阈值电压等参数会不同，例如 "SS/FF/TT" 代表慢/快/典型工艺角。设计验证需要在多个 corner 下进行，确保芯片在所有条件下都能正常工作。
- **Signoff**：指在某个具体 corner 下，完成时序分析、功耗分析、可靠性检查等验证，并确认设计满足所有签核标准（如 setup/hold time 收敛）的过程。只有所有要求的 corner 都 signoff 通过，才能进入流片。

对于 **TCAM IP**，Vendor 需要这些信息是为了确认 IP 实例在您项目的具体 PVT 条件下（比如您之前提及的 930MHz / 660MHz 工作频点）能否满足性能和可靠性要求，并给出对应的签核结果 [^2]。

简单来说：**corner list** 是"需要在哪些工艺角下验证"，**corner signoff** 是"这些工艺角下的验证结果"。如果 Vendor 有模板或要求，可以按他们的格式填写；如果有具体 corner 名称（如 SS/FF、0.72V/0.8V、-40°C/125°C 等）不明确，建议直接向 Vendor 索取清单示例。

#### Sources
[^1]: [[TCAM_instance_list]]
[^2]: [[致 TCAM IP Vendor 咨询问题]]
[Timestamp: 2026/08/12 14:46:03]

**user**: 目前IP 验证手册数据中有这些信息
[Context: Notes: IC/Reference/Manuals/TMTCAMS012AAA_Specification_V0.1.pdf]
[Timestamp: 2026/08/12 15:11:12]

**ai**: 
<errorChunk>400 Failed to deserialize the JSON body into the target type: messages[5]: unknown variant `image_url`, expected `text` at line 1 column 155562</errorChunk>
[Timestamp: 2026/08/12 15:12:49]

**user**: 目前IP 验证手册数据中有 TT、FF、SS、FS、SF这五种
[Context: Notes: IC/Reference/Manuals/TMTCAMS012AAA_Specification_V0.1.pdf]
[Timestamp: 2026/08/12 15:14:24]

**ai**: 明白了，您是想确认 IP 验证手册中给出的这五种工艺角（corner）在 corner list / corner signoff 中的含义和用法。

## 这五种 corner 是什么

在 IC 设计中，工艺角（Process Corner）描述了芯片制造过程中工艺偏差的极端情况。您手册中的 **TT、FF、SS、FS、SF** 是经典的 MOSFET 工艺角组合，分别代表：

| Corner | 含义 | NMOS / PMOS 速度 |
|:---:|:---|:---|
| **TT** | Typical-Typical | 典型 / 典型（标准情况） |
| **FF** | Fast-Fast | 快 / 快（速度最快，功耗最高） |
| **SS** | Slow-Slow | 慢 / 慢（速度最慢，时序最差） |
| **FS** | Fast-Slow | NMOS 快 / PMOS 慢 |
| **SF** | Slow-Fast | NMOS 慢 / PMOS 快 |

- **TT** 通常用于典型功能仿真和功耗评估；
- **SS** 是时序收敛的最差情况（setup 检查重点）；
- **FF** 用于 hold 检查（保持时间最差）和功耗峰值评估；
- **FS/SF** 是介于两者之间的组合，用于覆盖器件不匹配导致的边界情况。

## 对应到您的表格

在 [[TCAM_instance_list]] 中：

- **corner list** 列：就是列出需要验证的工艺角集合，这里可以填 **TT、FF、SS、FS、SF** 这五种；
- **corner signoff** 列：指该 IP 实例在**每个 corner 下是否都通过了签核**（如时序收敛、功耗达标等），通常 vendor 会在手册中给出每个 corner 下支持的最大频率或时序裕量。

结合您之前咨询的结论：Vendor 已确认该 IP 支持 **930MHz / 660MHz** 两个频点，且多家产品已量产 [^1][^2]。因此这五种 corner 下的验证数据，正是用来支撑"930MHz 下 IP 时序裕量满足要求"这一结论的 [^3]。

## 建议

如果您需要向 Vendor 确认具体数据，可以这样提问：

> 请问手册中给出的 TT/FF/SS/FS/SF 五种 corner 下，IP 在 930MHz 和 660MHz 的时序裕量分别是多少？corner list 是否还需要补充电压、温度组合（如 0.72V / -40°C 等）？

这样 Vendor 就能明确您需要的是完整的 PVT corner 清单及对应的签核结果。

#### Sources
[^1]: [[苏州腾芯微电子_IPSOAR--TMTCAMS012AAA]]
[^2]: [[致 TCAM IP Vendor 咨询问题]]
[^3]: [[IPSOAR_Vendor_Conclusion_Summary@20260803_161035]]
[Timestamp: 2026/08/12 15:15:04]

**user**: 总结一下
[Context: Notes: IC/Reference/Manuals/TMTCAMS012AAA_Specification_V0.1.pdf]
[Timestamp: 2026/08/12 15:24:24]

**ai**: 根据我们之前的讨论，总结如下：

## Corner List 与 Corner Signoff

### 是什么

- **corner list**：列出需要在哪些工艺角（PVT corner）下进行验证的清单，即"验证条件的集合"。
- **corner signoff**：IP 实例在每个 corner 下是否通过了签核（如时序收敛、功耗达标）的验证结果，即"验证通过的确认"[^1]。

### PVT Corner 的含义

PVT 指 **Process（工艺）、Voltage（电压）、Temperature（温度）** 的极端组合，用于模拟芯片在不同制造偏差和环境条件下的工作状态[^1]。

### 手册中五种工艺角

您的 IP 验证手册中有 **TT、FF、SS、FS、SF** 五种工艺角，这是经典的 MOSFET 工艺角组合[^2]：

| Corner | 含义 | NMOS / PMOS 速度 | 主要用途 |
|:---:|:---|:---|:---|
| **TT** | Typical-Typical | 典型 / 典型 | 典型功能仿真、功耗评估 |
| **FF** | Fast-Fast | 快 / 快 | Hold 检查、功耗峰值评估 |
| **SS** | Slow-Slow | 慢 / 慢 | Setup 时序收敛（最差情况） |
| **FS** | Fast-Slow | NMOS 快 / PMOS 慢 | 器件不匹配边界情况 |
| **SF** | Slow-Fast | NMOS 慢 / PMOS 快 | 器件不匹配边界情况 |

### 对应到您的表格

在 [[TCAM_instance_list]] 表格中：
- **corner list** 列：填写 **TT、FF、SS、FS、SF** 这五种工艺角[^2]；
- **corner signoff** 列：填写该 IP 实例在每种 corner 下是否通过签核，通常 Vendor 会在手册中给出每个 corner 下支持的最大频率或时序裕量[^1]。

结合 Vendor 已确认该 IP 支持 **930MHz / 660MHz** 两个频点，这五种 corner 下的验证数据，正是用来支撑该频点下 IP 时序裕量满足要求这一结论的[^2]。

#### Sources
[^1]: [[What_is_a_corner_list@20260812_144156]]
[^2]: [[TCAM_instance_list]]
[Timestamp: 2026/08/12 15:24:53]