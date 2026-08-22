---
tags:
  - 7000N
  - pro_todo
status: Waiting
---
# TODO
![[4-linear_table.png]]

- [x] table_ram_initialize： ✅ 2026-04-24
	- [-] 是否可复用 80 内的呢？包含无复位寄存器初始化流程：不可以，80是寄存器类型表；
- [x] sram： ✅ 2026-04-24
	- [x] 定制、接口文档，绝大部分都是spram，单端口资源更小； ✅ 2026-04-24
	- [!] 项目 ram 选型不同，不可复用可重用；
- [x] private_common： ✅ 2026-04-24
	- [x] 参数; ✅ 2026-04-24
	- [x] table_access_arb_nxm； ✅ 2026-04-24
		- [x] LRU 仲裁； ✅ 2026-04-24
		- [x] table_arb_bypass_reg； ✅ 2026-04-24
		- [x] table_out_cache_fifo； ✅ 2026-04-24
	- [x] table_index_gen_private； ✅ 2026-04-24
	- [x] common_relay_n_bit； ✅ 2026-04-24
	- [x] csr； ✅ 2026-04-24
		- [x] 寄存器表单； ✅ 2026-04-24
		- [x] 查看 tab_hash 类型； ✅ 2026-04-30
- [ ] common_par_chk：CBB
	- [x] wrapper：做了是否整除处理； ✅ 2026-04-23
	- [ ] CBB：文档介绍；
	- [x] 奇偶校验、ECC原理； ✅ 2026-04-23
	- [ ] ECC
		- [ ] 为何没实现回写功能？
		- [ ] 如何实现 1bit 纠错呢？
		- [ ] 

# PT
### 架构图
![[1-linear_table.png]]

---
### 数据流图
- [ ] 太复杂，先跳过；

---

### 反压图
- 单拍表![[2-linear_table.png]]
- 多拍表![[3-linear_table.png]]

---

### shared_common_table_wr_addr
![[5-linear_table.png]]



--- 
# QA
- [x] 为什么线性表内 csr 间接访问寄存器使用 tab_hash？ ✅ 2026-05-06
	- [x] 二者不同：Tab 无反压机制，无法暂存当前 csr 访问； ✅ 2026-05-06
- [ ] csr 中端口优先级默认0，csr、流水线优先级相同，如果同时访问的话，怎么仲裁呢？
- [ ] 奇偶校验：
	- [ ] 发生奇偶校验后如何处理呢？
	- [ ] 多 bank 场景上报地址不包含 bank 号；![[1-linear_table.png]]
- [ ] ECC 为什么不支持回刷功能呢？会使 1bit 可纠正错误变成 2bit 不可纠正的错误；
	- [ ] 1bit 可纠正错误如何实现？是在 CB 中直接实现吗？
	- [ ] 老 7000 中只有 Port 表使用 ECC，其余都是奇偶校验；
	- [ ] 老 7000 使用的是 int0、1，80 中 SRAM 表触发奇偶校验使用 int2；