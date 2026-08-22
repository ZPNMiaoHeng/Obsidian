
### 中断汇聚

模块负责汇聚以下三个中断源：

- `int0`：ECC 单比特校验错误，对应输出 `csr_error_interrupt0`；
- `int1`：软件访问表项过快，对应输出 `csr_error_interrupt1`；
- `int2`：ECC 双比特校验错误，对应输出 `csr_error_interrupt2`。

### 表项初始化

- 模块内部包含控制所有表项初始化的 CSR 寄存器。此寄存器通过接口信号 `csr_table_clear_en` 传递给各 table 模块。
- 初始化完成后，每个 table 输出 1bit 完成信号 `table_clear_done`。
- 模块内多个表可以同时进行初始化。
- 初始化未完成前，对未完成表的读操作返回 0。

### 表项读写访问

- 一组接口在同一拍内只能响应单独的读或写操作。若读、写同时有效，仅响应写操作。
- 读写地址不得超出表的地址范围。
    - 访问超出表功能深度的地址（且未初始化）时，读返回值可能为 x 态。
    - 软件需保证地址有效性。设计原则：在源头解决问题，降低表内时序消耗和复杂度。

### ECC 错误地址上报

- table 内部触发的 ECC 校验错误，其错误地址由 table 内部 CSR 节点本地记录并上报，模块无需参与处理。
- 对于内部多 bank 共享表，增加 8bit bank 号标记寄存器，用于记录触发错误的 bank 编号 [[2](obsidian://open?file=Note%2Fmindmap%2Flinear%20table.smm.md)]。