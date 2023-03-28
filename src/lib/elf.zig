pub const elf64 = struct {
    pub const Offset = usize; 
    pub const Address = usize; 
    pub const Section = u16; 
    pub const Versym = u16; 
    pub const Byte = u8; 
    pub const Half = u16; 
    pub const Sword = i32; 
    pub const Word = u32; 
    pub const Sxword = i64; 
    pub const Xword = u64; 
};

pub const ElfHeader = extern struct {
    e_ident : [e_ident.ei_nident] elf64.Byte,
    e_type : elf64.Half,  
    e_machine : elf64.Half, 
    e_version : elf64.Word,
    e_entry : elf64.Address,
    e_phoff : elf64.Offset,
    e_shoff : elf64.Offset,
    e_flags : elf64.Word,
    e_ehsize : elf64.Half,
    e_phentsize : elf64.Half,
    e_phnum : elf64.Half,
    e_shentsize : elf64.Half,
    e_shnum : elf64.Half,
    e_shstrndx : elf64.Half,
}; 

pub const Ehdr = ElfHeader; 

pub const e_ident = struct {
    pub const Byte = elf64.Byte; 
    pub const ei_mag0 : Byte = 0x7f; 
    pub const ei_mag1 : Byte = 'E'; 
    pub const ei_mag2 : Byte = 'L';
    pub const ei_mag3 : Byte = 'F';
    pub const EiClass = enum ( u8 ) {
        ELFCLASSNONE = 0,
        ELFCLASS32 = 1,
        ELFCLASS64 = 2,
        _, 
    };
    pub const EiData = enum ( u8 ) {
        ELFDATANONE = 0,
        ELFDATA2LSB = 1,
        ELFDATA2MSB = 2,
        _, 
    };
    pub const EiVersion = enum ( u8 ) {
        EV_NONE = 0,
        EV_CURRENT = 1,
        _, 
    };
    pub const EiOsAbi = enum ( u8 ) {
        ELFOSABI_NONE = 0,
        ELFOSABI_SYSV = 0,
        ELFOSABI_HPUX = 1,
        ELFOSABI_NETBSD = 2,
        ELFOSABI_LINUX = 3,
        ELFOSABI_SOLARIS = 6,
        ELFOSABI_AIX = 7,
        ELFOSABI_IRIX = 8,
        ELFOSABI_FREEBSD = 9,
        ELFOSABI_TRU64 = 10,
        ELFOSABI_MODESTO = 11,
        ELFOSABI_OPENBSD = 12,
        ELFOSABI_ARM_AEABI = 64,
        ELFOSABI_ARM = 97,
        ELFOSABI_STANDALONE = 255,
        _, 
    };
    pub const AbiVersion = Byte; 
    pub const EiPad = [8] Byte; 
    pub const ei_nident = 16; 
};

pub const EiDentType = extern struct {
};

// p_type : elf64.Word, 
// p_offset : elf64.Offset, 
// p_vaddr : elf64.Address,
// p_paddr : elf64.Address,
// p_filesz : elf64.Word,
// p_memsz : elf64.Word,
// p_flags : elf64.Word,
// p_align : elf64.Word,