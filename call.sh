# zig build-exe /Users/cutiedeng/Documents/Zorroos/src/virtual_app.zig -OReleaseSafe --cache-dir /Users/cutiedeng/Documents/Zorroos/zig-cache --global-cache-dir /Users/cutiedeng/.cache/zig --name out -mcmodel medium -target riscv64-freestanding-none -mcpu baseline_rv64 --script /Users/cutiedeng/Documents/Zorroos/src/linker.ld -I /Users/cutiedeng/Documents/Zorroos/src -flto
zig build-exe /Users/cutiedeng/Documents/Zorroos/src/virtual_app.zig -OReleaseSafe --cache-dir /Users/cutiedeng/Documents/Zorroos/zig-cache --name out -mcmodel medium -target riscv64-freestanding-none --script /Users/cutiedeng/Documents/Zorroos/src/linker.ld -I /Users/cutiedeng/Documents/Zorroos/src -mcpu baseline_rv64+d