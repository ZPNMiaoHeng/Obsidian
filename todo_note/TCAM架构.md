#IC 

# TCAM架构

好的，基于已定稿的 [[TCAM_ARB实现方案]]、[[TCAM_ECC校验实现方案]] 和 [[以往项目 TCAM]]，以下是补完后的完整架构图：

```
tcam_wrapper (L1)
│
├── CSR
│   ├── 配置寄存器
│   │   ├── csr_timeout_timer / csr_timeout_pressure_pipeline_en (ARB饿死保护)
│   │   ├── PATROL_CTRL / PATROL_INTERVAL (ECC巡检)
│   │   └── ECC_SRAM_CTRL
│   ├── 中断上报
│   │   ├── int0：CE 信息性中断（硬件已自动纠正，软件记录归档）
│   │   └── int2：UE 致命中断（软件立即响应）
│   ├── 软件键值配置表项
│   └── CSR 状态记录
│
├── TCAM_ECC_FSM ──────────────── [[TCAM_ECC校验实现方案]]
│   ├── 状态流程：IDLE → READ_DATA → CHECK_DATA → READ_MASK → CHECK_MASK → ADDR_INC
│   │                  └─ CE ─► WRITE_BACK_DATA / WRITE_BACK_MASK（硬件自动纠错回写）
│   ├── 请求：ecc_rd_req（巡检读，ARB 最低优先级）
│   └── 请求：ecc_wr_req（回写，ARB 最高优先级）
│
├── ECC_GEN ── 写路径：数据 → 生成校验位 → 写入外部 ECC SRAM
├── ECC_CHK ── 读路径：数据 + 校验位 → 检错 → CE 回写 / UE 上报 int2
│
├── TCAM_ARB ──────────────────── [[TCAM_ARB实现方案]]
│   ├── 请求源（按优先级）：
│   │   ① ecc_wr_req   （ECC 写回，最高优先级）
│   │   ② pl_search_req（流水线查表，默认高于软件）
│   │   ③ csr_req      （软件请求，带饿死保护计数器）
│   │   ④ ecc_rd_req   （巡检读，最低优先级）
│   ├── 调度机制：两层仲裁 + 机会式调度（流水线空拍直接 grant 软件）+ 饱和计数器
│   └── 硬件互锁：move_busy 有效期间，stall 软件请求与巡检读的 grant
│
├── 外层 mux（TCAM 接口选通）
│   ├── 输入 A：ARB grant 输出
│   ├── 输入 B：搬移/清除操作（来自搬移 FSM，不进 ARB 仲裁）
│   └── 优先级语义：ECC 写回无条件抢占；搬移通过 pipeline_conflict 避让流水线
│
├── 搬移 FSM ──────────────────── [[ACL搬移无感实现方案]]
│   ├── move_busy ──► 广播至 ARB（硬件互锁）
│   ├── pipeline_conflict ──► 主动避让流水线查表
│   └── 搬移/清除操作 ──► 经外层 mux 访问 TCAM 接口
│
├── fifo_ctrl ─────────────────── [[以往项目 TCAM]]
│   ├── bitmap2index：bitmap → index 转换
│   └── fifo：深度 4；valid 打拍对齐 index 计算延迟；支持反压
│       （路径 2-cycle 延迟 + 预留 1-cycle 冗余）
│
└── 存储实体
    ├── TCAM IP
    │   ├── Data 阵列
    │   └── Mask 阵列（与 Data 独立存储）
    └── 外部 ECC 校验位 SRAM（带写掩码，本身不做 ECC 保护）
        ├── Data 校验位
        └── Mask 校验位（与 Data 统一存储，通过写掩码区分更新）
```

**数据流示意**

```
流水线 ──► fifo_ctrl (bitmap2index → fifo) ──► pl_search_req ──┐
软件 ──► CSR ──► csr_req ──────────────────────────────────────┤
ECC_FSM ──► ecc_rd_req / ecc_wr_req ───────────────────────────┴──► TCAM_ARB ──► 外层 mux ──► TCAM IP
                                                        ▲              │              │
                                                move_busy│              │              ├──► 外部 ECC SRAM
                                                         │              │              ▲      (ECC_GEN/ECC_CHK)
                                                         └── 搬移 FSM ────┴── 搬移/清除 ──┘
```

**本轮补全的关键点**

- **ARB 请求源**：已补全为四类——`ecc_wr_req`（最高）、`pl_search_req`、`csr_req`、`ecc_rd_req`（最低）[^1]
- **搬移 FSM**：明确其**不进 ARB 仲裁**，通过 `move_busy` 硬件互锁 + 外层 mux 与 ARB 输出竞争 TCAM 接口[^1]
- **存储实体**：显式画出 TCAM IP 的 Data/Mask 双阵列，以及外部独立 ECC 校验位 SRAM（带写掩码、无额外 ECC 保护）[^2]
- **ECC_GEN/ECC_CHK 数据流**：写路径经 ECC_GEN 生成校验位写入外部 SRAM，读路径数据+校验位送入 ECC_CHK 检错纠错[^2]
- **fifo_ctrl 内部**：补全为 bitmap2index → fifo 两级结构，深度 4，valid 打拍对齐 index 计算延迟，支持反压[^3]

这套结构已与 v2.2 定稿方案完全对齐，可以直接作为 RTL 实现的层级参考。

[^1]: [[TCAM_ARB实现方案]]

[^2]: [[TCAM_ECC校验实现方案]]

[^3]: [[以往项目 TCAM]]