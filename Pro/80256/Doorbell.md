---
Done: false
status: Doing
start: 🌟🌟
tags:
  - todo
  - spec
---
# SPEC
- SPEC 中定义 MSI 功能：![[2-Doorbell.png]]
## 规格
- 只支持 mem write 报文；
	- mem read 需要带响应，流水线处理比较麻烦，不支持；
- 不需要添加 HIE 字段，走静态路由；


# MSI/MSIX 报文字段修改- 知乎

![[Doorbell-MSX、MSIX.png]]

![[1-Doorbell.png]]

- Fmt[2:0]：3‘b011（data）；
- Type[4:0]：00000；
- Attr[1:0]：2‘b00；
- Length[9:0]=10’b1（one DW of data）；
- Last DW=4’b0；
- First DW=4‘b1111；

![[4-Untitled.png]]





