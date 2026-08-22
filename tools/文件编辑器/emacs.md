#tools 
### 语法
##### `AUTOSENSE`：
1. 自动添加敏感列表；
2. `/*AS*/`：always块中自动生成敏感列表；
##### `/*AUTOARG*/`：
1. 自动生成模块参数表；
2. 使用：模块端口表用/*AUTOARG*/创建，它会分析模块的input/output/inout语句，生成端口列表。
3. 可靠！！
##### `/*AUTOINST*/`
1. 自动实例化
2. 将会在自动链接模块端口，多比特的信号会显示
##### `/*AUTOWIRE*/`
1. 自动连接
2. 配置自动实例化，会生成wire类型多比特数据；
#####  `/*AUTOREG*/`
1. 自动生成reg类型；
2. 若模块的输出来自寄存器，信号不但要声明输出，还要声明寄存器类型。
##### `/*AUTORESET*/`
1. 给寄存器类型变量赋初值
#### 端口连接
如果输入信号来自顶层模块，子模块输出直接连到顶层模块，不具有其他逻辑功能
1. `AUTOINPUT` 
2. `AUTOOUTPUT` 
3. `AUTOINOUT` 

### 快捷键
1. `C-c C-a`：将AUTOs进行扩展；
2. `C-c C-s`：保存文件，扩展AUTO，调用编辑器；
3. `C-c C-k`：将所有自动添加的代码取消；

### 技巧
#### 找模块
- 顺序：
	1. 当前文件；
	2. 然后找 `module_name.v`；
	3. 最后找 `verilog-library-directories` 变量定义的每个目录；
```verilog
// Local Variables:
// verilog-library-directories:("." "subdir" "subdir2")
// verilog-library-files:("/some/path/technology.v" "/some/path/tech2.v")
// verilog-library-extensions:(".v" ".h")
// End:
```

#### 宏定义
- 当使用 `AUTOINST` 或 `AUTOSENSE`时，`Verilog-Mode`需要知道当前文件中定义了哪些宏，这样才能正确地解析模块，并知道哪些宏代表常量。如果你想用同一个文件的先前位置定义的宏的值，你可以自动读取它们：
```verilog
// Local Variables:
// eval:(verilog-read-defines)
// eval:(verilog-read-defines "group_standard_includes.v")
// End:
```
- 第一个`eval`读取当前文件中的所有`defines`，第二个`eval`读取指令文件中的 `define`。

#### 包含头文件
- 出于速度的考虑，Verilog-Mode不自动读取包含文件，也就是说 AUTOSENSE 不会把你在头文件中定义的常量做常量看，你可以让Verilog-Mode读取包含文件。
```verilog
// Local Variables:
// eval:(verilog-read-includes)
// End:
```


# REF
- [Emacs verilog-mode 的使用 – Wenhui's Rotten Pen](https://www.wenhui.space/docs/02-emacs/verilog_mode_useguide/)
- 
