#IC #DDR #FPGA 
# I/O Port

| Type   | Width  | Name                   | Description       | 参考链接                                                                                                                          |
| ------ | ------ | ---------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| inout  | [8:0]  | c0_ddr4_dm_dbi_n       | DM/DBI：根据配置寄存器决定； | [[EDEC spec JESD79-4B.pdf#page=60&offset=71,461\|EDEC spec JESD79-4B, 4.11 Data Mask(DM), Data Bus Inversion (DBI) and TDQS]] |
|        | [71:0] | c0_ddr4_dq             | 双向数据总线            |                                                                                                                               |
|        | [8:0]  | c0_ddr4_dqs_c          |                   |                                                                                                                               |
|        | [8:0]  | c0_ddr4_dqs_t          |                   |                                                                                                                               |
| output |        | c0_ddr4_act_n,         |                   |                                                                                                                               |
|        | [16:0] | c0_ddr4_adr            |                   |                                                                                                                               |
|        | [1:0]  | c0_ddr4_ba             |                   |                                                                                                                               |
|        | [1:0]  | c0_ddr4_bg,<br>        |                   |                                                                                                                               |
|        |        | c0_ddr4_cke,<br>       |                   |                                                                                                                               |
|        |        | c0_ddr4_odt,           |                   |                                                                                                                               |
|        |        | c0_ddr4_cs_n,          |                   |                                                                                                                               |
|        |        | c0_ddr4_ck_t,<br>      |                   |                                                                                                                               |
|        |        | c0_ddr4_ck_c,<br>      |                   |                                                                                                                               |
|        |        | c0_ddr4_reset_n        | DDR4复位信号          |                                                                                                                               |
|        |        | c0_init_calib_complete | 初始化、矫正完成标志信号。     |                                                                                                                               |
|        |        | c0_data_compare_error  |                   |                                                                                                                               |
| input  |        | sys_rst                | 系统复位信号            |                                                                                                                               |
|        |        | c0_sys_clk_p           | 系统时钟：`p`          |                                                                                                                               |
|        |        | c0_sys_clk_n           | 系统时钟：`n`          |                                                                                                                               |


# note
![[Pasted image 20241009172810.png]]
这个例子应该是![[Pasted image 20241009175335.png]]内部包含了
- PHY；
- ==ddr4_0 应该是MC==；

## Q：
1. phy xilinx 接口为啥还需要在接入DDR4呢？
2. 例子中`c0_ddr4_d***`信号为啥直接接入`u_ddr4_0`模块呢？
## A
# REF
官方手册![[Pasted image 20241009144302.png]]
# TODO：
- 先做DQ16；（例子是72）![[Pasted image 20241009162159.png]]
- 后续参数化；