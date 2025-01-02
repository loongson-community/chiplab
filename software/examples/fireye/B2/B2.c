//BSP板级支持包所需全局变量
unsigned long UART_BASE = 0xbfe001e0;					//UART16550的虚地址
unsigned long CONFREG_UART_BASE = 0xbfafff10;			//CONFREG模拟UART的虚地址
unsigned long CONFREG_TIMER_BASE = 0xbfafe000;			//CONFREG计数器的虚地址
unsigned long CONFREG_CLOCKS_PER_SEC = 100000000L;		//CONFREG时钟频率
unsigned long CORE_CLOCKS_PER_SEC = 33000000L;			//处理器核时钟频率

int B2_n = 100;
int L[100] = {48, 47, 40, 40, 36, 31, 25, 25, 25, 24, 14, 13, 13, 10, 10, 10, 10, 10, 10, 8, 5, 5, 5, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21, 21, 21, 21, 23, 23, 23, 23, 26, 29, 29, 32, 32, 32, 32, 33, 33, 33, 33, 38, 38, 38, 38, 38, 38, 38, 39, 40, 40, 40, 42, 43, 48};
int R[100] = {48, 48, 53, 53, 53, 54, 55, 57, 59, 66, 66, 66, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 96, 96, 96, 96, 96, 96, 96, 96, 95, 95, 95, 95, 94, 94, 93, 93, 93, 92, 92, 89, 89, 83, 80, 79, 78, 77, 77, 76, 76, 71, 71, 71, 71, 70, 70, 69, 69, 69, 68, 57, 51, 48};

#define LOOP 2

#include <stdio.h>

#define KN 100

int log_2(int x) { int ans = 0; while(x >>= 1) ans++; return ans; }
int B2_max(int a, int b) { return a > b ? a : b; }
int B2_min(int a, int b) { return a < b ? a : b; }

int query(int d[][KN], int l, int r, int maxx) {
    int t = log_2(r - l + 1);
    if (maxx) return B2_max(d[t][l], d[t][r - (1 << t) + 1]);
    return B2_min(d[t][l], d[t][r - (1 << t) + 1]);
}

void init(int d[][KN], int a[], int len, int maxx) {
    for (int i = 0; i < len; i++) d[0][i] = a[i];
    int t = 1;
    for (int i = 1; t <= len; i++) {
        for (int j = 0; j + t < len; j++)
            if (maxx)d[i][j] = B2_max(d[i - 1][j], d[i - 1][j + t]);
            else d[i][j] = B2_min(d[i - 1][j], d[i - 1][j + t]);
        t <<= 1;
    }
}

int main() {
    int dl[20][KN], dr[20][KN];

    init(dl, L, B2_n, 1);
    init(dr, R, B2_n, 0);

    int ans;
    for (int var = 0; var < LOOP; var++) {
        ans = 1;
        for (int i = 1; i <= B2_n; i++) {
            int l = ans, r = B2_n - i + 1;
            while (l <= r) {
                int mid = l + r >> 1;
                if (query(dr, i - 1, i + mid - 2, 0) - query(dl, i - 1, i + mid - 2, 1) + 1 >= mid) {
                    ans = B2_max(ans, mid); l = mid + 1;
                } else r = mid - 1;
            }
        }
    }

    printf("%d\n", ans);
    return (ans == 64) ? 0 : 1;
}
