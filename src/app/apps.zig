// create some symbols and put the program here. 
comptime {
    asm( 
        \\.align 3
        \\.section .data 
        \\app_numbers: 
        \\.quad 3
        \\.quad app0_start
        \\.quad app0_end
        \\.quad app1_start
        \\.quad app1_end 
        \\.quad app2_start
        \\.quad app2_end
        \\.section .data 
        \\app0_start: 
        \\.incbin "apps/hello/zig-out/bin/hello.bin"
        \\app0_end: 
        \\.section .data
        \\app1_start:
        \\.incbin "apps/hello/zig-out/bin/hello.bin"
        \\app1_end:
        \\app2_start: 
        \\ .incbin "apps/hello/zig-out/bin/hello.bin"
        \\app2_end: 
    );
}