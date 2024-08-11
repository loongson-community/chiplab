# 基于Chiplab的龙芯杯团体赛开发环境 
## 1. 前言
Chiplab支持龙芯杯团体赛的功能测试与性能测试，有关Chiplab的完整介绍请参考[CHIPLAB使用介绍](https://chiplab.readthedocs.io/)

## 2. 目录结构
.   
├── chip&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;SoC顶层。    
│　　└── soc_demo&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;SoC顶层代码实例。   
│　　　　　├── nscscc-team&emsp;&emsp;&emsp;&ensp;<font color='red'>龙芯杯SoC顶层代码。</font>   
│　　　　　　　　├── axi_wrap&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;<font color='red'>cpu axi 接口包装一层，使仿真和上板 axi 访问行为一致。</font>   
│　　　　　　　　├── CONFREG&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>confreg 模块，连接 CPU 与开发板上数码管、拨码开关等 GPIO 类设备。</font>   
│　　　　　　　　├── ram_wrap&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>axi ram 的封装层，增加固定延迟设置。</font>   
│　　　　　　　　├── uart_debug&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>串口下载模块。</font>   
│　　　　　　　　├── xilinx_ip&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>Xilinx IP，包含 clk_pll、axi_crossbar_2x3。</font>  
│　　　　　　　　├── soc_axi_lite_top.v&emsp;&emsp;<font color='red'>SoC_lite 的顶层。</font>  
│　　　　　　　　├── soc_config.vh&emsp;&emsp;&emsp;&ensp;<font color='red'>配置SoC为功能测试或性能测试的头文件。</font>  
│　　　　　├── loongson&emsp;&emsp;&emsp;&ensp;龙芯实验箱SoC顶层代码。   
│　　　　　├── Baixin&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;百芯开发板SoC顶层代码。   
│　　　　　└── sim&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;仿真SoC顶层代码   
├── fpga&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;综合工程。   
│　　├── nscscc-team&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>龙芯杯fpga工程及所需嵌入式软件。</font>   
│　　　　　├── run_vivado&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>Vivado工程目录</font>   
│　　　　　　　　├── constraints&emsp;&emsp;&emsp;&emsp;<font color='red'>约束文件</font>   
│　　　　　　　　├── testbench&emsp;&emsp;&emsp;&emsp;<font color='red'>前仿测试文件</font>   
│　　　　　　　　├── create_project.tcl&emsp;&emsp;&emsp;<font color='red'>Vivado工程创建脚本</font>    
│　　　　　　　　├── run_func_test.tcl&emsp;&emsp;&emsp;<font color='red'>运行功能测试脚本</font>    
│　　　　　　　　├── run_allbench.tcl&emsp;&emsp;&emsp;<font color='red'>运行性能测试脚本</font>    
│　　　　　└── software&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>Vivado中前仿/上板所需嵌入式软件</font>   
│　　　　　　　　├── func&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>功能测试</font>   
│　　　　　　　　　　　├── Makefile&emsp;&emsp;&emsp;<font color='red'>生成功能测试所需obj使用的编译脚本</font>   
│　　　　　　　　└── perf&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>性能测试</font>   
│　　　　　　　　　　　├── bench&emsp;&emsp;&emsp;&emsp;<font color='red'>性能测试c源码</font>   
│　　　　　　　　　　　├── include&emsp;&emsp;&emsp;&emsp;<font color='red'>性能测试头文件</font>   
│　　　　　　　　　　　├── lib&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>性能测试所需c库</font>   
│　　　　　　　　　　　├── obj&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>性能测试编译结果</font>   
│　　　　　　　　　　　├── bin.lds.S&emsp;&emsp;&emsp;&emsp;<font color='red'>交叉编译的链接脚本源码</font>   
│　　　　　　　　　　　├── convert.c&emsp;&emsp;&emsp;&emsp;<font color='red'>生成 coe 和 mif 文件的本地执行程序源码</font>   
│　　　　　　　　　　　├── start.s&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>主函数</font>   
│　　　　　　　　　　　├── Makefile&emsp;&emsp;&emsp;&emsp;<font color='red'>性能测试编译脚本</font>   
│　　├── loongson&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;龙芯实验箱综合工程。   
│　　　　　├── 2019.2&emsp;&emsp;&emsp;&emsp;对应Vivado 2019.2版本。   
│　　　　　└── 2023.2&emsp;&emsp;&emsp;&ensp;对应Vivado 2023.2版本。   
│　　└── Baixin&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;百芯开发板综合工程。   
├── IP&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;SoC IP。   
│　　├── AMBA&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;总线 IP。    
│　　├── APB_DEV&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;APB协议通信设备。    
│　　　　　├── URT&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;UART设备控制器。   
│　　　　　└── NAND&emsp;&emsp;&emsp;&emsp;&emsp;NAND设备控制器。   
│　　├── AXI_DELAY_RAND&emsp;&emsp;随机延迟注入。    
│　　├── AXI_SRAM_BRIDGE&emsp;&ensp;AXI协议 -> SRAM接口转换。    
│　　├── BRIDGE&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;1x2桥接模块。    
│　　├── DMA&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;DMA逻辑，用于设备作为master访问内存。    
│　　├── SPI&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;SPI Flash设备控制器。    
│　　├── MAC&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;MAC设备控制器。    
│　　├── CONFREG&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;用于访问开发板上数码管、拨码开关等外设以及特殊寄存器。   
│　　├── myCPU&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>处理器核逻辑。</font>  
│　　└── xilinx_ip&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;Vivado平台所创建的IP。   
│　　　　　├── 2019.2&emsp;&emsp;&emsp;&emsp;对应Vivado 2019.2版本。   
│　　　　　└── 2023.2&emsp;&emsp;&emsp;&ensp;对应Vivado 2023.2版本。   
├── sims&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;运行仿真以及存放testbench源码。   
│　　└── verilator&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;以verilator仿真工具为基础。   
│　　　　　├── run_prog&emsp;&emsp;&emsp;&emsp;测试程序运行目录，包括func、性能测试程序、内核等。   
│　　　　　├── run_random&emsp;&emsp;&ensp;随机指令序列运行目录。   
│　　　　　└── testbench&emsp;&emsp;&emsp;&ensp;testbech源码，提供仿真运行、在线比对、设备模拟等功能。   
├── software&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;测试用例。   
│　　├── coremark&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;coremark性能测试程序。   
│　　├── dhrystone&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;dhrystone性能测试程序。  
│　　├── func&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<font color='red'>功能测试点，验证处理器核设计是否与指令手册一致，龙芯杯也使用该目录的c源码进行功能测试。</font>   
│　　├── linux&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&ensp;提供内核启动的支持。   
│　　├── random_boot&emsp;&emsp;&emsp;&emsp;&emsp;为随机指令序列的运行提供支持。   
│　　├── random_res&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;存放随机指令序列。   
│　　└── generic&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;通用的编译脚本。   
└── toolchains&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;chiplab运行所需工具。    
　　　├── loongarch32r-linux-gnusf-\*&emsp;&emsp;&emsp;gcc工具链。  
　　　├── nemu&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;nemu模拟器，用于在线实时比对。   
　　　└── system_newlib&emsp;&emsp;&emsp;&emsp;newlib C库，用于编译C程序。

## 3. 环境下载与安装
### 3.1 下载本仓库
因包含submodule，需要将submodule的特定commit也一并clone下来，注意不要在中文目录下clone

`git clone --recurse-submodules -j4 https://gitee.com/loongson-edu/chiplab`

### 3.2 toolchains工具下载
toolchains这个目录是存在的，只不过里面是空的，需要用户自行下载，详情请参考`toolchains/README.md`。

### 3.3 项目所需第三方工具安装
以Ubuntu (Windows 10+ 请基于WSL**2**)为例:

```
# 终端运行
sudo apt install verilator gtkwave #verilator version 4.224 (loongarch64 4.222+)    
```

## 4. 实验步骤

### 4.1 基于verilator进行功能测试的前仿真
#### 4.1.1 参数设置
设置CHIPLAB_HOME系统变量  

```
# 终端运行
export CHIPLAB_HOME="your own chiplab pwd address"
```
#### 4.1.2 替换myCPU
`IP/myCPU`中存放的是处理器核代码，对外的接口和核顶层模块名称固定。该环境默认处理器核已实现`AXI`总线。
```verilog
module core_top(
    input           aclk,
    input           aresetn,
    input    [ 7:0] intrpt, 
    //AXI interface 
    //read reqest
    output   [ 3:0] arid,
    output   [31:0] araddr,
    output   [ 7:0] arlen,
    output   [ 2:0] arsize,
    output   [ 1:0] arburst,
    output   [ 1:0] arlock,
    output   [ 3:0] arcache,
    output   [ 2:0] arprot,
    output          arvalid,
    input           arready,
    //read back
    input    [ 3:0] rid,
    input    [31:0] rdata,
    input    [ 1:0] rresp,
    input           rlast,
    input           rvalid,
    output          rready,
    //write request
    output   [ 3:0] awid,
    output   [31:0] awaddr,
    output   [ 7:0] awlen,
    output   [ 2:0] awsize,
    output   [ 1:0] awburst,
    output   [ 1:0] awlock,
    output   [ 3:0] awcache,
    output   [ 2:0] awprot,
    output          awvalid,
    input           awready,
    //write data
    output   [ 3:0] wid,
    output   [31:0] wdata,
    output   [ 3:0] wstrb,
    output          wlast,
    output          wvalid,
    input           wready,
    //write back
    input    [ 3:0] bid,
    input    [ 1:0] bresp,
    input           bvalid,
    output          bready,

    //debug
    input           break_point,//无需实现功能，仅提供接口即可，输入1’b0
    input           infor_flag,//无需实现功能，仅提供接口即可，输入1’b0
    input  [ 4:0]   reg_num,//无需实现功能，仅提供接口即可，输入5’b0
    output          ws_valid,//无需实现功能，仅提供接口即可
    output [31:0]   rf_rdata,//无需实现功能，仅提供接口即可

    //debug info
    output [31:0] debug0_wb_pc,
    output [ 3:0] debug0_wb_rf_wen,
    output [ 4:0] debug0_wb_rf_wnum,
    output [31:0] debug0_wb_rf_wdata
);
```
#### 4.1.3 仿真
仿真的工作目录位于`sims/verilator/run_*`，当前仅支持`verilator`。
- `run_prog` : 该工作目录下可运行`func`测试用例、`dhrystone`、`coremark`性能测试程序、`linux`以及自定义C程序。
- `run_random` : 该工作目录下可进行随机指令序列测试。 

具体使用方法请参考[verilator仿真环境说明](https://chiplab.readthedocs.io/zh/latest/Simulation/verilator.html)。

需要注意的是，在运行func测试时，需根据处理器核情况更改`chiplab/software/func/func_src/Makefile`中第四行`CACHEFLAGS = -Dhas_cache=0`，为0时，start.s 不使用 cacop指令。

### 4.2 基于Vivado进行功能测试和性能测试的前仿真

1）【myCPU加入】首先确保已经替换`IP/myCPU`中的处理器核代码

2）【编译software】发布包默认提供编译好的obj。

特别注意：功能测试和性能测试发布包中默认提供的obj为无chache版本，若实现了cache和cacop指令，需要将`chiplab/fpga/nscscc-team/software/perf/Makefile`文件的第二行改为`AFLAGS+=-Dhas_cache=1`。将`chiplab/fpga/nscscc-team/software/func/Makefile`文件的第七行改为`CACHEFLAGS = -Dvivado -Dhas_cache=1`。该宏置为1后会使用cacop指令在每次复位后执行cache初始化。

之后重新编译性能测试：

```
cd $CHIPLAB_HOME/fpga/nscscc-team/software/perf #进入性能测试目录
make clean                                      #清除已有编译结果
make                                            #执行性能测试编译
```

重新编译功能测试：

```
cd $CHIPLAB_HOME/fpga/nscscc-team/software/func #进入功能测试目录
make clean                                      #清除已有编译结果
make                                            #执行功能测试编译
```

完成编译后，在fpga/nscscc-team/software/func/obj目录下可以看到功能测试的编译结果

| 文件名     | 解释     |
| -------- | -------- |
| main.elf | 生成的可执行文件，属于中间文件 |
| rom.vlog | verilator仿真所需的内存初始化文件 |
| main.bin | 由main.elf生成的二进制文件，包含代码、数据段，用于 vivado 前仿和上板下载 |
| test.s   | 对 main.elf 反汇编得到的文件，可根据其中的PC和指令码用于调试 |
| inst_ram.mif | Memory Initialization File 文件 |
| inst_ram.coe | 重新定制vivado ip核 axi ram 所需的 coe 文件 |

在fpga/nscscc-team/software/perf/obj的各子目录存放性能测试的编译结果

| 子目录     | 解释     |
| -------- | -------- |
| allbench | 联合编译结果。包含 20 个测试程序的源码，用于综合实
现并上板。 |
| bitcount | 独立编译结果。仅包含 bitcount 测试程序。 |
| bubble_sort | 独立编译结果。仅包含 bubble_sort 测试程序。 |
| coremark   | 独立编译结果。仅包含 coremark 测试程序。 |
| crc32 | 独立编译结果。仅包含 crc32 测试程序。 |
| dhrystone | 独立编译结果。仅包含 dhrystone 测试程序。 |
| quick_sort | 独立编译结果。仅包含 quick_sort 测试程序。 |
| select_sort | 独立编译结果。仅包含 select_sort 测试程序。 |
| sha | 独立编译结果。仅包含 sha 测试程序。 |
| stream_copy | 独立编译结果。仅包含 stream_copy 测试程序。 |
| stringsearch | 独立编译结果。仅包含 stringsearch 测试程序。 |
| fireye_A0 | 独立编译结果。仅包含 fireye_A0 测试程序。 |
| fireye_B2 | 独立编译结果。仅包含 fireye_B2 测试程序。 |
| fireye_C0 | 独立编译结果。仅包含 fireye_C0 测试程序。 |
| fireye_D1 | 独立编译结果。仅包含 fireye_D1 测试程序。 |
| fireye_I2 | 独立编译结果。仅包含 fireye_I2 测试程序。 |
| inner_product | 独立编译结果。仅包含 inner_product 测试程序。 |
| lookup_table | 独立编译结果。仅包含 lookup_table 测试程序。 |
| loop_induction | 独立编译结果。仅包含 loop_induction 测试程序。 |
| my_memcmp | 独立编译结果。仅包含 my_memcmp 测试程序。 |
| minmax_sequence | 独立编译结果。仅包含 minmax_sequence 测试程序。 |

各子目录中具体编译得到的文件如下：

| 文件名     | 解释     |
| -------- | -------- |
| main.elf | 生成的可执行文件，属于中间文件 |
| inst_data.bin | 由main.elf生成的二进制文件，包含代码、数据段，用于 vivado 前仿和上板下载 |
| test.s   | 对 main.elf 反汇编得到的文件，可根据其中的PC和指令码用于调试 |
| axi_ram.mif | Memory Initialization File 文件 |
| axi_ram.coe | 重新定制vivado ip核 axi ram 所需的 coe 文件 |

3）【创建Vivado工程】打开Vivado，在下方的控制台Tcl Console中，首先切换目录至`fpga/nscscc-team/run_vivado`，再调用create_project.tcl脚本。具体命令如下：

```
cd $CHIPLAB_HOME/fpga/nscscc-team/run_vivado
source create_project.tcl
```

脚本执行完成后，再手动添加myCPU代码至工程中

4）【执行Run Linter进行RTL分析】成功建立Vivado工程后可以先运行左侧的Run Linter进行语法检查。

5）【进行功能测试仿真】

首先修改 `$CHIPLAB_HOME/chip/soc_demo/nscscc-team/soc_config.vh`头文件，打开 `RUN_FUNC_TEST`宏，关闭`RUN_PERF_TEST`宏。

之后在Vivado中点击Run Simulation。打开仿真界面后在控制台Tcl Console中执行下列命令，进行地址切换与调用tcl脚本执行仿真：

```
cd [get_property DIRECTORY [current_project]]
source ../run_func_test.tcl
```

功能测试包含58个测试点，应看到Vivado控制台打印信息`Number 8'd58 Functional Test Point PASS!!!`，证明功能测试前仿真通过。另外还可通过观察波形的方式判断仿真结果，具体可参考《CPU设计实战：LoongArch版》中[func测试仿真验证结果判断](https://bookdown.org/loongson/_book3/chapter-single-cycle-cpu.html#func%E6%B5%8B%E8%AF%95%E4%BB%BF%E7%9C%9F%E9%AA%8C%E8%AF%81%E7%BB%93%E6%9E%9C%E5%88%A4%E6%96%AD)

5）【进行性能测试单个测试用例仿真】

首先修改 `$CHIPLAB_HOME/chip/soc_demo/nscscc-team/soc_config.vh`头文件，打开 `RUN_PERF_TEST`宏，关闭`RUN_FUNC_TEST`宏。

在性能测试中，还需要注意`$CHIPLAB_HOME/chip/soc_demo/nscscc-team/soc_config.vh`头文件中的`RUN_PERF_NO_DELAY`宏。打开该宏后，可以关闭 AXI RAM 的固定延时机制，以加快仿真。性能测试分数提交应当是关闭`RUN_PERF_NO_DELAY`宏的分数。

在Vivado中点击Run Simulation。打开仿真界面后在控制台Tcl Console中执行下列命令，进行地址切换、更换内存初始化文件、重新开始仿真。

```
cd [get_property DIRECTORY [current_project]]
file copy -force ../../software/perf/obj/stream_copy/axi_ram.mif ./loongson.sim/sim_1/behav/xsim/axi_ram.mif
restart
run all
```

例子中给出的是执行用时较短的 stream_copy 测试用例，执行其它性能测试用例，修改该字段即可。

如果性能仿真正确运行，在控制台Tcl Console里可以看到类似如下打印信息
```
Test begin!
…(不同程序有不同打印)
… PASS!... (不同程序有所不同)
…: Total Count =…(不同程序有所不同)
```

6）【进行性能测试全部测试用例仿真】
可直接使用tcl脚本对性能测试所有程序执行仿真，控制台命令如下：
```
cd [get_property DIRECTORY [current_project]]
source ../run_allbench.tcl
```
看到控制台输出stringsearch测试通过后，证明所有性能测试完成。

### 4.3 基于Vivado进行综合实现

#### 4.3.1 功能测试上板验证
1）功能/性能测试宏修改

首先修改 `chiplab/chip/soc_demo/nscscc-team/soc_config.vh`头文件，打开 `RUN_FUNC_TEST`宏，关闭`RUN_PERF_TEST`宏。

2）修改 IP Sources -> axi_ram -> Other Options -> COE File。之后进行综合、实现、bit生成。(串口下载出错的同学请通过 axi_ram 初始化进行 software 切换)

3）下载bit文件

4）通过UART下载bin文件

UART下载功能移植自[tinyriscv](https://gitee.com/liangkangnan/tinyriscv/)，修改了axi总线支持。

使用脚本：`chiplab/fpga/nscscc-team/software/uart_downloader.py`进行下载，在`chiplab/fpga/nscscc-team/software`目录下执行下载命令：

在Windows环境下：

`python .\uart_downloader.py 串口号 bin文件`

例如

`python .\uart_downloader.py COM3 D:\chiplab\fpga\nscscc-team\software\func\obj\main.bin`

在Linux环境下：

`python3 ./uart_downloader.py 串口号 bin文件`

例如

`python3 ./uart_downloader.py /dev/ttyUSB0 ./func/obj/main.bin`

bin文件下载完成后会自动复位处理器核，即可看到实验现象。若执行完成当前测试希望进行下一个测试，直接运行新测试bin的下载命令即可。

另外该脚本支持复位命令，发送后对处理器核与confreg进行复位

在Windows环境下：

`python .\uart_downloader.py 串口号 reset`

在Linux环境下：

`python3 ./uart_downloader.py 串口号 reset`

5）观察实验现象
在FPGA上板验证时其结果正确与否的判断只有一种方法，func正确的执行行为是：

1.开始，单色LED全灭，双色LED灯一红一绿，数码管显示全0；

2.执行过程中，单色LED全灭，双色LED灯一红一绿，数码管高8位和低8位同步累加；

3.结束时，单色LED全灭，双色LED灯亮两绿，数码管高8位和低8位数值相同，对应测试功能点数目，龙芯杯功能测试应在数码管上出现3A 00 00 3A。

如果func执行过程中出错了，则数码管高8位和低8位第一次不同处即为测试出错的功能点编号，且最后的结果是单色LED全亮，双色LED灯亮两红，数码管高8位和低8位数值不同。

另外，可通过修改拨码开关switch值调整程序执行速度，从而看到完整的数码管数字递增。

#### 4.3.2 性能测试上板验证
1）功能/性能测试宏修改

首先修改 `chiplab/chip/soc_demo/nscscc-team/soc_config.vh`头文件，打开 `RUN_PERF_TEST`宏，关闭`RUN_FUNC_TEST`宏，关闭`RUN_PERF_NO_DELAY`宏。

2）修改 IP Sources -> axi_ram -> Other Options -> COE File。之后进行综合、实现、bit生成。(串口下载出错的同学请通过 axi_ram 初始化进行 software 切换)

3）下载bit文件

4）通过UART下载bin文件

可以下载单个性能测试bin文件，如：

`python .\uart_downloader.py COM3 D:\chiplab\fpga\nscscc-team\software\perf\obj\bitcount\inst_data.bin`

下载完成后自动复位执行，如果性能测试上板正确运行，双色 LED 灯全变为绿色，16 个单色 LED 全灭。如果性能测试的功能错误，双色 LED 灯会变成一绿一红，16 个单色 LED 灯全亮。无论功能是否正确都会在数码管上显示计数周期。

也可以下载allbench的性能测试bin文件，通过拨码开关确定进行的测试程序，如：

`python .\uart_downloader.py COM3 D:\chiplab\fpga\nscscc-team\software\perf\obj\allbench\inst_data.bin`

下载 allbench 的 bin 文件后，在实验板上使用 8 个拨码开关的右侧 4 个选择运行哪个测试，随后按复位键，开始运行由拨码开关指定的测试。约定拨码开关拨上为 1，拨下为 0，则 4 个拨码开关与性能测试程序的对应关系如下表。

| 序号     | 运行的测试程序     | 拨码开关状态     |
| -------- | -------- | -------- |
| 1 | bitcount | 5'b0_0001 |
| 2 | bubble_sort | 5'b0_0010 |
| 3 | coremark | 5'b0_0011 |
| 4 | crc32 | 5'b0_0100 |
| 5 | dhrystone | 5'b0_0101 |
| 6 | quick_sort | 5'b0_0110 |
| 7 | select_sort | 5'b0_0111 |
| 8 | sha | 5'b0_1000 |
| 9 | stream_copy | 5'b0_1001 |
| 10| stringsearch | 5'b0_1010 |
| 11| fireye_A0 | 5'b0_1011 |
| 12| fireye_B2 | 5'b0_1100 |
| 13| fireye_C0 | 5'b0_1101 |
| 14| fireye_D1 | 5'b0_1110 |
| 15| fireye_I2 | 5'b0_1111 |
| 16| inner_product | 5'b1_0000 |
| 17| lookup_table | 5'b1_0001 |
| 18| loop_induction | 5'b1_0010 |
| 19| my_memcmp | 5'b1_0011 |
| 20| minmax_sequence | 5'b1_0100 |
| 其它| 不运行性能测试 | 其它 |

#### 4.3.3 关于 Windows + WSL2 进行串口下载的说明

如果使用 Windows + WSL2，希望从 WSL2 中进行串口下载，需要参照微软的[连接USB设备](https://learn.microsoft.com/zh-cn/windows/wsl/connect-usb)，在Windows上安装usbipd-win，并将对应的USB设备附加到WSL2中。

Windows下设置需要加载的USB设备，常用命令如下：

`usbipd list` 查看USB设备列表

`usbipd bind --busid <busid>` 共享设备

`usbipd attach --wsl --busid <busid>` 加载对应设备到WSL

`usbipd detach --busid <busid>` 从Windows中断开设备

`usbipd detach --busid <busid>` 从WSL2中归还设备至Windows

之后在 WSL2 中，首先安装环境：

```
sudo apt install linux-tools-generic hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/6.8.0-39-generic/usbip 20
```

其中第二条命令中的`6.8.0-39`需要根据第一条`sudo apt install linux-tools-generic hwdata`安装的版本号进行修改

之后在WSL2中查看USB设备，使用命令`lsusb`后，应能看到`Bus 001 Device 004: ID 0403:6001 Future Technology Devices International, Ltd FT232 Serial (UART) IC`，代表已经读取到USB设备。使用命令`ls /dev/ttyUSB*`查看串口号，即可使用该串口进行下载。

#### 4.3.4 CPU 频率调整

性能测试统计的是 myCPU 运行性能测试程序实际花费的时间，其原理是：测试换 SoC_AXI_Lite 里设置了一
个固定 100MHz 的计时器，在运行性能测试程序的前后读取该计时器，其差值就是运行这一性能测试程序的所花费的实际时间。因而需要大家自行调整 SoC_AXI_Lite 里的 cpu_clk，使其为 myCPU 支持的最高频率，以获取最高性能分。调整 cpu_clk 的方法为：

双击Vivado工程中的`clk_pll`IP核，重新定制，在 `IP 定制界面->Output Clocks`修改 `clk_out1`的`Output Freq`。不允许修改`clk_out2`。完成修改后可重新进行综合、实现、bit生成。

调整 cpu_clk 后，一定要注意综合实现生成 bit 流文件后，Implementation 栏的 WNS 不允许为负值。
当 WNS 为负值时，表示设计中有违约路径，该栏也会显示为红色。在此提醒大家：

(1) WNS 为负值，生成的 bit 流文件也可能是能够正确运行的。但是比赛统一约定，不允许 WNS 为负值。

(2) 通常 SoC 里 uncore 部分不会成为违约路径，但如果发现 myCPU 没有违约路径，WNS 却为负值，这也是不被允许的。比赛统一约定，不允许 WNS 为负值。

(3) myCPU 一定是嵌入到性能测试环境 SoC_AXI_Lite 里综合实现后 WNS 非负值。如果预赛提交作品不满足该项，性能测试分记为 0 分。

#### 4.3.5 综合、实现的优化参数不允许修改

大赛统一要求：不允许自行修改综合、实现、生成 Bit 流文件时候的参数，也不允许修改约束文件 soc_lite.xdc。

所以在生成 Bit 流文件准备上板时，必须按照发布包里的工程设置完成综合、实现的步骤。

我们在评审预赛作品时，会严格按照发布包里的环境进行综合、实现并查看上板情况，如果有时序违约，按
照“预赛提交说明.pdf”，得分会记为 0 分。

在新的发布包里，我们已经性能测试环境 perf_test/soc_axi_pref 里的综合、实现策略实现为性能优化优先。

之所以不允许大家再修改编译参数，是因为时间有限，不希望大家将时间浪费在尝试（调试）综合、实现各
种参数以获得最高频率。其实再精细优化综合、实现的参数，也最多只能再获得少许的频率提升。我们希望大家将时间尽量花在有意义的事情上，比如设计 myCPU 之上运行的应用、系统等。
