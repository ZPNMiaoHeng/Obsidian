#card 

##### 代码风格（学习）
###### 每次赋值前寄存器清空
![[Pasted image 20250106093301.png]]
- 为何不使用 assign 语句呢？而是每次将端口寄存器数据清空后再写入数据呢？

###### 寄存器赋值为何分开写？
![[Pasted image 20250106111000.png]]
##### QA
![[Pasted image 20250106091936.png]]
- 读写使能信号为何使用 penable 不同电平呢？

###### ？
![[Pasted image 20250106103416.png]]

###### 宏定义
![[Pasted image 20250106101639.png]]
- WDT_HC_RPL:HC 表示 hard code，是否为硬件写死。若是硬件写死的话，使用默认值，否则使用 wdt_cr 寄存器的值。
- WDT_HC_RMOD:
- 
###### WDT 新增额外功能：改写wdt使能

![[Pasted image 20250106100238.png]]
![[Pasted image 20250106100304.png]]
- ~~代码中只有写1操作，将 wdt 置为无效状态，怎么启用呢？只有APB复位，将wdt_control_en 初始化为0.~~
- 在后续寄存器赋值时，通过鉴权方式查看 wdt_control_en 是否有效（相当于开启一个可以更改内部寄存器权限的等级），可以更改 wdt 控制寄存器使能信号。
-


# 名词

| 缩写      | 全称                        | 解释             |
| ------- | ------------------------- | -------------- |
| TOP     | timeout period            | WDT 计数器超时周期。   |
| cnt     | counter value             | WDT 计数器的值。     |
| intr    | Interrupt                 | WDT 中断有效信号。    |
| restart | counter restart           | WDT 计数器重启使能信号。 |
| wdt_en  | timer enable              | WDT 计数器使能信号。   |
| eoi     | end of Interrupt          | 中断结束。          |
| rpl     | reset pulse length        | 复位脉冲长度。        |
| rmod    | output response mode      | 输出响应模式。        |
|         |                           |                |
| cr      | control reg               | 控制寄存器。         |
| torr    | timeout range reg         | 超时范围寄存器。       |
| ccvr    | current counter value reg | 保存当前计数器值的寄存器。  |
| stat    | status reg                | 状态寄存器。         |
| ver_id  | version id reg            | 版本号寄存器。        |
