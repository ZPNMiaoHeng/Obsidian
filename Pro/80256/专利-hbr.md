五、技术方案描述
1、描述技术方案结构组成及每部分的功能和连接关系。
模板：本技术方案的结构包括X、X、XX、XXX四个部分，各部分的连接关系是，X与XX相连接，XXX通过XXXX连接到X,其中X的功能是：XX的功能是…，XXX的功能是…，XXX的功能是：…。（注：如果是几个部分的组合所形成的功能，只需阐述组合功能即可)，另外X由A、B、C组成，ABC的连接关系是…，XX由…组成，连接关系是…，（各部分的组成及连接关系)。

	本技术方案的结构包括NT Bridge和NT Virtual EndPoint两部分。非透明桥分为NTE和NTB两个模块，NTE是NT endpoint,每个VCS都会有一个NT endpoint,NT endpoint是由SOC虚拟出来的，主要完成scratch pad功能。SOC将NT endpoint的BAR基地址信息写入NTB内的BAR译码表，主要完成跨VCS域的地址、ID转换和doorbell,实现不同VCS之间的设备通信。
	
	将所有的NTDP/EP用SOC软件模拟实现，通过截获配置请求，为每个端口虚拟出一个 Virtual DP/Virtual EP,枚举完成后Virtual DP/Virtual EP的作用就是BAR译码，判断是否是访问NTB的报文送给NT Bridge,我们可以将BAR译码过程在NT Bridge实现，这样NT Bridge with BAR模块就可以放到UP端口下，而不是放到Virtual DP/Virtual EP下面； 
	NTB模块由地址转换表模块(Addr mapping tab|e)、ID转换表模块(ID mapping tab|e)、Doorbel I模块和非透明桥组播模块(Multicast)四部分组成。非透明桥单播模块的功能是由D转换表模块和地址转换表模块组成。非透明桥单播模块、Doorbe||模块、非透明桥组播模块三个模块并行访问，但只会命中其中一项的地址空间。

	其中地址转换表模块的功能保存当前Swicth下的非透明桥单播的地址空间，并提供另一个Swi©th下的地址转换后的基地址；ID转换表模块的功能是保存不同设备的总线信息，并且ID转换表中设备信息可扩展。Doorbe|I模块保存本 Switch内Doorbe l|功能对应地址空间，并记录另一Swicth的基地址和MS|报文信息，可以实现将对应类型的报文转换为MSI中断报文，用于通知另一Switch。非透明桥组播模块功能为记录T组播的地址空间，并计算出需要将此报文复制到挪些设备。)
	所有对NT endpoint的BAR访问首先会穿过NTB模块，命中BAR2~BAR5的报文会根据报文类型进行地址和ID转换，按照转换后的地址和D在Ingress中路由找到出口；命中 BARO~BAR1 Doorbell地址空间的报文，会根据doorbell产生MSI/MSIX中断报文；命中 BARO~BAR1 scratch pad功能地址空间报文会路由到NTE模块，访问NTE中的scratch pad寄存器；

2、工作原理
针对本技术方案所有的结构图（或电路图)对本技术方案的具体实施进行描述，在工作原理描述过程中，应尽量详细，并对解决现有技术中的问题和缺点部分尽可能地重点介绍。如果有流程图，应对流程作详细介绍。
(1)NT endpoint.
	NT endpoint完全由SOC虚拟化出来，Host枚举时将配置请求发送给SOC,SoC虚拟化 NT endpoint空间，并将NT endpoint BAR译码信息写填写到NT Bridge BAR decoder译码表；对应的BUS号填写到NT Bridge中寄存器保存。数据报文命中NT Bridge BAR decoder后通过 NT Bridge转换后再交给后续模块进行路由。·

(2)地址转换模式 
NT Bridge支持两种地址转换模式：直接地址转换和查表地址转换。
直接地址转换源地址上加上一个偏移offset得到目的地址，A-LUT查表(Address Loop-up Table)转换按照如下过程转换地址：
(1)去掉高位BAR Base Address;
(2)将BAR地址空间等分为N块大小相同的地址窗口，高位地址作为窗口index窗口index作为索引查A-LUT表，输出转换后translated base address;
(3)translated base address与offset拼在一起形成新的地址。

A-LUT查表只适合单个NTB的情况，当多个VCS的NTB共享同一张地址转换表，并且 BAR空间地址不是按照等分成N块进行转换，此时需要用TCAM实现，如下图所示，软件填写TCAM中的VCS、src addr base和addr mask,输入要转换的地址cs和src_addr到TCAM, TCAM的每一行会先通过src_addr&addr mask屏蔽掉低位的offset,然后与TCAM中ycs和 src addr base进行比较，输出命中的index,把index作为地址去索引一张与TCAM深度相等的SRAM,输出dst vcs、dst addr base和addr mask,按照如下公式计算转换后的地址：
· Translated addr=src_addr&(~addr_mask)+dst addr base 

(3)地址/ID转换过程
两个host各属于一个VCS,无论他们是否在同一个switch上，拓扑中总会有一个witchx被划分成两个VCS,NTB的地址转换发生在这个switchx,host通过操作switchx的NTB来实现两个VCS之间的互相访问。
hosto发出来BAR请求被发送到NTB Bridge模块，NTB对报文进行地址和ID转换，如下图所示，NTB BAR空间地址被划分为很多块，每一块对应一个目的VCS以及对应的NTB,地址转换通过线性转换或者查表转换，将VCS0的地址转换为目的VCS1的地址，同时得到VCS1的Dest NTB Bus号；

NTB Mem/VCS mapping表(8个VCS,每个VCS1个NTB,每个NTB的BAR2~BAR5用于地址转换，总计32个BAR,并支持IOMMU功能装载，表项深度512，总计可以划分为512个地址转换窗口，用TCAM实现)：

为了节省芯片面积，目的基地址和目的VCS使用SRAM实现。

NTB ID/VCS mapping表(128项，受限于index宽度，最多支持128个设备同时进行NTB传输，同时支持index和BDF查找，用寄存器实现，ID转换表是全局表，不同Hos的VCS号和BDF号可能重复，因此需要增加Host ID区分)：
Bus Segment是PCIe6.0新引入的总线D号扩展机制，Host为每个RC分配一个16位的 segment,每个segment下都可以有256条总线，这样总线的数量就被扩展了，可以继续使用SecBus/,SubBus路由机制。同一个Host下的多个segment之间的mem地址空间是统一编址的，不需要segment信息。NTB的lD转换增加segment字段，是否比较segment字段通过全局寄存器控制。

ID转换如下图，ID转换是通过NT ID/VCS mapping table进行的，NT ID/VCS mapping table里的每一项用VCS/Bus/Dev/Eunc唯一标识，每个设备在表中有且仅有一项。 
ID转换分为requester ID转换和completion ID转换，hosto发出的NTB请求通过 host0/VCS0/Bus0/Devo/Func0号查找NT mapping table,命中后输出NT mapping table的index号，用这个Index替换掉requester ID中的Dev/Eunc字段，Bus字段替换为NT mapping table输出的目的VCS1 Dest NTB Bus号Translated Requester ID,然后用新的Translated Requester ID和地址进入路由模块查找出口，最终就会被路由到目的VCS的出口，并按照目的VCS1的地址路由到达host1。
Host1返回读响应，读响应的completer ID为host1/Bus1/Dev1/Func1,requester ID为请求报文携带的Translated Requester ID,读响应报文将通过Translated Requester ID进行路由。当路由到Translated Requester ID里的BUS号等于switch NTB口的BUS号时，说明已经到达了能够回到VCs0的switchx,此时通过Translated Requester ID里index反向索引NT mapping table,得到VCs0/BUS0/DEVo/FUNC0/Src NTB Bus号，用BUs0/DEV0/FUNC0替换Translated Requester ID,用Src NTB Bus/Dev=0/Func=0替换Completer ID,然后送到Ingress通过 VCS0/BUS0/DEV0/FUNC0查找出口，返回到源VCS并通过requester ID路由到host0.。 

VCS0/Bus/Dev/Eunc的变化过程如下图：
DMA或者EP也可以通过NTB进行跨VCS的通信，NT mapping table是一张全局表，在每条流水线前都可以查NT mapping table,因此DMA模块可以依赖于NT function的位置。每个DMA endpoint有自己的BDF号，因此在ID转换表中要占用一项；
地址转换表是Host手动填写的，每个Host填写的内容可能不同：D转换表是全局的，所有的D转换表都是相同的，ID转换表可以有SOC自动填写，当NTB收到一个报文，命中了地址转换表，但是却没有命中D转换表，这种报文就要转发给SOC,SOC提取报文中 Request ID里的BDF号，填写到ID转换表里，然后SOC把报文路由到出口；后续同样Request D的报文就会命中D转换表；

## doorbell中断
NTB还需要支持doorbell产生中断，软件写BAR doorbell寄存器时查表将其转换为目的 VCS域的MSl/MSIX中断。
Doorbell实现在NTE模块一个问题是，中断报文产生与NTB数据之间可能会出现乱序，例如host0先向host1发送NTB数据，数据发完后，马上敲一下doorbell寄存器，NTB数据会直接被路由到host1所在出口的SW OQ buffer0里，但是doorbell会被路由到Synthetic Subsystem NT模块，NT模块产生中断报文会送到host1所在出口的另外一个SW OQ buffer1里，两个OQ buffer虽然都是去同一个出口station,但是他们之间调度的时候不能保证顺序，有可能OQ buffer?1的doorbell会跑到OQ buffer0的data前面，导致软件出错。
解决方法：在Ingress NTB模块实现若干个doorbell寄存器，每个doorbel‖寄存器对应对应若干个MSI/MSIX寄存器，软件在枚举NTB时由SOC填写好MS1/MSIX地址； Host敲Doorbell的时候产生一个特殊MSl/MSIX PD,doorbell报文被转换为MSl/MSIX消息，由dice构造MSl/MSIX报文发送出去；
Doorbell占用一段连续的BAR1地址空间，因此每个VCS只需要一个Doorbell base和 Doorbell mask寄存器 NTB就能够判断Host是否在写Doorbel‖寄存器 Doorbell addr-Doorbell base得到Doorbell offset,通过Doorbell offset查MSl/MSIX addr/data表，产生MSI/MSIX PD:
根据源ycs号查doorbell table,并且Doorbell addr&Doorbell_mask=Doorbell base则表示是一个doorbell写报文；
Doorbell_addr-Doorbell_base得到Doorbell_offset,如果msi/msix table深度为256，则通过msi table base+Doorbell_offset[7:o]查MSl/MSIX addr/data表，产生Msl/MSIX PD;

## Scatch pad
Scratchpad白板寄存器是一块共享的寄存器空间，每个host写入Scratchpad的数据可以被其他host读出来；Scratchpad在NTB endpoint用一块memory实现，所有host对scratchpad寄存器的写都写入这块共享的memory:
NTE模块只实现scratchpad功能，使用BARo实现scratchpad,NTB查addr/ID/doorbell表都未命中的报文，在PCle单播路由中会命中NT endpoint所在DP的mem base/limit空间，这些报文会被路由到SOC;