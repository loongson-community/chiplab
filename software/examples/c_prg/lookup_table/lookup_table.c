/*
    Copyright 2008-2009 Adobe Systems Incorporated
    Copyright 2018 Chris Cox
    Distributed under the MIT License (see accompanying file LICENSE_1_0_0.txt
    or a copy at http://stlab.adobe.com/licenses.html )


Goal: Test performance of various idioms and optimizations for lookup tables.


Assumptions:
    1) The compiler will optimize lookup table operations.
        Unrolling will usually be needed to hide read latencies.

    2) The compiler should recognize ineffecient lookup table idioms and substitute efficient methods.
        Many different CPU architecture issues will require reading and writing words for best performance.
            CPUs with...
                    cache write-back/write-combine delays.
                    store forwarding delays.
                    slow cache access relative to shifts/masks.
                    slow partial word (byte) access.
                    fast shift/mask operations.
        On some CPUs, a lookup can be handled with vector instructions.
        On some CPUs, special cache handling is needed (especially 2way caches).




TODO - lookup and interpolate (int16_t, int32_t, int64_t, float, double)
TODO - 2D and 3D LUTs, simple and interpolated

*/

/******************************************************************************/

#include <time.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

/******************************************************************************/
/******************************************************************************/
//BSP板级支持包所需全局变量
unsigned long UART_BASE = 0xbfe001e0;					//UART16550的虚地址
unsigned long CONFREG_UART_BASE = 0xbfafff10;			//CONFREG模拟UART的虚地址
unsigned long CONFREG_TIMER_BASE = 0xbfafe000;			//CONFREG计数器的虚地址
unsigned long CONFREG_CLOCKS_PER_SEC = 100000000L;		//CONFREG时钟频率
unsigned long CORE_CLOCKS_PER_SEC = 33000000L;			//处理器核时钟频率

clock_t start_time, end_time;

// this constant may need to be adjusted to give reasonable minimum times
// For best results, times should be about 1.0 seconds for the minimum test run
int base_iterations = 1;
int iterations = 1;

// 4000 items, or about 2..4k of data
// this is intended to remain within the L1 cache of most common CPUs
#define SIZE_SMALL 2000

// about 0.5..1M of data
// 没有那么大内存，这里给50KB到100KB
// this is intended to be outside the L2 cache of most common CPUs
#define SIZE 50000

// initial value for filling our arrays, may be changed from the command line
int32_t init_value = 3;

/******************************************************************************/

// our global arrays of numbers

uint8_t inputData8[SIZE];
uint8_t resultData8[SIZE];

uint16_t inputData16[SIZE];
uint16_t resultData16[SIZE];

/******************************************************************************/
/******************************************************************************/


void fill_8(uint8_t * first, uint8_t * last, uint8_t value) {
    while (first != last) *first++ = (uint8_t)(value);
}

void fill_16(uint16_t * first, uint16_t * last, uint16_t value) {
    while (first != last) *first++ = (uint16_t)(value);
}

void fill_random_8(uint8_t * first, uint8_t * last) {
    srand((unsigned int)init_value + 123 );
    while (first != last) {
        *first++ = (uint8_t)rand();
    }
}

void fill_random_16(uint16_t * first, uint16_t * last) {
    srand((unsigned int)init_value + 123 );
    while (first != last) {
        *first++ = (uint16_t)rand();
    }
}

int max(int a, int b){
    if(a > b)
        return a;
    else
        return b;
}

/******************************************************************************/
/******************************************************************************/



// baseline - a trivial loop

void test_lut1_u8(const uint8_t* input, uint8_t *result, const int count, const uint8_t* LUT, const char *label) {

    start_time = clock();

    for(int i = 0; i < iterations; ++i) {
        for (int j = 0; j < count; ++j) {
            result[j] = LUT[ input[j] ];
        }
    }
    
    end_time = clock();

    int j;

    for (j = 0; j < count; ++j) {
        if (result[j] != (uint8_t)(init_value)) {
            printf("test %s failed (got %u, expected %u)\n", label, (unsigned)(result[j]), (unsigned)(init_value));
            break;
        }
    }

    double time_cost = (end_time - start_time)/ (double)(CLOCKS_PER_SEC);
    printf("\"%s, %d times\"  %f sec\n",
        label,
        count,
        time_cost);

}

void test_lut1_8(const int8_t* input, int8_t *result, const int count, const int8_t* LUT, const char *label) {

    start_time = clock();

    for(int i = 0; i < iterations; ++i) {
        for (int j = 0; j < count; ++j) {
            result[j] = LUT[ input[j] ];
        }
    }
    
    end_time = clock();

    int j;

    for (j = 0; j < count; ++j) {
        if (result[j] != (int8_t)(init_value)) {
            printf("test %s failed (got %u, expected %u)\n", label, (unsigned)(result[j]), (unsigned)(init_value));
            break;
        }
    }

    double time_cost = (end_time - start_time)/ (double)(CLOCKS_PER_SEC);
    printf("\"%s, %d times\"  %f sec\n",
        label,
        count,
        time_cost);

}

void test_lut1_u16(const uint16_t* input, uint16_t *result, const int count, const uint16_t* LUT, const char *label) {

    start_time = clock();

    for(int i = 0; i < iterations; ++i) {
        for (int j = 0; j < count; ++j) {
            result[j] = LUT[ input[j] ];
        }
    }
    
    end_time = clock();

    int j;

    for (j = 0; j < count; ++j) {
        if (result[j] != (uint16_t)(init_value)) {
            printf("test %s failed (got %u, expected %u)\n", label, (unsigned)(result[j]), (unsigned)(init_value));
            break;
        }
    }

    double time_cost = (end_time - start_time)/ (double)(CLOCKS_PER_SEC);
    printf("\"%s, %d times\"  %f sec\n",
        label,
        count,
        time_cost);

}

void test_lut1_16(const int16_t* input, int16_t *result, const int count, const int16_t* LUT, const char *label) {

    start_time = clock();

    for(int i = 0; i < iterations; ++i) {
        for (int j = 0; j < count; ++j) {
            result[j] = LUT[ input[j] ];
        }
    }
    
    end_time = clock();

    int j;

    for (j = 0; j < count; ++j) {
        if (result[j] != (int16_t)(init_value)) {
            printf("test %s failed (got %u, expected %u)\n", label, (unsigned)(result[j]), (unsigned)(init_value));
            break;
        }
    }

    double time_cost = (end_time - start_time)/ (double)(CLOCKS_PER_SEC);
    printf("\"%s, %d times\"  %f sec\n",
        label,
        count,
        time_cost);

}

/******************************************************************************/
/******************************************************************************/

int main(int argc, char** argv) {

    // output command for documentation:
    int i;
    // for (i = 0; i < argc; ++i)
    //     printf("%s ", argv[i] );
    // printf("\n");

    if (argc > 1) base_iterations = atoi(argv[1]);
    if (argc > 2) init_value = (int32_t) atoi(argv[2]);

    uint8_t myLUT8[ 256 ];
    uint16_t myLUT16[ 65536 ];
    

    fill_8(myLUT8, myLUT8+256, (uint8_t)(init_value));
    fill_16(myLUT16, myLUT16+65536, (uint16_t)(init_value));

    fill_random_8( inputData8, inputData8+SIZE );
    fill_random_16( inputData16, inputData16+SIZE );


// uint8_t
    iterations = base_iterations;

    test_lut1_u8( inputData8, inputData8, SIZE_SMALL, myLUT8, "uint8_t lookup table1 small inplace");
    test_lut1_u8( inputData8, resultData8, SIZE_SMALL, myLUT8, "uint8_t lookup table1 small");

    iterations = max( 1, (int)(((uint64_t)base_iterations * SIZE_SMALL) / SIZE) );
    
    test_lut1_u8( inputData8, inputData8, SIZE, myLUT8, "uint8_t lookup table1 large inplace");
    test_lut1_u8( inputData8, resultData8, SIZE, myLUT8, "uint8_t lookup table1 large");



// int8_t
    iterations = base_iterations;

    test_lut1_8( (int8_t*)inputData8, (int8_t*)inputData8, SIZE_SMALL, (int8_t*)(myLUT8+128), "int8_t lookup table1 small inplace");  
    test_lut1_8( (int8_t*)inputData8, (int8_t*)resultData8, SIZE_SMALL, (int8_t*)(myLUT8+128), "int8_t lookup table1 small"); 

    iterations = max( 1, (int)(((uint64_t)base_iterations * SIZE_SMALL) / SIZE) );
    
    test_lut1_8( (int8_t*)inputData8, (int8_t*)inputData8, SIZE, (int8_t*)(myLUT8+128), "int8_t lookup table1 large inplace");
    test_lut1_8( (int8_t*)inputData8, (int8_t*)resultData8, SIZE, (int8_t*)(myLUT8+128), "int8_t lookup table1 large");

    
// uint16_t
    iterations = base_iterations;

    test_lut1_u16( inputData16, inputData16, SIZE_SMALL, myLUT16, "uint16_t lookup table1 small inplace");
    test_lut1_u16( inputData16, resultData16, SIZE_SMALL, myLUT16, "uint16_t lookup table1 small");

    iterations = max( 1, (int)(((uint64_t)base_iterations * SIZE_SMALL) / SIZE) );
    
    test_lut1_u16( inputData16, inputData16, SIZE, myLUT16, "uint16_t lookup table1 large inplace");
    test_lut1_u16( inputData16, resultData16, SIZE, myLUT16, "uint16_t lookup table1 large");

// int16_t
    iterations = base_iterations;

    test_lut1_16( (int16_t*)inputData16, (int16_t*)inputData16, SIZE_SMALL, (int16_t*)(myLUT16+32768), "int16_t lookup table1 small inplace");
    test_lut1_16( (int16_t*)inputData16, (int16_t*)resultData16, SIZE_SMALL, (int16_t*)(myLUT16+32768), "int16_t lookup table1 small");

    iterations = max( 1, (int)(((uint64_t)base_iterations * SIZE_SMALL) / SIZE) );
    
    test_lut1_16( (int16_t*)inputData16, (int16_t*)inputData16, SIZE, (int16_t*)(myLUT16+32768), "int16_t lookup table1 large inplace");
    test_lut1_16( (int16_t*)inputData16, (int16_t*)resultData16, SIZE, (int16_t*)(myLUT16+32768), "int16_t lookup table1 large");

    return 0;
}

// the end
/******************************************************************************/
/******************************************************************************/
