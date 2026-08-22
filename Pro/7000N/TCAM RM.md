---
tags:
  - 7000N
  - pro_todo
  - todo
status: Doing
---
# 需求
## RM 要求
### 实现 TCAM 资源共享![4 TCAM IP 选型](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/4-TCAM IP 选型.png)
- [x] CAP 模块要求实现 TCAM 资源共享，类似 table_pool---方案已确认； ✅ 2026-05-17

---
## 项目规格
- ![1 TCAM](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/1-TCAM.png)
- ![2 TCAM](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/2-TCAM.png)
# TODO
- [x] 学习 TCAM ：
	- [x] 查看 7000 TCAM 流程；🔼 
		- [x] CAP 支持 TCAM 搬移和清楚，查看代码实现；
		- [x] CSR 寄存器表单可以实现表格参数化：当前都是手填的，容易出错，可以参考 hash_table csr 表单；
		- [x] 多 bank 实现； ✅ 2026-05-12
	- [x] 查看 8002 TCAM 定制流程；---要比 7000 TCAM 更简单些，1602 TCAM 定制多奇偶校验；🔼 
- [x] [[TCAM IP 选型]]：SMIC 12； 🔺 ✅ 2026-05-12
	- [x] 查看项目需求； ✅ 2026-05-12
	- [x] 怎么选啊？？？？？ ✅ 2026-05-12
- [x] TCAM wrapper：
	- [x] 参考 80256 线性表 csr 到表项访问的处理，有效隔绝  csr 访问通路的时序违例；⏫ 
- [ ] 定制脚本化⏬ 

## 变动
### CSR
- [ ] TCAM csr 修改：
	- [x] 中断汇聚：不分数据搬移中断和 TCAM 中断，地址使用 0x0~0x8； ✅ 2026-05-11
	- [x] 软件配置信息：汇聚为 TCAM\_ACCESS\_CFG 寄存器，使用地址 0x9； ✅ 2026-05-11
	- [!] 奇偶校验上报格式： 待评审
		- BUG：当前每个 bank 单独上报奇偶校验触发信息和地址位，就会导致csr参数化不容易实现；
		- 解决方案：多 bank 汇聚成 1bit 单独奇偶校验信号，奇偶校验地址上报为 bank+错误地址，解析交给软件；
		- 原因：csr-chain 配置地址位 bank+Tcam地址，应当统一格式；
		- 优点：
			- 节约资源，寄存器数量从`bank_num->1`;
			- 不考虑 bank 数量，方便参数化 csr 表单；
	- [ ] BE 寄存器在 csr 模块外部参数化，根据 bank 数量实现；
	- [x] CAM 寄存器之前是每个 Bank 一个，改为 1 个表单一个；
		- [?] 之前项目为什么做成每个 Bank 一个 CAM 寄存器呢？
			- [/] 如果软件访问 TCAM 表的话，需要同事配置每个 Bank CAM寄存器；（是不是麻烦些）
			- [?] 存在 Bank 单独控制场景嘛？
		- [ ] csr.v 中最后读寄存器 default 改为 TCAM；![3 TCAM](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/3-TCAM.png)
### 代码
#### L3
##### indexgen
- [ ] 是否可以直接写成 1024 bitmap 转 10bit index 呢？为什么需要拆分每 128bit 呢？
- [ ] ![1 2026 05 18](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/1-2026-05-18.png)
	- [x] 优先编码器，最后找出最低有效位；
	- [ ] else 分支是否冗余，会不会产生组合逻辑环？

# QA