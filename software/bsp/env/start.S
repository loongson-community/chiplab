#include "regdef.h"
#include "uart_print.h"
#include "handler.h"

.globl default_ex
.extern UART_BASE

	.section .init
	.globl _start
	.type _start,@function

_start:

#if has_cache==1
    # invalid the old inst in icache and old data in dcache by index
    li.w t0,0x0
    #li.w t2,0x100
    li.w t2, cache_index_depth
1: 
    #slli.w    t1, t0, 0x4
    slli.w    t1, t0, cache_offset_width
#if cache_way==1
    cacop     0x00, t1, 0x0 
    cacop     0x01, t1, 0x0
#elif cache_way==2
    cacop     0x00, t1, 0x0 
    cacop     0x00, t1, 0x1
    cacop     0x01, t1, 0x0
    cacop     0x01, t1, 0x1
#elif cache_way==4
    cacop     0x00, t1, 0x0 
    cacop     0x00, t1, 0x1
    cacop     0x00, t1, 0x2 
    cacop     0x00, t1, 0x3
    cacop     0x01, t1, 0x0
    cacop     0x01, t1, 0x1
    cacop     0x01, t1, 0x2
    cacop     0x01, t1, 0x3
#endif
    addi.w    t0, t0, 0x1
    bne       t0, t2, 1b
#else
    /* disable   cache */
    # li.w    $r12,0x1
    # csrwr	$r12,0x101
#endif

	/* init CSR */
    li.w	    $r12,0x8
    li.w	    $r13,0x18
    csrxchg	$r12,$r13,0x0

    csrwr	$r0,0x180
    csrwr	$r0,0x181
    li.w    $r12,0x19
    csrwr	$r12,0x180
    li.w    $r12,0xa0000009
    csrwr	$r12,0x181

    li.w	    $r12,0x10
    li.w	    $r13,0x18
    csrxchg	$r12,$r13,0x0

    /* load data section */
	la.local t0, _data_lma
	la.local t1, _data
	la.local t2, _edata
	bgeu t1, t2, 2f
1:
	ld.w t3, t0, 0
	st.w t3, t1, 0
	addi.w t0, t0, 4
	addi.w t1, t1, 4
	bltu t1, t2, 1b
2:

	/* clear bss section */
	la.local t0, __bss_start
	la.local t1, _end
	bgeu t0, t1, 2f
1:
	st.w $r0, t0, 0
	addi.w t0, t0, 4
	bltu t0, t1, 1b
2:

	/* init UART */
	la.local    t0, UART_BASE
	ld.w        t1, t0, 0
	#WRITE(li.wne,OFS_FIFO,FIFO_ENABLE|FIFO_RCV_RST|FIFO_XMT_RST|FIFO_TRIGGER_0);
	li.w       t2, 0x07   
	st.b     t2, t1, 2
	#WRITE(li.wne,OFS_LINE_CONTROL, 0x80);
	li.w       t2, 0x80
	st.b     t2, t1, 3
	#WRITE(li.wne,OFS_DIVISOR_MSB, (divisor & 0xff00) >> 8); 
	li.w       t2, 0x00 
	st.b     t2, t1, 1 
	#WRITE(li.wne,OFS_DIVISOR_LSB, divisor & 0xff);
	li.w       t2, 0x36 
	st.b     t2, t1, 0 
	#WRITE(li.wne,OFS_DATA_FORMAT, data | parity | stop);
	li.w       t2, 0x3 
	st.b     t2, t1, 3
	#WRITE(li.wne,OFS_MODEM_CONTROL,0);
	li.w       t2, 0x0 
	st.b     t2, t1, 4 

    /* init exception base and ex_table */
    bl      ex_base_init
    #bl      ex_table_init

	la.local	sp, _stack
    
	/* argc = argv = 0 */
	li.w a0, 0
	li.w a1, 0
	bl main
	/*tail exit*/
	bl      _myexit
1:
	b 1b

ex_base_init:
    la.local t0, trap_handler
    csrwr   t0, 0xc
    
    jirl    zero, ra, 0x0

ex_table_init:
    la      t0, default_ex
    la      t1, _ex_table_base_start
    addi.w  t3, t1, 0
    #general ex table init
    li.w     t2, 0x20
1:
    st.w    t0, t1, 0
    addi.w  t1, t1, 4
    addi.w  t2, t2, -1
    bge     t2, zero, 1b
    #int table init
    addi.w  t1, t3, 0
    st.w    t0, t1, ex_tlb_refill<<2
    la      t0, syscall_ex
    st.w    t0, t1, ex_syscall_type<<2
    jirl    zero, ra, 0

Hex_to_ASCII:
	addi.w  sp, sp, -8
	st.w    ra, sp, 0
	add.w   t0, zero, a0
	st.w    t0, sp, 4
	li.w      a0, 0x30    #'0'
	bl      putchar
	li.w      a0, 0x78    #'x'
	bl      putchar

    li.w      t3, 0x3a    #'9' + 1
	li.w      t5, 32
11:
	addi.w  t5, t5, -4
	ld.w    t0, sp, 4
	srl.w   t0, t0, t5
    andi    t4, t0, 0xf     #get_number
    addi.w  t4, t4, 0x30    #'0'~'9'
    blt     t4, t3, 22f
    addi.w  t4, t4, 0x27    #'a'~'f'
22:
	add.w   a0, t4, zero   #store to UART
	#st.w    t0, sp, 8
	bl      putchar
    bne     t5, zero, 11b
	ld.w    ra, sp, 0
	addi.w  sp, sp, 8
	jirl    zero, ra, 0


.globl _myexit
.org 0x548
_myexit:
	syscall 0x11 //nemu exit
1:
	b 1b

###################
####EXCEPTION######
###################
.align 8
.globl trap_handler
trap_handler:
	csrwr   s6, 0x30
	csrwr   s7, 0x31
	csrrd   s6, 0x5
	li.w      s7, 0x3f0000	
	and     s6, s7, s6
	srli.w  s6, s6, 14
	la      s7, _ex_table_base_start
	add.w   s6, s6, s7
	ld.w    s7, s6, 0
	csrrd   s6, 0x30
	jirl    zero, s7, 0

default_ex:
    st.w    t0, sp, -4
    st.w    t1, sp, -8
    st.w    t2, sp, -12
    st.w    t3, sp, -16
    st.w    t4, sp, -20
    addi.w  sp, sp, -28

    UART_PRINT("\nReach unexpected ex\n")
    UART_PRINT("====================\n")
    UART_PRINT("\nError Epc  is ")
	csrrd   t0, 0x6     #read epc
    addi.w  a0, t0, 0
    bl      Hex_to_ASCII

    UART_PRINT("\nVs bit     is ")
    csrrd   t4, 0x05
	st.w    t4, sp, 0
    li.w      t3, 0xfff
    and     a0, t3, t4 #mask IS
    bl      Hex_to_ASCII
    UART_PRINT("\nExcode     is ")
	ld.w    t4, sp, 0
    srli.w  t4, t4, 16
	li.w      t3, 0x3f
	and     a0, t3, t4  #mask Ecode
    bl      Hex_to_ASCII
    UART_PRINT("\nBad addr   is ")
	csrrd   a0, 0x07
	bl      Hex_to_ASCII
    UART_PRINT("\n====================\n")

    csrrd   t0, 0x6     #read epc
    addi.w  t0, t0, 4   #epc += 4
    csrwr   t0, 0x6     #write epc

    addi.w  sp, sp, 28
    ld.w    t4, sp, -20
    ld.w    t3, sp, -16
    ld.w    t2, sp, -12
    ld.w    t1, sp, -8
    ld.w    t0, sp, -4

    idle 0

syscall_ex:
    idle 0

	.globl  handler_declare
handler_declare:
    st.w    t8, sp, -4       
    st.w    tp, sp, -8      
    add.w   t8, a0, zero
    la      tp, _ex_table_base_start
	slli.w  a1, a1, 2
	add.w   tp, tp, a1
    st.w    t8, tp, 0
    ld.w    t8, sp, -4       
    ld.w    tp, sp, -8
	jirl    zero, ra, 0

	.globl  handler_release
handler_release:
    st.w    t8, sp, -4       
    st.w    tp, sp, -8      
    la      t8, default_ex
    la      tp, _ex_table_base_start
	slli.w  a0, a0, 2
	add.w   tp, tp, a0
    st.w    t8, tp, 0
    ld.w    t8, sp, -4       
    ld.w    tp, sp, -8
	jirl    zero, ra, 0
