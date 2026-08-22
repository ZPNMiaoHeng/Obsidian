#spec 
# 术语
1. Manager：对应之前master，管理器；
2. Subordinate component：slave，下级组建，后续使用Subordinate 表示从机；
	1. Peripheral Subordinate Component：外围从属组件， Peripheral Subordinate。
		1. ⚠️：当非法访问Subordinate时，即使发生错误，访问失败；为了防止系统死锁，必须按照协议正确方式完成。
	2. Memory Subordinate component：内存从属组件，对内存进行操作；
	3. Interconnect component：具有多个AMBA接口的组件，该接口将一个或多个Manager组件连接到一个或多个从属组件。一个互连组件可以用于组合在一起:•一组管理器，使它们显示为单个管理器接口。•一组从属，以便它们显示为单个从属界面。
3. transaction：事务；
4. transfer：传输；
5. DMA：Direct Memory Access，直接内存访问；
6. AXI channl
	1. AW：Write request，写请求；
	2. W：Write data，写数据；
	3. B：Write response，写相应；
	4. AR：Read request，读请求；
	5. R：Read data，读数据；
7. bandwidth：带宽；
8. 一个AXI事务操作在主机和从机之间存在多个中间组件。相对于整个事务，对于任何中间组件，一个给定的事务；
	1. Upstream：上游，该组件和其上级组件；
	2. Downstream：下游，该组件和其目标从属组件；
# Part A
## Chapter A1 Introduction
1. 特点：
	1. 控制和数据分离；
	2. 支持使用`stobe`信号，完成数据字节不对齐传输；
	3. 使用只发出起始地址的突发事务； 
	4. 支持发射多个未完成的事务地址；
	5. 支持事务乱序完成；
	6. 支持使用寄存器打断组合路径，收敛时序；`Permits easy addition of register stages to provide timing closure.`
2. W通道中传输数据会被缓存，因此主机执行写事务时从机无需知道先前的写事务；
	1. Q：缓存机制是主机实现嘛；
3. 典型的系统拓扑
	1. 共享请求和数据通道；
	2. 共享请求通道和多个数据通道；
		1. 在大多数系统中，请求通道带宽需求明显小于数据带宽需求；
		2. 这样的系统可以通过使用具有多个数据通道的共享请求通道来实现并行数据传输，从而在系统性能和互连复杂性之间实现良好的平衡。
	3. 拥有多请求和数据通道的多层次架构；
4. 寄存器切片：每个AXI通道都是单方向传输信息，在架构上两个通道之间不需要任何固定的关系。这些特性意味着寄存器片几乎可以在任何通道的任何点插入，代价是额外的延迟周期。
	1. 时钟延迟和操作频率之间权衡；
	2. 在处理器和高性能存储器之间直接、快速的链接