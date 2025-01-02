1. [GCC交叉编译器](https://gitee.com/loongson-edu/la32r-toolchains/releases)

根据架构下载相应`loongarch32r-linux-gnusf-${TOOLCHAINS_DATE}.tar.gz`，并解压。解压后将`loongarch32r-linux-gnusf-${TOOLCHAINS_DATE}/bin/`目录添加到path中。
linux下建议打开
```
$ vim ~/.bashrc
```
在文件末尾添加以下内容，注意保持此处`${TOOLCHAINS_DATE}`和所下载工具链文件夹名称一致。
```
export PATH=${CHIPLAB_HOME}/toolchains/loongarch32r-linux-gnusf-${TOOLCHAINS_DATE}/bin/:$PATH 
```
之后
```
$ bash
```
使配置生效

2. [NEMU](https://gitee.com/wwt_panache/la32r-nemu/releases)

在当前目录`mkdir nemu`，然后下载`la32r-nemu-interpreter-so`到`nemu`目录。

3. C库 从picolibc和newlib中二选一即可，推荐picolibc，software中的makefile默认使用picolibc，若使用newlib需对makefile进行少量修改，详见software/README.md

3.1 [picolibc](https://gitee.com/ffshff/la32r-picolibc/releases/tag/V1.0)

在当前目录`mkdir picolibc`，然后将`picolibc.tar.gz`解压到`picolibc`目录。

3.2 [newlib](https://gitee.com/ffshff/newlib-la32r/releases/tag/V1.0)

在当前目录`mkdir newlib`，然后将`newlib.tar.gz`解压到`newlib`目录。

4. [qemu](https://gitee.com/loongson-edu/la32r-QEMU/releases/tag/v0.0.2)

根据架构下载相应的`la32r-QEMU-x86_64-*-22.04.tar`并解压。解压后将`la32r-QEMU-x86_64-ubuntu-22.04/`目录添加到path中。

linux下建议打开
```
$ vim ~/.bashrc
```
在文件末尾添加以下内容
```
export PATH=${CHIPLAB_HOME}/toolchains/la32r-QEMU-x86_64-ubuntu-22.04/:$PATH 
```
之后
```
$ bash
```
使配置生效