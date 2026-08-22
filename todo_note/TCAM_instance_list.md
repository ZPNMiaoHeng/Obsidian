#7000N #tcam 

根据我们之前的讨论，总结如下：

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

### 电压角选择：为什么 SSG 配 0.72V、FF 配 0.88V

> 说明：手册中的 **SS** 对应签核时的 **SSG（Slow-Slow Global）** 角，这里统一用 SSG 表示。

#### 电压范围来源

0.72V 与 0.88V 对应 **0.8V 标称电压（Vnom）±10%** 的供电范围：

| 电压点 | 计算 | 含义 |
|:---:|:---|:---|
| 0.72V | 0.8V × 0.9 | Vmin，最低工作电压 |
| 0.80V | 0.8V × 1.0 | Vnom，标称工作电压 |
| 0.88V | 0.8V × 1.1 | Vmax，最高工作电压 |

#### 为什么 SSG 配 Vmin（0.72V）？

**SSG 用于验证 Setup 时序**（数据到达太晚，采不到）。电路延迟与电压强负相关：

$$\text{延时} \propto \frac{V_{DD}}{(V_{DD}-V_{th})^\alpha}$$

- 电压越低 → 晶体管驱动电流越小 → 门延迟越大；
- 慢工艺（SS）本来延迟就大，再叠加低电压，延迟进一步恶化；
- 因此 **SSG + 0.72V + 高温** = Setup 最坏情况。

> 如果 SSG 配 0.88V，高电压会把慢工艺"补偿"回来，该角就失去意义了。

#### 为什么 FF 配 Vmax（0.88V）？

**FF 用于验证 Hold 时序**（数据变化太快，被过早采样导致竞态）。同样基于上述延迟公式：

- 电压越高 → 晶体管翻转越快 → 数据到达时间越早；
- 快工艺（FF）本来就快，再叠加高电压，数据到达进一步提前；
- 因此 **FF + 0.88V + 低温** = Hold 最坏情况。

> 如果 FF 配 0.72V，低电压会把快工艺"拖慢"，Hold 风险反而被掩盖。

#### 小结

| 工艺角 | 验证目标 | 配的电压 | 原因 |
|:---:|:---|:---:|:---|
| **SSG** | Setup 收敛（最慢路径） | **0.72V（Vmin）** | 低电压放大慢工艺延迟，得到最坏 setup |
| **FF** | Hold 收敛（最快路径） | **0.88V（Vmax）** | 高电压放大快工艺速度，得到最坏 hold |
| **TT** | 典型功能/功耗 | 0.80V（Vnom） | 标称条件下的代表性行为 |

本质上，这是用"**最坏组合**"的思路覆盖 (Process, Voltage, Temperature) 三维工艺空间：每个工艺角只在能使它成为最严苛工况的那个电压点做签核，从而用有限的仿真次数覆盖整个工作边界。

### 对应到您的表格

在 [[TCAM_instance_list]] 表格中：
- **corner list** 列：填写 **TT、FF、SS、FS、SF** 这五种工艺角[^2]；
- **corner signoff** 列：填写该 IP 实例在每种 corner 下是否通过签核，通常 Vendor 会在手册中给出每个 corner 下支持的最大频率或时序裕量[^1]。

结合 Vendor 已确认该 IP 支持 **930MHz / 660MHz** 两个频点，这五种 corner 下的验证数据，正是用来支撑该频点下 IP 时序裕量满足要求这一结论的[^2]。

- ![9a5daaf231af8bcc8535c14b19bf1781](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/9a5daaf231af8bcc8535c14b19bf1781.png)
- ![2 TCAM instance list](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/2-TCAM_instance_list.png)

#### Sources
[^1]: [[What_is_a_corner_list@20260812_144156]]
[^2]: [[TCAM_instance_list]]

---