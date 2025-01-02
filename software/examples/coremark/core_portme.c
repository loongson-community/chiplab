//#include <stdio.h>
//#include <stdlib.h>
#include "coremark.h"
//#include "platform.h"
//#include "encoding.h"

#if VALIDATION_RUN
	volatile ee_s32 seed1_volatile=0x3415;
	volatile ee_s32 seed2_volatile=0x3415;
	volatile ee_s32 seed3_volatile=0x66;
#endif

#if PERFORMANCE_RUN
	volatile ee_s32 seed1_volatile=0x0;
	volatile ee_s32 seed2_volatile=0x0;
	volatile ee_s32 seed3_volatile=0x66;
#endif

#if PROFILE_RUN
	volatile ee_s32 seed1_volatile=0x8;
	volatile ee_s32 seed2_volatile=0x8;
	volatile ee_s32 seed3_volatile=0x8;
#endif

volatile ee_s32 seed4_volatile=ITERATIONS;
volatile ee_s32 seed5_volatile=0;

static CORE_TICKS t0, t1;

void start_time(void)
{
  t0 = get_clock_count();
}

void stop_time(void)
{
  t1 = get_clock_count();
}

CORE_TICKS get_time(void)
{
  return t1 - t0;
}

secs_ret time_in_secs(CORE_TICKS ticks)
{
#ifdef USE_CPU_CLOCK_COUNT
  secs_ret retval = ((secs_ret)ticks) / (secs_ret)CORE_CLOCKS_PER_SEC;
#else
  secs_ret retval = ((secs_ret)ticks) / (secs_ret)CONFREG_CLOCKS_PER_SEC;
#endif
  return retval;
}
