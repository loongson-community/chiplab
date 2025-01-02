## 1. 总述

本目录包含板级支持包bsp和示例程序examples，示例程序支持在qemu中运行、在verilator中使用nemu进行difftest前仿、在龙芯杯SoC中Vivado前仿与FPGA上板。

bsp中包含三个文件夹——drivers、env、include。drivers用于保存外设驱动程序，目前仅包含CONFREG中的TIMER的驱动，用于获取时间。env文件夹中包含启动文件start.s、链接脚本separate.lds、bin转mif和coe的C程序convert.c。include是板级支持包的头文件目录。common.mk是公用Makefile，用于将板级支持包的内容添加进编译过程中。

## 2. 使用picolibc/newlib

Makefile默认使用picolib，若使用newlib，首先将`examples/*/Makefile`文件中的

`PICOLIBC_DIR=../../../toolchains/picolibc`

改为

`PICOLIBC_DIR=../../../toolchains/newlib`

之后将`bsp/common.mk`文件中的`LDFLAGS`和`QEMU_LDFLAGS`的

`-lsemihost` 

替换为

`-lgloss`
 
完成修改，此时调用的是newlib库

## 3. 尝试一下Hello World吧

### 3.1 在QEMU中运行
```
$ cd $CHIPLAB_HOME/software/examples/hello_world
$ make clean
$ make qemu
```
此时就可以在终端中看到`Hello Loongarch32r!`了。使用QEMU可以帮助我们判断写的嵌入式软件是否正确。

注一：由于目前的Makefile不支持增量make，建议先`make clean`再`make`。
注二：`make qemu`调用的链接脚本是独特的，因此`make qemu`获得的`obj`无法用于前仿和FPGA。

### 3.2 在Verilator中前仿
```
$ cd $CHIPLAB_HOME/sims/verilator/run_prog
$ ./configure.sh --run hello_world
$ make clean
$ make
```
同样可以在终端中看到`Hello Loongarch32r!`，也可以从`$CHIPLAB_HOME/sims/verilator/run_prog/log/hello_world/uart_output.txt.real`中查看记录到文件的打印信息。

注三：由于nemu不支持rdcntvl.w指令，而c_prg中的程序调用了clock()函数，该函数使用rdcntvl.w指令实现，因此目前c_prg中的程序暂时无法在Verilator环境下仿真。

### 3.3 使用龙芯杯SoC在Vivado中前仿

由于龙芯杯前仿的testbench在终端中输出时使用的是CONFREG模拟的UART，因此首先将`software/examples/hello_world/main.c`中全局变量`UART_BASE`设为0，此时不再使用UART16550，而是读取全局变量`CONFREG_UART_BASE`向模拟UART输出。

之后
```
$ cd $CHIPLAB_HOME/software/examples/hello_world
$ make clean
$ make
```
得到的obj文件夹中的mif文件和coe文件就可以用作vivado前仿真。

在Vivado中点击Run Simulation。打开仿真界面后在控制台Tcl Console中执行下列命令，进行地址切换、更换内存初始化文件、重新开始仿真。

```
cd [get_property DIRECTORY [current_project]]
file copy -force ../../../../software/examples/hello_world/obj/axi_ram.mif ./loongson.sim/sim_1/behav/xsim/axi_ram.mif
restart
run all
```
之后就能在vivado终端中看到`Hello Loongarch32r!`

### 3.4 使用龙芯杯SoC在FPGA上运行
在FPGA上运行时需要使用真串口UART16550进行输出，因此首先将`software/examples/hello_world/main.c`中全局变量`UART_BASE`设为`0xbfe001e0`。

之后
```
$ cd $CHIPLAB_HOME/software/examples/hello_world
$ make clean
$ make
```
得到的obj文件夹中的hello_world.bin文件可以用来串口下载至ram中，使用的串口下载上位机软件是本目录下的`uart_downloader.py`.

在Windows环境下：

`python .\uart_downloader.py 串口号 bin文件`

例如

`python .\uart_downloader.py COM3 D:\chiplab\software\examples\hello_world\obj\hello_world.bin`

在Linux环境下：

`python3 ./uart_downloader.py 串口号 bin文件`

例如

`python3 ./uart_downloader.py /dev/ttyUSB0 ./examples/hello_world/obj/hello_world.bin`

bin文件下载完成后会自动复位处理器核，此时来不及打开串口助手看输出，可以连接串口助手后手动按下复位，即可看到`Hello Loongarch32r!`。

## 4. 基于该SDK进行自主嵌入式软件开发

下面就让我们在自主设计的LA32R处理器核上运行自己编写的C程序吧，在CHIPLAB提供的SDK中，进行裸金属环境的嵌入式软件开发是十分便利的。

### 步骤一：编写C程序

在examples文件夹下新建一个test文件夹，之后在test文件夹下新建main.c，写好C程序后，记得添加下列全局变量:
```c
//BSP板级支持包所需全局变量
unsigned long UART_BASE = 0xbfe001e0;					//UART16550的虚地址
unsigned long CONFREG_UART_BASE = 0xbfafff10;			//CONFREG模拟UART的虚地址
unsigned long CONFREG_TIMER_BASE = 0xbfafe000;			//CONFREG计数器的虚地址
unsigned long CONFREG_CLOCKS_PER_SEC = 100000000L;		//CONFREG时钟频率
unsigned long CORE_CLOCKS_PER_SEC = 33000000L;			//处理器核时钟频率
```
里面的数值需根据SoC实际情况给出，若使用CHIPLAB提供的龙芯杯SoC则不需变更参数，只需注意`UART_BASE`为0时使用CONFREG模拟UART，非0时使用真实的UART16550。

### 步骤二：修改Makefile

可以先将hello_world中的Makefile复制到test文件夹下，然后修改Makefile中的`TARGET = test`作为软件工程的名称，该名称会用于bin文件等的命名。若没有特殊的编译选项需求，这样就改好了，若希望修改编译选项，在Makefile的`CFLAGS += -O3 -g`后面自行添加。

### 步骤三：修改config.sh

为了在Verilator中前仿，还要修改`sims/verilator/run_prog/config.sh`
将hello_world的配置抄一下加在下面即可
`
test) 
    RUN_FUNC=n
    RUN_C=y
    DEAD_CLOCK_EN=n
    OUTPUT_PC_INFO=n
    OUTPUT_UART_INFO=y
    mkdir -p ./obj/
    mkdir -p ./log/
    ;;
`
完成修改，可以去尝试跑qemu跑verilator跑vivado跑FPGA了。

## 5. 运行龙芯杯功能测试与性能测试

### 5.1 功能测试

直接在func_src文件夹下make就能获得可以用于功能测试的bin、coe、mif了

```
$ cd $CHIPLAB_HOME/software/examples/func/func_src
$ make clean
$ make
```
在obj文件夹下即可获得所需文件

### 5.2 性能测试

待合并