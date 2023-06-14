/// The start of the kernel's memory
pub const memory_start_entry: usize = 0x100000;

const os = @import("root").os;
// const std = os.std;
const std = @import("std");

pub var origin_page: [4096]u8 align(4096) = page: {
    @setEvalBranchQuota(2000);
    var page: [4096]u8 align(4096) = [_] u8 {0} ** 4096; 
    var u8Ptr: *u8 = &page[0];
    var alignU8Ptr: *align(8) u8 = @alignCast(8, u8Ptr);
    var pagePtr: [*]PageTableEntry = @ptrCast([*]PageTableEntry, alignU8Ptr);
    for (0..512) |i| {
        pagePtr[i].setValid(false);
    }
    const physical_start_addr = 0x80000000;
    // const ppn = physical_start_addr >> (12 + 9 * 2); 
    const ppn = physical_start_addr >> 12; 
    const ideal_page_number = 0;
    pagePtr[ideal_page_number].setValid(true);
    pagePtr[ideal_page_number].setRead(true);
    pagePtr[ideal_page_number].setWrite(true);
    pagePtr[ideal_page_number].setExecute(true);
    pagePtr[ideal_page_number].setUser(false);
    pagePtr[ideal_page_number].setGlobal(true);
    pagePtr[ideal_page_number].setPhysicalPageNumber(ppn);
    break :page page;
};
pub var page_manager_area: [4096]u8 align(4096) = undefined;
pub var fixed_buffer_allocator: std.heap.FixedBufferAllocator = std.heap.FixedBufferAllocator.init(pma: {
    const first = &page_manager_area[0];
    const first_no_aligned = @alignCast(1, first);
    const pma = @ptrCast([*]u8, first_no_aligned);
    const pma_slice: []u8 = pma[0..4096];
    break :pma pma_slice;
});
pub const page_manager_area_allocator: std.mem.Allocator = fixed_buffer_allocator.threadSafeAllocator();
pub var page_manager: std.Treap(u64, std.math.order) = .{};

pub const Page = struct {
    physical_page_number: u64,
    virtual_page_number: u64,
    pub fn ptr(self: Page) *u8 {
        const lhs = @shlExact(self.virtual_page_number, 12);
        const lptr = @ptrCast(*u8, lhs);
        return lptr;
    }
};

pub const PageTable = struct {
    page: Page,
    pub fn pageEntries(self: PageTable) [512]PageTableEntry {
        const ptr = self.page.ptr();
        const slice: []PageTableEntry = ptr[0..512];
        return slice;
    }
};

pub const PageTableEntry = extern struct {
    val: u64,
    pub inline fn getPhysicalPageNumber(self: PageTableEntry) usize {
        const ppn = self.val >> 10;
        const mask = (1 << 44) - 1;
        const rst = ppn & mask;
        return rst;
    }
    pub inline fn setPhysicalPageNumber(self: *PageTableEntry, physicalPageNumber: usize) void {
        const ppn = physicalPageNumber;
        const mask = (1 << 44) - 1;
        const rst = ppn & mask;
        self.val = self.val & ~(@as(u64, mask) << 10);
        self.val = self.val | (rst << 10);
    }
    pub inline fn isValid(self: PageTableEntry) bool {
        return self.val & 1 == 1;
    }
    pub inline fn setValid(self: *PageTableEntry, valid: bool) void {
        if (valid) {
            self.val = self.val | 1;
        } else {
            self.val = self.val & ~@as(u64, 1);
        }
    }
    pub inline fn isRead(self: PageTableEntry) bool {
        return self.val & 2 == 2;
    }
    pub inline fn setRead(self: *PageTableEntry, read: bool) void {
        if (read) {
            self.val = self.val | 2;
        } else {
            self.val = self.val & ~2;
        }
    }
    pub inline fn isWrite(self: PageTableEntry) bool {
        return self.val & 4 == 4;
    }
    pub inline fn setWrite(self: *PageTableEntry, write: bool) void {
        if (write) {
            self.val = self.val | 4;
        } else {
            self.val = self.val & ~4;
        }
    }
    pub inline fn isExecute(self: PageTableEntry) bool {
        return self.val & 8 == 8;
    }
    pub inline fn setExecute(self: *PageTableEntry, execute: bool) void {
        if (execute) {
            self.val = self.val | 8;
        } else {
            self.val = self.val & ~8;
        }
    }
    pub inline fn isLeaf(self: PageTableEntry) bool {
        return (self.isRead() ||
            self.isWrite() ||
            self.isExecute() ||
            false);
    }
    pub inline fn isUser(self: PageTableEntry) bool {
        return self.val & 16 == 16;
    }
    pub inline fn setUser(self: *PageTableEntry, user: bool) void {
        if (user) {
            self.val = self.val | 16;
        } else {
            self.val = self.val & ~@as(u64, 16);
        }
    }
    pub inline fn isGlobal(self: PageTableEntry) bool {
        return self.val & 32 == 32;
    }
    pub inline fn setGlobal(self: *PageTableEntry, global: bool) void {
        if (global) {
            self.val = self.val | 32;
        } else {
            self.val = self.val & ~32;
        }
    }
    pub inline fn isAccessed(self: PageTableEntry) bool {
        return self.val & 64 == 64;
    }
    pub inline fn setAccessed(self: *PageTableEntry, accessed: bool) void {
        if (accessed) {
            self.val = self.val | 64;
        } else {
            self.val = self.val & ~64;
        }
    }
    pub inline fn isDirty(self: PageTableEntry) bool {
        return self.val & 128 == 128;
    }
    pub inline fn setDirty(self: *PageTableEntry, dirty: bool) void {
        if (dirty) {
            self.val = self.val | 128;
        } else {
            self.val = self.val & ~128;
        }
    }
    pub inline fn get_rsw(self: PageTableEntry) u2 {
        return (self.val >> 8) & 3;
    }
    pub inline fn setRsw(self: PageTableEntry, rsw: u2) u2 {
        const rsw_u64: u64 = rsw;
        self.val = self.val | (rsw_u64 << 8);
    }
};

pub inline fn init() void {
    std.log.info("page addr start: {*}, number: {x}", .{ &origin_page, @ptrToInt(&origin_page) >> 12 });
    std.log.info("high page number: {}", .{ 0x80000000 >> (12 + 2 * 9)}); 
    var node = page_manager_area_allocator.create(std.Treap(u64, std.math.order).Node) catch unreachable;
    defer page_manager_area_allocator.destroy(node);
    node.key = 1;
    var en = page_manager.getEntryFor(0);
    en.set(node);
    var node2 = page_manager_area_allocator.create(std.Treap(u64, std.math.order).Node) catch unreachable;
    defer page_manager_area_allocator.destroy(node2);
    var en3 = page_manager.getEntryFor(3);
    en3.set(node2);
    var min = page_manager.getMin();
    std.log.info("min: {?}", .{min});
    var max = page_manager.getMax();
    std.log.info("max: {?}", .{max});
    // map 0x80200000 -> 0x1000
    const vmain = os.vmain;
    const vmainVal = @ptrToInt(&vmain);
    const vmain2 = vmainVal - 0x80000000; 
    const ppn = @ptrToInt(&origin_page) >> 12;
    std.log.info("vmain2: {x}", .{vmain2}); 
    os.rt.setTrap(vmain2);
    std.log.info("ppn: {}", .{ ppn }); 
    {
        const ptr = @intToPtr([*]PageTableEntry, ppn << 12); 
        std.log.info("ptr: {*}", .{ptr}); 
        for (0..512) |i| {
            if (ptr[i].isValid()) {
                std.log.info("page entry [{}]: valid, ppn: {}.", .{ i, ptr[i].getPhysicalPageNumber() }); 
            }
        }

    }
    setSatp(ppn);
    os.sbi.shutdown(); 
}

pub inline fn setSatp(ppn: u64) void {
    const mask = 0x8000_0000_0000_0000;
    const r = ppn | mask;
    asm volatile (
        \\csrw satp, %[0]
        \\sfence.vma
        :
        : [@"0"] "r" (r),
        : "memory"
    );
}
