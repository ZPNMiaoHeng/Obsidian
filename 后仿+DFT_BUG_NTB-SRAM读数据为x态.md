#PS80256 #后仿 #bug 

### 问题现象
DFT 网表回来后，BT 访问出现 x 态，后分析定位为 SRAM 读数据为 x 态；
#### vcs 编译 log
编译 log 会提示：
```log
Warning: Q corrupted due to CRE* toggle in TH.U NTB TOP.ntb function top.ntb unicast.ntb addr table.ntb mem vcs mapping data table table.ntb memory0 body.UO SPRAM INST at 0.0ns
```
![[1-后仿+DFT_BUG_NTB-SRAM读数据为x态.png]]

### 问题根因
- IP 与 VCS 版本编译冲突；
	- VCS 2023 版本，在 vcs 2018 版本已验证过；

### 如何规避
- SRAM 初始化赋值从 0 改为 x；