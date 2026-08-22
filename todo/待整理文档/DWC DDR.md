#DDR #Synopsys 
# 随记
## 手册说明
### 名词
#### 时钟

| Name               | Description          |
| ------------------ | -------------------- |
| core_ddrc_core_clk | uMCTL2 主时钟，并同步给 PHY。 |
| core_ddrc_rstn     | uMCTL2 复位信号，低电平有效。   |
| aclk_n/hclk_n/pclk | axi/ahb/apb 时钟信号。    |
| presetn            | apb 复位信号，低电平有效。      |
| ddrc_core_rst_n    |                      |
| sys_clk            |                      |
#### 其他
| Name        | Description                                            |
| ----------- | ------------------------------------------------------ |
| aclk domain | 目的时钟域                                             |
| reset mode  | core_ddrc_rstn assert，就是低电平有效，进入 复位模式。 |
### 寄存器配置
1. 动态寄存器分为四组：[[DWC_ddr_umctl2_databook.pdf#page=1685&offset=36,424|DWC_ddr_umctl2_databook, 6.2.1 Dynamic Registers]]；
	1. 静态寄存器；
	2. 动态寄存器：在 DDRC 运行期间的任何时间都可以写入，需要同步处理；
	3. 刷新相关寄存器（Refresh Related Registers）是动态的，更新前需要处理：
		1. 根据需求更改刷新相关的寄存器；
		2. 在更改寄存器稳定之后，切换 RFSHCTL3.refresh_update_level 信号。
2. 大部分寄存器在 cMCTL2 控制器进入复位初始化（core_ddrc_core_clk 有效， core_ddrc_rstn 无效）后不可改变。
## 上电初始化流程
![[Pasted image 20241105100509.png]]
1. core_ddrc_rstn 和 aresetn_n 有效；
2. presetn 有效；
3. 时钟开始工作（pclk、core_ddrc_core_clk、aclk_n）；
4. 当时钟稳定后，presetn 无效：APB 接口开始工作，配置寄存器；
5. 允许 128 个周期用于预置到 core_ddrc_core_clk 和 aclk 同步，并允许初始化结束逻辑；

# other
#### TODO：
- 查看 IP 手册 DFI 相关的，主要查看地址和数据。

![[Pasted image 20241021164248.png]]