#DDR #IC #SoC 
### DDR4 时序参数

|                                              |                                                                 |
| -------------------------------------------- | --------------------------------------------------------------- |
| tCCD_S(CAS_n to CAS_n Short Delay)           | **不同** Bank Group 的连续读或连续写命令之间较短的延迟时间。                          |
| tCCD_L(CAS_n to CAS_n Long Delay)            | **相同** Bank Group 的连续读或连续写命令之间较长的延迟时间。                          |
| CL(CAS Latency)                              | 列地址选通延迟时间，发送一个**列地址信号**到**数据开始响应**之间的延迟。                        |
| tRCD(ACT to read or write Command Delay)     | **激活命令**到**读写命令**之间需要间隔的时间。                                     |
| tRP(PRE command period）                      | 发送**预充电命令**到**激活下一行**的时间。                                       |
| tRAS(ACT to PRE command period)              | 发送**激活命令**到发送**预充电命令**之间需要间隔的周期时间。                              |
| tRC(Row Cycle time)                          | **一个行激活**到**下一个行激活**之间需要间隔的时间，其中包括了激活和预充电的时间。                   |
| tWR(Write Recovery time)                     | **一个激活的行完成写操作后**到**发送预充电命令**之间需要等待的时间，这个时间是为了保证数据可以被正确地写入内存单元中。 |
| tWTR(Write to Read command time)             | **写操作结束**到**发送读命令**之间需要等待的时间。                                   |
| tRTP(Read to Precharge delay)                | 对**一个激活的行发送读命令后**到**对此行发送预充电命令**之间需要等待的时间。                      |
| tRFC(Refresh command period)                 | **发送刷新命令**到**可以进行其他操作**的间隔时间，即刷新操作的时钟周期。                        |
| tREFI(Refresh Interval)                      | **两个刷新操作**之间的间隔时间。                                              |
| tMOD(Mode Register Set command update delay) | **发送配置模式寄存器命令**到**配置完成**的时间。                                    |
| AL                                           | 额外延迟时间。                                                         |
| tRPRE                                        |                                                                 |
| tRPST                                        |                                                                 |
|                                              |                                                                 |
- 这两个时序参数的区别在于连续读命令或者连续写命令的地址是否处于同一 Bank Group，由于每个 Bank Group 在内存中是独立运行的，所以不同Bank Group 执行读与写命令之间的时间约束会比较小。
- Q：
	- ![[Pasted image 20241021153519.png]]
	- tRPRE：read pre？
	- tRPST
