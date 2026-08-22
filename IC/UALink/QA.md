#UALinx #todo 
# 5 TL
## [[5 Transaction Layer（TL）#5.5 TL Tx 和 Rx 数据流、Tx 和 Rx 压缩缓存]]
- [x] Originator 是报文发起者，但 req 和 OrigData 为何是分开传输？？ pack 格式不是以 Flit 格式嘛？
	- [x] A：最初传输不是以 Packing 形式，在 UALink 中进行组包。2025年2月28日09:33:40
- [x] Tx Address Cache 是属于 Rx 端维护写嘛？Tx 端发数据只负责查是否命中？
	- [x] A：错误，Tx、Rx 各有一个可选的 Cache，各自负责维护。2025年2月28日09:34:31
- [x]  Cache 命中后，谁发出压缩请求呢？
	1. 是通过地址索引，tag 对比是否命中？ CacheLine 中保存的压缩请求嘛？
		- [x] A：当前这么认为；2025年2月28日09:35:34
	2. Cache 数据格式：Valid，Tag(压缩请求)，Req pack。
	3. Cache 规格：
		1. 几路组相联？
		2. Cacheline 大小？
		3. Cache 大小？
		4. 几级 Cache？
		5. Cache 内实现的替换算法？
		6. Cache 一致性如何维护？
		7. DFX：Cache 效率；
- [?] Tx req 中命中发压缩 req，未命中发 req。若发出 req ，Rx cache 会出现未命中情况吗？
	- [!] spec 中说 Rx Cache 由 Tx Cache 维护  




- [x] NOP 算 Flit 嘛
- [x] 复习 Cache 原理，[[Cacheline 和 entry 之间关系]] 