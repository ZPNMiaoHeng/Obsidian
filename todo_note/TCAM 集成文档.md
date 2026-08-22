#7000N #tcam 
## 模块信息

- 模块名：`TCAM_TOP`
- 源文件：`asic/design_code/common/tcam/src/tcam_top.v`
- filelist：已合并至 `common.f`

---

## 配置说明

- 复位后，TCAM 需**先下发清除信号**，否则处于保护状态；此时读操作有效，但读数据为 0。
- TCAM 读写数据格式要求：![[2-TCAM 集成文档.png]]

---

## 参数配置说明

| 参数 | 默认值 | 含义 | 说明/约束 |
| --- | --- | --- | --- |
| `TCAM_AW_WIDTH` | 9 | 字地址位宽 | 每个 bank 内条目数 = `2^AW` |
| `TCAM_DATA_WIDTH` | 69 | 表项数据位宽（含有效位） | 约定 **din[0] 为表项有效标志**，实际数据位 = `DATA_WIDTH - 1`；ECC 覆盖全部 `DATA_WIDTH` bit |
| `CSR_RECEIVER_MULTICAST_ADDR` | 12'hfff | CSR 链组播地址 | 链上节点接收判据之一 |
| `CSR_RECEIVER_BROADCAST_ADDR` | 12'hfff | CSR 链广播地址 | 链上节点接收判据之一 |

---

## 例化示例

### 换规格只需改参数（例：1K 条目 × 72 bit，单 bank）

```verilog
TCAM_TOP #(
    .TCAM_AW_WIDTH               (10),       // 1024 entry，对应表深地址
    .TCAM_DATA_WIDTH             (72)        // 71 bit 数据 + 1 bit 有效位，对应表数据位宽
    // 其余参数保持默认
) u_tcam_1kx72 ( ... );