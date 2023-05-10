const ElfHeader = struct {
    identity: ElfIdentify, 
}; 

pub const ElfIdentify = extern struct {
    /// Magic number: 0x7f 0x4f(E) 0x4c(L) 0x46(F) 
    magic : [4] u8,  
    /// File class: 0x01(32-bit) 0x02(64-bit) 
    class : u8 , 
    endian : u8 , 
    version : u8 , 

    pub fn init_and_check(self: *const ElfIdentify) ?*const ElfIdentify {
        inline for (self.magic, "\x7fELF") |m, c| {
            if (m != c) {
                return null; 
            } 
        }
        switch (self.class) {
            0x01 , 0x02 => {
                // 0x01 : 32 bit 
                // 0x02 : 64 bit 
            }, 
            else => {
                return null; 
            }, 
        }
        switch (self.endian) {
            0x01 , 0x02 => {
                // 0x01 : little endian 
                // 0x02 : big endian 
            }, 
            else => {
                return null; 
            }, 
        }
        switch (self.version) {
            0x01 => {} , 
            else => {
                return null; 
            }, 
        }
        return self; 
    } 
}; 

const std = @import("std"); 

pub fn call() !void {
    var elf : ElfIdentify = undefined; 
    _ = elf.init_and_check() orelse return error.InvalidElf; 
}

pub export fn elf_export() void {
    call() catch @panic(""); 
}