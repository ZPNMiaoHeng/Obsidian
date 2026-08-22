---
tags:
  - bug
time: 2026-05-13
path:
published: false
Done:
---
### 问题现象
复位打拍使用 cbb 模块，rst 输入 cbb 后输出是 x 态；CBB 内部调用标准寄存器 cell； 

### 问题根因
模块实例化时，输出接口 tie0，标准 cell 的输入是 1‘b1、输出是 1’b0，导致仿真时 cell 出现多驱问题，出现 x 态。

### 如何规避
1. 查看 vcs 编译 log，其中会有相关提示信息；
2. DFT 网表接口输出验证脚本生成，防止此类问题；