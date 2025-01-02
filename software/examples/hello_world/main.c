#include <stdio.h> 
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

//BSP板级支持包所需全局变量
unsigned long UART_BASE = 0xbfe001e0;					//UART16550的虚地址
unsigned long CONFREG_UART_BASE = 0xbfafff10;			//CONFREG模拟UART的虚地址
unsigned long CONFREG_TIMER_BASE = 0xbfafe000;			//CONFREG计数器的虚地址
unsigned long CONFREG_CLOCKS_PER_SEC = 100000000L;		//CONFREG时钟频率
unsigned long CORE_CLOCKS_PER_SEC = 33000000L;			//处理器核时钟频率

#define CPSIZE 12
char src[CPSIZE] = "this is src";
char dst[CPSIZE] = "this is dst";

int main(int argc, char** argv)
{
	int a = 100;
	float b = 3.2564;
	double c = 5478.47563;
	char *str;

	printf("Hello Loongarch32r!\n");
	printf("a = %d\n",  a);
	printf("b = %f\n",  b);
	printf("c = %lf\n", c);

    str = (char *)malloc(6);
    strcpy(str, "ABCDE");
    printf("String = %s,  Address = 0x%x\n", str, str);

	memcpy(dst, src, CPSIZE);
    printf("%s\n", dst);
  
	return 0;
}