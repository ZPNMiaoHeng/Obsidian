### csr table
- csr table 和 80 table不同，80 table 如何实现软件写呢？
- csr_table_access 是什么呢？

### csr_chain_leaf
主要功能将 csr-cmd 转换为内部节点寄存器读取；
- 支持寄存器打拍输入可配；
- 判断 csr-chain 是否命中对应 csr 节点（reg_addr_prefix），并将输出节点内寄存器读写命中；
- 支持 csr 节点超时上报；
	- 发生原因：命中当前 csr 节点，
	- reg_wt_cmp 无效；