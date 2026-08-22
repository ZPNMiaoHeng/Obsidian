#DC #Synopsys 

##### 综合后查看资源
- 原因：综合后的报告资源不准确，需要进入`DC`环境加载`DDC` 查看；
``` bash
make load_ddc  #综合环境加载 ddc
current_design #切换模块
sizeof_collection [get_flat_cell *] #查看当前TOP下的cell
sizeof_collection [get_flat_cell -fi "is_sequential ==true"] #查看当前TOP下的seq
```

![[1-DC.png]]
- 当前设计：base、limit![[2-DC.png]]