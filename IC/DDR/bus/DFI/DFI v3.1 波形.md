1、 reset 0、2表示两个phase；
2、二分pin
3、MC--转接口---PHY
	600 300 1200/2400MHz

⚠️
- cke 复位后拉高；
- DFI中 为两个phase；
- 初始化完成后先进入MRS配置，；
- REF
- ZQ 校准
# DFI v3.0 波形

- `cs[3:2]`表示一些通用命令：自刷新，矫正等；`cs[1]`表示读命令；`cs[0]`表示写命令；
	- 当`cs[3:2]`表示自刷新时，注意看是两个phase同时自刷新，还是单独自刷新（可以就一位信号拉低）；
- `act_n[1:0]`是否同时变化？
	- 在ACT激活phase 0 时，act_n[1:0]同时拉低，但只有cs_n[0]拉低；
#### 命令波形记录
#### MRS
-  cs选择双phase，但phase0变化慢一拍，==是否使用phase 1的配置呢==？
	- ![[Pasted image 20241016144828.png]]

#### REF
- ==**无论是选择phase0 还是phase1，都会使用`ras[1]/csr[1]/we[1]`**。==
	- *每隔一段时间就会插入一个自刷新命令，DDR特性*。
##### phase 0 REF
- cs[2]=0，选择 phase 0，使用==ras_n/cas_n/we_n[1]=001== ；![[Pasted image 20241016091537.png]]
##### phase 1 REF
- `cs[3]=0`，选择`phase1` ；![[Pasted image 20241015201237.png]]
##### 双phase刷新
![[Pasted image 20241016094913.png]]

#### PRE
- A10=1’b0 ---> `Single Bank Precharge`；![[Pasted image 20241016153402.png]]
- A10=1'b1 --->`Precharge all Bank`；
#### RFU
#### WRITE
- `dfi_cs[3:0]    4'b1111 ---> 4'b1110`：对`phase 0`操作；
-  `ras/cas/we = 100` 表示写操作；
- 等待`**`延迟后，在数据通道传输数据：==wrdata_en/wrdata 怎么变化的==？？![[Pasted image 20241015200106.png]]
	- ==vcs波形怎么加，怎么找==？
#### ACT
- `act[1:0]        2'b11 --> 2'b00`：表示是一条激活命令；
- `dfi_cs[3:0]    4'b1111 ---> 4'b1110`：激活`phase 0`；

DDR颗粒：
- DDR_CS0_N：变为有效状态（1‘b0）；
#### ZQ
- cs选择双phase，但phase0变化慢一拍，==是否使用phase 1的配置呢==？
- ![[Pasted image 20241016145630.png]]

#### READ


## 奇怪的波形
##### 1、选中双phase，但REF+ZQ，最终显示REF
- ==phase0是REF，phase1是ZQ；在颗粒上显示是双phase REF==；
![[Pasted image 20241016101539.png]]
##### 2、双phase选中，ZQ，但颗粒显示REF

![[Pasted image 20241016102254.png]]
3、WR变成MRS了
4、WR->READ

## IP行为总结
##### dfi_cs[3:0]
- dfi_cs[3:2]：`REF、MRS` 选择 phase；
	- `dfi_cs_n[3]=0---> phase1`；
	- `dif_cs_n[2]=0---> phase0`；
- dfi_cs[1:0]：`WRITE、ACT`选择 phase；
	- `dfi_cs_n[1]=0---> phase1`；
	- `dif_cs_n[0]=0---> phase0`；



# Q
- 两个phase 不同命令，颗粒怎么处理？
	- 波形显示采用phase 1；
	- A：其实是对应一个颗粒，就无先后顺序；
- 为什么phase 不是同时刷新呢？
	- phase 1 先刷新，然后phase 0再刷新；
	- A：可以看代码怎么实现的（emmm）：
- 写数据时序参数在波形中如何看？或者在代码写在哪里呢？
- Q1：
	- DFI上是==写命令==，但==读信号有效==，在==颗粒上显示为读操作==；
	- ==rddata_en在颗粒读操作后面，那颗粒如何识别为读操作==呢？

- [ ] 整个读操作如何实现？？如何实现突发传输？
## verdi
- 怎么从波形查看信号呢？
	- 尝试将信号从波形直接拉到代码处，但无反应。