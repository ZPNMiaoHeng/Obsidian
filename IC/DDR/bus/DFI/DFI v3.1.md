#IC #DDR #SoC 
1. 先看接口定义，忽略时序参数；
# 随记
- 信号名字后缀加上`_pN`是什么意思呢？
	- 是在`MC`和`DDR`之间频率有对比情况下，才会使用；
	- 定义了DFI PHY时钟的每个相位N的信号值，相位为0可以忽略后缀；

# Spec
## 3.0 interface Siganal Group

#### 3.2.5 Wirte Data Signal and Parameters

| Signal          | Width | Description                                                                                                                                                               |
| --------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| dfi_wrdata      |       | 1、写数据。<br>2、当 wrdata_en 有效后，在时序参数 tphy_wrdata PHY 时钟周期下，dfi_wrdata 数据才有效。<br>3、连续写操作需要 wrdata_en 连续有效。                                                                    |
| dfi_wrdata_cs_n |       | 1、如果 Data chip select 启用，则此信号表示访问哪个芯片选择以获取相关的写数据，==以独立补偿访问不同芯片选择的数据接口上的时序差异==。<br>2、在**写训练**期时表示当前正在训练的 chip；<br>3、**不在写训练**时为可选信号，表示访问的芯片选择或者相关写数据的目标；                   |
| dfi_wrdata_en   |       | 1、写数据使能信号，表示`dfi_wrdata、dfi_wrdata_mask` 数据是否有效。<br>2、理想情况下，**dfi_wrdata_en bits 与 PHY 数据切片存在一一对应的关系，比如 dfi_wrdata_en[0] 对应 dfi_wrdata 信号最低数据段**；--对应实现突发传输模式，BL8 或者 BL4。 |
| dfi_wrdata_mask |       | 1、默认为写数据字节掩码。<br>2、若 ==DBI特性==开启，phy dbi_mode=0，则此信号变为 DBI信号，表示写数据是否反转<br>3、若 dfi_wrdata 数据位宽不是8的倍数，则 dfi_wrdata_mask 信号的最高位对应于数据的最高有效部分字节。                               |
- dfi_wrdata_en 与 dfi_wrdata 实现 BL8 突发传输方式：
	- ![[Pasted image 20241027174313.png]]

| 时序参数         | 时序起点                       | 时序终点                       |
| ------------ | -------------------------- | -------------------------- |
| t_phy_wrlat  | PHY 采样 Write 命令            | PHY 采样 dfi_wrdata_en_pN 有效 |
| t_phy_wrdata | PHY 采样 dfi_wrdata_en_pN 有效 | PHY 采样 dfi_wrdata_pN 有效    |
- 都可以被定义为0；
