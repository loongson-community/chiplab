OUTPUT_ARCH(loongarch)
ENTRY(_start)

MEMORY
{
  sram (rwxai) : ORIGIN = 0x1c000000, LENGTH = 1024K
}

SECTIONS
{
  __stack_size = DEFINED(__stack_size) ? __stack_size : 64K;
  .init :
  {
    KEEP (*(SORT_NONE(.init)))
  } >sram AT>sram
  
  .text :
  {
    _ftext = . ;
    *(.text.unlikely .text.unlikely.*)
    *(.text.startup .text.startup.*)
    *(.text .text.*)
    *(.gnu.linkonce.t.*)
  } >sram AT>sram

  .fini :
  {
    KEEP (*(SORT_NONE(.fini)))
  } >sram AT>sram
  . = ALIGN(16);
  PROVIDE (__etext = .);
  PROVIDE (_etext = .);
  PROVIDE (etext = .);
  .preinit_array :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >sram AT>sram
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >sram AT>sram
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >sram AT>sram
  .ctors :
  {
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  } >sram AT>sram
  .dtors :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  } >sram AT>sram
  . = ALIGN(16);
  PROVIDE( _eisram = . );
  
  .ex_table_base :
  {
	  _ex_table_base_start = .;
	  . = 0x500;
	  _ex_table_base_end = .;
  } >sram AT>sram

  .data :
  {
    *(.rdata)
    *(.rodata .rodata.*)
    rodata_end = .;
    *(.gnu.linkonce.r.*)
    *(.data .data.*)
    *(.gnu.linkonce.d.*)
    . = ALIGN(16);
    PROVIDE( __global_pointer$ = . + 0x800 );
    *(.sdata .sdata.*)
    *(.gnu.linkonce.s.*)
    . = ALIGN(16);
    *(.srodata.cst16)
    *(.srodata.cst8)
    *(.srodata.cst4)
    *(.srodata.cst2)
    *(.srodata .srodata.*)
  } >sram AT>sram
  . = ALIGN(16);
  PROVIDE( _edata = . );
  PROVIDE( edata = . );
  PROVIDE( _fbss = . );
  PROVIDE( __bss_start = . );
  .bss :
  {
    *(.sbss*)
    *(.gnu.linkonce.sb.*)
    *(.bss .bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(16);
  } >sram AT>sram
  . = ALIGN(16);
  PROVIDE( _end = . );
  PROVIDE( end = . );
  PROVIDE (__heap_start = _end);
  .stack ORIGIN(sram) + LENGTH(sram) - __stack_size :
  {
    PROVIDE( _heap_end = . );
    PROVIDE (__heap_end = _heap_end);
    PROVIDE (__heap_size = __heap_end - __heap_start);
    . = __stack_size;
    PROVIDE( _stack = . );
  } >sram AT>sram
}
