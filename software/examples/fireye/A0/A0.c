//BSP板级支持包所需全局变量
unsigned long UART_BASE = 0xbfe001e0;					//UART16550的虚地址
unsigned long CONFREG_UART_BASE = 0xbfafff10;			//CONFREG模拟UART的虚地址
unsigned long CONFREG_TIMER_BASE = 0xbfafe000;			//CONFREG计数器的虚地址
unsigned long CONFREG_CLOCKS_PER_SEC = 100000000L;		//CONFREG时钟频率
unsigned long CORE_CLOCKS_PER_SEC = 33000000L;			//处理器核时钟频率

int A0_n = 10000;
int A0_k = 20;
int data[20] = {207, 47, 368, 668, 655, 560, 8, 820, 11, 723, 396, 310, 268, 572, 45, 84, 229, 5, 92, 475};
#define LOOP 1

#include <stdio.h>

#define KN 10000

int pos[KN] = {1};

int A0_max(int a, int b) { return a > b ? a : b; }

int main() {
    pos[0] = 0;

    int ans = 0;
    for(int i = 0; i < A0_k; i++) {
		int x = data[i];
		for(int j = x; j <= A0_n; j += x) pos[j] ^= 1;
		int tmp = 0;
		for(int j = 1; j <= A0_n; j++) tmp += pos[j];
		ans = A0_max(ans, tmp);
	}

    printf("%d\n", ans);
    return (ans == 3367) ? 0 : 1;
}
