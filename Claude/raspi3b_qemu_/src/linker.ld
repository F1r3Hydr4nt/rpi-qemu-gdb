ENTRY(_start)
SECTIONS
{
    . = 0x8000;
    __text_start = .;
    .text : { *(.text.boot) *(.text) }
    __text_end = .;
    
    __rodata_start = .;
    .rodata : { *(.rodata) }
    __rodata_end = .;
    
    __data_start = .;
    .data : { *(.data) }
    __data_end = .;
    
    . = ALIGN(0x1000);
    __bss_start = .;
    .bss : { *(.bss*) } 
    __bss_end = .;
}