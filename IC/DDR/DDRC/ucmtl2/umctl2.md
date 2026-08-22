#card 
# init_ddr_fsm
- 此模块功能是 DDR 初始化状态机，方便debug。
- 路径：`U_DWC_ddr_umctl2/U_ddrc/ddrc_ctrl_wrapper/ddrc_ctrl_inst[0]/ddrc_ctrl/ts/gs/gs_init_ddr_fsm.v`
- ![[Pasted image 20250122153114.png]]



# 名词解释
- CAM，Content Addressable Memory；
- sbr，Scrubber：；
	- sbr_clk：巡检时钟，与 DDRC 主时钟（core_ddrc_core_clk）分开，但同步，以相同的频率同步运行；
	- sbr_resetn：巡检复位，与 DDRC 复位信号（core_ddrc_rstn）分开；