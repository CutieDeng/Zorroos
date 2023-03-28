# ELF 文件结构描述

ELF 是一种 `object` 文件格式，又称为 *Executable and Linking Format*. 

其中，有三种文件格式：

- **Relocatable File** 可重定位格式文件，其存储的 code 和 data 可以与其他 object 文件一起构成一个可执行文件或一个共享 object 文件。
- **Executable file** 可执行文件，存储一个可以用于执行的程序。该文件指定了 exec 应该如何创建该程序的进程内存结构。
- **shared object file** 共享 object 文件，其中的 code 和 data 能够在两种不同的情况下链接。
首先，链接编译器 (la) 和其他可重定义、共享 object 文件一同处理该文件，其次，动态链接器把它和他们一起创建一个进程 image. 

[[TODO: 让人迷惑的发言和描述。]]

object 文件由汇编器和链接器创建，其内部的二进制表示用于描述一个可被执行的程序。
而程序一般所需的其他抽象机制，如 shell script, 则不能被这样运行。

本章用于描述该文件的格式和它构建程序有关的部分。
章节 5 也同样描述了 *object* 文件必要的构建程序的信息。

## 文件格式

*object* 用于链接和执行。出于方便起见，*object* 文件格式提供了多种文件内容的速阅视图，根据不同的行为需要。

*ELF header* 位于文件的起始位置，其通过一个 *road map* 描述该文件的组织。
*Sections* 描述了用于链接的大量信息：指令，数据，符号表，重定位信息等等。
