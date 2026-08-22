
- 发现问题：虽然station开透传配置，但对应透传寄存器没配置；
	- ![[4-Fabric 网络 cfg 报文路由出错.png]]
	- 修改寄存器配置：![[1-Fabric 网络 cfg 报文路由出错.png]]
	- 

## Station IP
### 路径
![[3-Fabric 网络 cfg 报文路由出错.png]]

### 手册
- `CFG_TLP_BYPASS_EN_REG`：此字段的设置决定了如何确定配置请求的最终目的地。
	- 注意：当“app_req_retry_en”标志被激活时，此字段的设置将被忽略。
- `CONFIG_LIMIT_REG`：配置请求会根据此字段的值被定向至 CDM 或 ELBI/RTBGTI。
	- 具有小于 CONFIG_LIMIT_BEG 地址的配置请求会被定向至 CDIL；
	- 具有大于 CONFIG_LINIT_REG 地址的配置请求则会根据 TARGET_ABOVE_CONFIG_LIMITREG 字段的设置被定向至 ELBD 或 TRGTI 接口。
	- 您的应用程序必须根据扩展配置寄存器设置一个适当的值来此字段。 
- `TARGET_ABOVE_CONFIG_LIMIT_REG`
	- 具有大于 CONFIG_LIMIT REG 值的地址的配置请求将根据此字段的设置被定向到 ELBI 或 TRGTi 接口。此字段可具有以下值：
- `MASK_RADM_1[16]:CX_FLY_MASK_UR_FUNC_MISMATCH`
	- ![[5-Fabric 网络 cfg 报文路由出错.png]]


##### 波形定位

![[7-Fabric 网络 cfg 报文路由出错.png]]
![[6-Fabric 网络 cfg 报文路由出错.png]]