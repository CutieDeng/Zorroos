ENTRY(_start) 

SECTIONS {
    . = 0x80400000; 
    PROVIDE (_start = .); 
    .text : { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) } 
    .rodata : { *(.rodata) } 
}
