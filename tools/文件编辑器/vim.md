#tools 
# 原始版
## 快捷键
- `*`：向前搜索；
- `#`：向后搜索；
- `:nohlsearch`：关闭高亮；
- `gf`：跳转光标中的文件；
- `C-p`：自动补全；
### Vim多个文件
##### 窗口 windows
前缀：`C-w`
- s：拆分窗口；
- v：垂直拆分窗口；
- w：切换窗口；
- q：退出窗口；
- T：拆分为一个新标签；
- x：用下一个交换；
- -、+：减少、增加高度；
- <>：减少、增加宽度；
- |：最大宽度；
- =：同样高和宽
##### 缓冲区buffer
- `:tab ba`：将缓冲区变为标签tab；
- `:e file`：在缓冲区新建一个文件；
- `:bn`：跳转到下一个缓冲区；
- `:bp`：跳转到上一个缓冲区；
- `ls`：列出所有打开的缓冲区；
- `sp file`：打开和拆分窗口；
- `vs file`：打开和垂直拆分窗口；
##### 选项卡 tab
- `gt`：跳转上一个标签；
- `gT`：跳转上一个标签；
- `2gt`：转到标签2；

#### 终端
- `:terminal`：打开一个终端；
#### 其他
- `vU`：使用v选中后，使用U变为大写；
- `vu`：使用v选中后，使用u变为小写；
- N-mode`C-a`：计数器，加1；
-  N-mode`C-x`：计数器，减1；

#### 文件夹
- `Ex`：显示当前文件夹；
- `Vexplore`：打开文件目录；

## 配置
### netrw
```bash
let g:netrw_banner = 1             # 设置是否显示横幅 
let g:netrw_liststyle = 3          # 设置目录列表的样式：树形 
let g:netrw_browse_split = 4       # 在之前的窗口编辑文件，类似按下大写 P 
let g:netrw_altv = 1               # 水平分割时，文件浏览器始终显示在左边 
let g:netrw_winsize = 25           # 设置文件浏览器窗口宽度为 25% 
netrw augroup ProjectDrawer        
	autocmd! 
	autocmd VimEnter * :Vexplore 
augroup END                        # 自动打开文件浏览器 
```
### TODO
- [ ] 阅读手册，了解命令；