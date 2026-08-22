#card #umctl2 #Synopsys #DDRC 
- [ ] MEME_ENH_RDWR_SWICTH 功能；
# MEME_ENH_RDWR_SWITCH == 0
## Page Policy
###  Explicit Auto-Precharge（Per Command）
- 功能：在每个基础命令前启用自动预充电；
- HIF 接口：若命令有效期间 `hif_cmd_autopre==1'b1` ，则该命令发送到 SDRAM 时，此命令的自动预充电比特位会被设置有效；否则会被设置无效，所有命令都不会以自动预充电方式执行；
- AXI 接口：通过 `arautopre_n` 和 `awautopre_n`两个信号控制显示自动预充电是否支持；----详细参考手册97页；

### Intelligent Precharge；
### RAS Lockout feature
# MEME_ENH_RDWR_SWITCH == 1
# TODO
## 不懂名词/寄存器
- [ ] MEME_ENH_RDWR_SWICTH;
## 问题
