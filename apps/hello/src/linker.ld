ENTRY(_start) 

SECTIONS {
    . = 0x80400000; 
    PROVIDE (_start = .); 
    .text : { *(.text) }
    .data : { *(.data .rodata) }
    .bss : { *(.bss) } 
}
