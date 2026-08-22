#IC #DDR 

#### 1. Q：DRAM 规格计算
![[Pasted image 20240924110656.png]]
![[Pasted image 20240924110820.png]]
1. Q：16GB规格中地址为什么不是18bits呢？也就是`Row Address`和`BG`之间的关系
	1. 假设1：`Row*Col*width of each column=1K*256K*4bits=1Gb`，是不是可以认为一个`Bank`？
	2. `Col`中其中两位应该是`BG Address` 和 `Bank Address in a BG`？
	3. Row行，但在端口上有18位（A0-A17）
2. Q：Page size如何计算呢？
	1. A：`Page Size=2^(Column Address Bits)×Data Width`；
3. DDR如何使用？哪部分是ip，哪部分是自己做呢？
4. 协议版本是固定的嘛？
	1. 比如：DFI协议要求MC和PHY版本一致，那是要求根据IP使用的。



验证反串讲：
1. Q：
	1. 双通道、DM条、颗粒是什么呢？
	2. 两个DDR 测试方案？
	3. DDRC 地址 映射方案；
	4. ECC分不分1bit、多比特纠错方式？
		1. 1bit纠错，多比特上报；
		2. 支持注错功能,，方便测试；需要是否占用资源；
	5. SIDEBAND-ECC？
		1. 优点：不需要巡检回刷（写入存储器），就可以直接读取数据；不影响带宽；
		2. 缺点：；
	6. 巡检ECC、数据ECC？？
	7. X8、X16：X16是不是可以使用两个X8组成呢？
2. 两种DDR 不同组合测试方案；不同颗粒规格组合测试方案
3. RANK