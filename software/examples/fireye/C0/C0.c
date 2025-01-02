//BSP板级支持包所需全局变量
unsigned long UART_BASE = 0xbfe001e0;					//UART16550的虚地址
unsigned long CONFREG_UART_BASE = 0xbfafff10;			//CONFREG模拟UART的虚地址
unsigned long CONFREG_TIMER_BASE = 0xbfafe000;			//CONFREG计数器的虚地址
unsigned long CONFREG_CLOCKS_PER_SEC = 100000000L;		//CONFREG时钟频率
unsigned long CORE_CLOCKS_PER_SEC = 33000000L;			//处理器核时钟频率

int C0_n = 2, A = 50, C0_m = 2, B = 50;
char C0_data0[50][3] = {"of", "to", "in", "is", "it", "on", "be", "as", "at", "by", "he", "or", "an", "we", "up", "so", "if", "do", "no", "me", "my", "go", "er", "us", "am", "oh", "de", "mm", "et", "al", "la", "ah", "ha", "eh", "ad", "ya", "en", "re", "ye", "ex", "yo", "ma", "na", "ta", "ed", "sh", "ho", "um", "em", "un"};
char C0_data1[50][3] = {"lo", "wo", "hi", "li", "ti", "ne", "ba", "pa", "si", "id", "mi", "mo", "fe", "el", "ox", "ab", "ar", "es", "ow", "pe", "bo", "oi", "op", "fa", "uh", "bi", "pi", "mu", "hm", "ay", "xi", "ki", "nu", "os", "aa", "ai", "ag", "ae", "ut", "aw", "oy", "ka", "ax", "od", "qi", "om", "jo", "za", "ef", "oe"};

#define LOOP 2

#include <stdio.h>

#define N 100

int mpN[6][6], mpM[6][6];
int ans;

struct Trie {
    int ch[N][26];
    int tot;
} t[2] = {{{1}, 0}, {{1}, 0}};

void insert(struct Trie *t, char *s) {
    int x = 0;
    for (int i = 0; s[i] != '\0'; i++) {
        if (!t->ch[x][s[i] - 'a'])
            t->ch[x][s[i] - 'a'] = ++t->tot;
        x = t->ch[x][s[i] - 'a'];
    }
}

void dfs(int x, int y) {
    if (x == C0_n + 1) {
        ++ans;
        return;
    }
    for (int i = 0; i < 26; i++) {
        int lastN = mpN[x - 1][y], lastM = mpM[x][y - 1];
        int nx = t[0].ch[lastN][i], ny = t[1].ch[lastM][i];
        if (!(nx && ny)) continue;
        mpN[x][y] = nx;
        mpM[x][y] = ny;

        nx = x, ny = y + 1;
        if (ny > C0_m) ++nx, ny = 1;
        dfs(nx, ny);
    }
}

void run() {
    for (int i = 0; i < A; i++) {
        insert(&t[0], C0_data0[i]);
    }
    for (int i = 0; i < B; i++) {
        insert(&t[1], C0_data1[i]);
    }
    for (int i = 0; i < LOOP; i++) {
        ans = 0;
        dfs(1, 1);
    }
}

int main() {
    t[0].ch[0][0] = 0;
    t[1].ch[0][0] = 0;

    run();
    printf("%d\n", ans);

    return (ans == 62) ? 0 : 1;
}
