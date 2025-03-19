/* Enhanced linker script for better memory contiguity */
ENTRY(_start)

SECTIONS
{
    /* Keep the original load address at 0x8000 */
    . = 0x8000;
    
    /* Text section (executable code) */
    __text_start = .;
    .text : {
        /* Boot code first for deterministic start address */
        *(.text.boot)
        
        /* Put all functions with the same name pattern together */
        *(.text.startup*)
        *(.text.init*)
        *(.text.hot*)
        
        /* Main text sections */
        *(.text)
        *(.text.*)
        
        /* Ensure alignment */
        . = ALIGN(4);
    }
    __text_end = .;
    
    /* Read-only data section */
    __rodata_start = .;
    .rodata : {
        *(.rodata)
        *(.rodata.*)
        *(.rodata1)
        
        /* String tables */
        *(.strtab)
        
        /* Ensure alignment */
        . = ALIGN(4);
    }
    __rodata_end = .;
    
    /* Read-write data section (initialized) */
    __data_start = .;
    .data : {
        /* Order data by access frequency and size */
        *(.data.rel.ro)
        *(.data)
        *(.data.*)
        *(.got)
        *(.got.plt)
        
        /* Ensure alignment */
        . = ALIGN(4);
    }
    __data_end = .;
    
    /* Read-write data section (uninitialized) */
    /* Align to page boundary for better memory mapping */
    . = ALIGN(0x1000);
    __bss_start = .;
    .bss (NOLOAD) : {
        /* Order by size (largest first) to reduce fragmentation */
        *(.bss.page_aligned)
        *(.dynbss)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        
        /* Ensure alignment */
        . = ALIGN(4);
    }
    __bss_end = .;
    
    /* Add end marker for heap allocation if needed */
    __end = .;
    
    /* Discard unnecessary sections to reduce size and fragmentation */
    /DISCARD/ : {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
        *(.ARM.exidx*)
        *(.ARM.attributes)
        *(.debug*)
    }
}
