#IC #Synopsys #DC
# 术语
- PPA：Performance性能、Power功耗、Area面积；
-

# 定义
1. libraray:
	1. Target library：将RTL级的HDL描述到门级时所需的标准单元综合库，Foundry提供，包含物理信息的单元模型；
	2. Link library：
		1. 链接库，可以时Target library或者已综合底层模块设计、memory等，
		2. 作用是由下而上的综合过程中，上一层的设计调用底层已综合模块或者hard macro时，将从link library中寻找并link起来。；
	3. Symbol library：显示电路时，用于表示器件、单元的符号库；
2. 工艺库分为可读的`.lib` 和二进制的`.db`。（Synopsys通用工艺库GTECH库，不带有任何工艺参数，仅代表一定的逻辑功能）
	1. 逻辑库：
		1. 综合过程有关的信息，通过DC用于设计的综合和优化；
		2. 一般包括：引脚到引脚的时序、面积、引脚类型、功耗等；
	2. 物理库：包含单元的物理特征---物理尺寸、层信息、单元方位相关的数据；
3. `Wire_load_model`：连线负载模型
	1. `Foundry`提供，基于连线的扇出，估计电阻电容等寄生参数，从而估计连线延迟。
	2. 具体方法：根据统计信息给出单位连线长度对应的面积、电阻电容系数，根据每根`net`的`fanout`数，通过`net`的面积及`RC参数`，并估算出`net delay`。
4. operating_conditions：
	1. `PVT`：`Temperature`、`Voltage`、`Process`；
	2. 三种状况：`best case`、`typical case`、`worst case`；
	3. 标准的STA分析条件：
		1. WC（Worst Case）：slow process，high temperature， lowest voltage；
		2. TYP（typical）：typical process，nominal temperature，nominal voltage；
		3. BC（Best Case）：fast process， lowest tempera，high voltage；
		4. WCL（Worst Case @ Cold）：slow process，lowest temperature， lowest voltage；
	4. 功耗分析：
		1. ML（Maximal Leakage）：fast process， high temperature，high voltage；
		2. TL（typical Leakage）：typical process，high temperature， normal voltage；