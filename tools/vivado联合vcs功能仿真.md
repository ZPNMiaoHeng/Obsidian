#FPGA #Synopsys 
当时分配项目为 DFI2POI 转接模块，但测试环境难搭建，因此使用 FPGA DDR IP 生成的仿真示例。但 FPGA 自带的功能仿真不如 vcs 好用，每次添加信号都需要重新编译，而且编译仿真时间长，Debug 代价太大。

## 编译 FPGA IP 库
[[#^1add32| FPGA IP 库编译]]
``` bash
10.90.0.126:20 #服务器
/home/data1/xiongxinzhong/workspace/test_by_miaoheng/fpga_vcs/Xilinx/vcs_simlation_lib #存放路径

```

## 修改工程
- 修改tb 添加生成波形语句
	- 路径：`/home/data1/xiongxinzhong/workspace/test_by_miaoheng/fpga_vcs/fpga_ddr_1206/ddr4_0_ex/imports/sim_tb_top.sv`

``` verilog
//  initial
//begin
//    $fsdbDumpfile("fpga_mcphy_1206_tb.fsdb");
//    $fsdbDumpvars();
//end
```

- 其余按照[[#^384004]]操作；
# TODO
- [x] 生成 FPGA IP 库；
- [x] IP 示例可以生成 vcs 仿真文件，并可编译；
- [x] DFI2POI项目生成 vcs 仿真文件，可编译；
- [?] verdi 仿真如何制定源码？
# Ref
- [vivado+vcs+verdi 仿真 - 知乎](https://zhuanlan.zhihu.com/p/608732234) ^1add32
- [一种vivado联合vcs仿真以及verdi查看波形的方法_vivado vcs 联合方针工程-CSDN博客](https://blog.csdn.net/qq_15062763/article/details/130102440) ^384004
