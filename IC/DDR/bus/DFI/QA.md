##### wrlat 的值与波形观测不同
- 写操作中 wrlat 的值为 0xf，在波形中观察 DFI 控制端口发出 WR 命令到 dfi_wrdata_en 有效时间PHY 时钟间隔为 ==0xe==；
	- ![[Pasted image 20241024165434.png]]
	- wwf：dfi_wrlat 是奇数，会出现这种情况，详细也不太清楚
	- mh：之前看过这个帖子！！！
		- [ ] 找出资料。