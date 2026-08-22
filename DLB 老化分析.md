#7000N 
###  DLB 老化原理

## 实现规格
- [ ] 两种方案各有优劣，需要了解变动、分析；
- [ ] 和协议对接，为什么 table 规格变动这么大；

### 7000 方案
![1 DLB 老化原理](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/1-DLB老化原理.png)
![1 DLB老化分析](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/1-DLB老化分析.png)
![2 DLB 老化分析](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/2-DLB老化分析.png)

### 性能计算
#### 32K 深表
- 表项规格：32Kx16；
- 实现规格：1Kx（16x32）；
- 频点：920Mhz，大约 1.09ns，
	- 1us 有 917 个 clk 周期；
	- 单次老化时间为 4-Cycle；
	- 实际 1us 老化次数约为 229 次，229x32=7328；
- 若划分 16 bank，每个 bank 单独老化 FSM控制；
	- bank规格：64x512；
	- 7328x16=117248>32K


#### 2K 深表
 表项规格：2Kx432；
实现规格：2Kx（432）；
- 频点：920Mhz，大约 1.09ns，
	- 1us 有 917 个 clk 周期；
	- 单次老化时间为 4-Cycle；
	- 实际 1us 老化次数约为 229 次，229x1=229；
- 若划分 16 bank，每个 bank 单独老化 FSM控制；
	- bank规格：128x432；
	- 性能计算：229x16=3664>2K


### 新方案变动
老方案太占用带宽了，修改实现方案：
![3 DLB老化分析](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/3-DLB老化分析.png)

### 新方案
![4 DLB老化分析](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/4-DLB老化分析.png)
![5 DLB 老化分析](https://raw.githubusercontent.com/ZPNMiaoheng/picgo/main/5-DLB老化分析.png)
