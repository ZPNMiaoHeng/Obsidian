#card 
`ris:Time`

`rir:Todo`
###### 2024年11月30日10:45:33
- 原先给的 FPGA 例子工程种存储区使用 component 类型，但实现的 DFI2POI 模块按照2564 波形实现，是RDIMM 类型。
- 二者区别在于：RDIMM 内部含有寄存器、缓存，容量更大，但端口信号（cke、cs、odt）位宽更大