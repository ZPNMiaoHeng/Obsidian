---
tags:
  - 7000N
  - pro_todo
status: Done
---
# todo
- [x] 逻辑架构组成； ✅ 2026-05-17
	- [x] 确定 cg 信号复位功能； ✅ 2026-05-17
- [-] DFT 代码；--- 新 IP 会集成；

# 架构介绍
## 8002 
### ARB
- 仲裁模块：外部输入与 csr 接口仲裁，csr 优先级更高；
### fifo_ctrl
![[3-8002_TCAM.png]]
- 支持 bitmap 转 index；
- valid 打两拍对齐 index 计算延迟；
- 支持反压，考虑路径上 2-Cycle 延迟，以及预留 1-cycle 冗余，深度设置为 4；

### cg
- 支持 clock gating，降低功耗；
	- 若 csr_tcam_cg_en有效，在读、写、匹配 TCAM 时，时钟才有效，其余处于无效状态；
	- [?] 为什么使用 rst_csr_n，不使用 rst_n？![[1-8002_TCAM.png]]
	- [x] 7000 项目中 cg 信号 rst_csr_n 信号被注释；![[2-8002_TCAM.png]] ✅ 2026-04-22
		- [x] 7000 使用异步复位，无需等到解复位之后 cg 信号有效； ✅ 2026-04-22

## 7000

### 奇偶校验检查
- ![[5-8002_TCAM.png]]
- ![[4-8002_TCAM.png]]
- 偶校验，具体实现还没搞懂，里面使用 generate 生成的。

