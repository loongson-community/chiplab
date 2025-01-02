TARGET = dhrystone

CFLAGS += -O3 -g -G8 -DTIME -DNumber_Of_Runs=1

C_SRCS := $(wildcard ./*.c )

INCLUDES := -I. 

OBJDIR = obj
COMMON_DIR = ../../bsp
GCC_DIR=../../../toolchains/loongson-gnu-toolchain-8.3-x86_64-loongarch32r-linux-gnusf-v2.0
PICOLIBC_DIR=../../../toolchains/picolibc
include ../../bsp/common.mk
