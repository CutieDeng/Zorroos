// pub const exception = enum (usize) { 
//     const ty = usize; 
//     pub const instruction_address_misaligned : ty = 0; 
//     pub const instruction_access_fault : ty = 1; 
//     pub const illegal_instruction : ty = 2; 
//     pub const break_point : ty = 3; 
//     pub const load_address_misaligned : ty = 4; 
//     pub const load_access_fault : ty = 5; 
//     pub const store_address_misaligned : ty = 6; 
//     pub const store_access_fault : ty = 7; 
//     pub const environment_call_from_u : ty = 8; 
//     pub const environment_call_from_s : ty = 9; 
//     pub const environment_call_from_m : ty = 11; 
//     // pub const 
// }; 

/// 异常枚举 
pub const interrupt = enum (usize) { 
    supervisor_software_interrupt = 1, 
    machine_software_interrupt = 3, 
    supervisor_timer_interrupt = 5, 
    machine_timer_interrupt = 7, 
    supervisor_external_interrupt = 9, 
    machine_external_interrupt = 11, 
}; 

/// 异常枚举
pub const Exception = enum (usize) { 
    instruction_address_misaligned = 0, 
    instruction_access_fault = 1, 
    illegal_instruction = 2, 
    break_point = 3, 
    load_address_misaligned = 4, 
    load_access_fault = 5, 
    store_address_misaligned = 6, 
    store_access_fault = 7, 
    environment_call_from_u = 8, 
    environment_call_from_s = 9, 
    environment_call_from_m = 11, 
    instruction_page_fault = 12, 
    load_page_fault = 13, 
    store_page_fault = 15, 
}; 

pub const std = @import("std"); 