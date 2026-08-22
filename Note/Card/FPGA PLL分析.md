 #card
- 查看 FPGA 例子中内置 IP MMCME4_ADV 中其余未使用端口输出时钟；![[Pasted image 20241125143013.png]]

| 模块端口    | 连接端口            | 频率比 |
| ------- | --------------- | --- |
| CLKOUT0 | u_bufg_divClk   | 1:1 |
| CLKOUT1 | addn_ui_clkout1 | 1:1 |
| CLKOUT2 | addn_ui_clkout2 | 1:1 |
| CLKOUT3 | addn_ui_clkout3 | 1:1 |
| CLKOUT4 | addn_ui_clkout4 | 1:1 |
| CLKOUT5 | dbg_clk         | 1:2 |
| CLKOUT6 | Clk             | 1:4 |
![[Pasted image 20241125144020.png]]
![[Pasted image 20241125173604.png]]