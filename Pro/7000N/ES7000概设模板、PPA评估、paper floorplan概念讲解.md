---
tags:
  - 7000N
  - 会议纪要
status: Done
---
- 新增接口编号；
- 数据流；
	- 多条数据流，需要使用 visio 图层功能；
- HWACG？---模块自己产生 cg 信息；
- 复位域：
	- cfg：复位全局；
	- ：复位逻辑；
- 功耗优化手段：
	- clock gating；
	- HWACG；
	- DBI；
	- 低压供电；

### 模块要求
#### 3 模块整体结构
- 画图：
	- 图元：FIFO、Cache、调度器、表项；
	- 接口名称；
	- 二级子模块功能描述；

#### 4 物理实现
##### 4.1 PARE FLOORPLAN


##### 资源与功耗分析
- 资源
	- memory：利用率；
	- 寄存器数量；
		- 寄存器表项、FIFO；
		- 记录信息；
		- 时序流水打拍；
		- 功能消耗；
	- 组合逻辑/寄存器比例；
	- DFT 资源上浮比例；
- 功耗
	- 静态功耗：
		- memory 部分来自定制 Memory 库；
		- STD CELL：估算 CELL 数量、预估的 LVT 比例计算；
	- 动态功耗：
		- memory 访问率；
		- STD CELL 平均翻转率（基于历史项目和经验）；

# 电路设计
- 逻辑级数：
	- 要求：30 级；
	- LVT ：50%以下；
	- 逻辑级数40级左右也能收敛，但使用 LVT 比例过高，会导致功耗过高；
- 功耗仿真：
	- ![[1-ES7000概设模板、PPA评估、paper floorplan概念讲解.png]]
	- switch power：线翻转功耗；
	- Internal Power：cell 内部翻转功耗；

