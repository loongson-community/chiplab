TARGET = coremark

C_SRCS := \
	core_list_join.c \
	core_main.c \
	core_matrix.c \
	core_state.c \
	core_util.c \
	core_portme.c \

CFLAGS := -O3 -funroll-all-loops -finline-limit=200 -ftree-dominator-opts -fno-if-conversion2 -fselective-scheduling -fno-code-hoisting -fno-common -falign-functions=4 -falign-jumps=4 -falign-loops=4

CFLAGS += -DFLAGS_STR=\""$(CFLAGS)"\"
CFLAGS += -g
#配置迭代次数
CFLAGS += -DITERATIONS=1

OBJDIR = obj
COMMON_DIR = ../../bsp
GCC_DIR=../../../toolchains/loongson-gnu-toolchain-8.3-x86_64-loongarch32r-linux-gnusf-v2.0
PICOLIBC_DIR=../../../toolchains/picolibc
include ../../bsp/common.mk
