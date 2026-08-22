---
Done: false
status: Doing
tags:
  - todo
  - spec
start: 🌟🌟
---
# 规格

- [?] 支持 Farbric 多路径：
	- [!] req、cpl 报文返回路径相同；
- [x] ~~TCAMx2 实现；~~
	- ~~实现3 种匹配模式；~~
	- ~~cpl 报文是用两种不同匹配模式同时查找；~~
	- ~~支持流水查表；~~
- 查表延迟为4拍；

- [x] 查看协议整理的 Segment ![[2-ID mapping table.png]]


#### 场景分析：
##### 会不会出现 8 个 NTB 同时访问 ID 表的场景？
![[1-ID mapping table.png]]
- 不会。
	- [!] 不会，入口 Slice 限制，Slice 给 Ingress 最多 1 cycle 1 PD；即使内部划分 8 个 VCS（8 个 NTB），同一时刻下，只有一个 NTB 中的 PD 是有效的；
	- [!] SW 规格：SW 内有 9 条 Ingress 流水线，9 条流水线并行的，流水线内部串行；

---

##### ？