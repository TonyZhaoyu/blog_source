---
title: Notes of embedded tutorials
date: 2019-06-07 17:47:42
---

#### **Episode 2**

1. Take-out from section 2:

* Emphasis the concept of a `bus`. Think of the bus as a connection between the CPU and peripherals (like I2C, SPI, etc.) and high speed modules like GPU, high speed RAM etc. 
* The role of a `bus` is to make the CPU easy to be connected to extensive modules. Also, the `bus` coordinates the frequency of each module.

2. Take-out from section 4:

* This section focuses on `bus` and `addressing` in a very brief way.
* There is a trick though to check the I/O memory on a Embedded Linux. Enter */proc*, and `$ cat iomem`.
* x86 has commands to direct control I/O devices. There is a dedicated 64K memory for those devices, and one could use `$ cat ioports`. In ARM SoCs, `$ cat ioports` may return nothing as no dedicated memory is allowed.

3. Take-out from section 5:

* ISA: instruction set architecture. Defines machine language mnemonic i.e., assembly. Micro-architecture: implementation of the ISA, like arythmic or control operations.

* A very brief history of ARM architecture. ARM Cortex-M, Cortex-A and Cortex-R were launched as part of ARM v7 architecture, while Cortex-M50, Cortex-M53 and Cortex-M57 were part of ARM v8 architecture.

***

#### **Episode 8**

1. Session 23 and 24 were skimmed through. The contents are mostly concepts.

2. Take-out from section 2:
`$ gcc -c xxx.c` will eventually generate an object file. If `$ readelf -S xxx.o`, one should be able to read multiple sections like .text, .rodata, .data, .bss, elf header etc. 
* When use gcc to link object files, the final executable would merge each section of object files.
* To conduct symbol table parsing, use `$ readelf -s xxx`.

3. Section 3 is useless.
4. Section 4 is useless.
5. Section 5 is useless.
6. Section 6 contains a walk-through of the header files in Linux source. Also a way to utilize makefile to include header paths (-I/path/). Some tricks are worth noting:
- `$ man 3 function` to check which glibc header file defines which function, .e.g., `$ man 3 malloc`.
- `$ grep -rin function` to get recursively (r) file lines (with line number -n) containing *function* name with ignored-case (-i).

7. There is an interesting point in section 7. In `Linux headers`, one could always be seeing *static inline xxx()*, i.e., static inline functions. The reason why to add a *static* is because:

- Firstly, inline functions could be treated as either a normal function or a content extensive function regardless of argument pass in return value etc.
- Secondly, if the inline function is treated as a normal function by the compiler, it'd incur redefinition if multiple files includes such a header. Adding `static` makes it being locally seen to the c file.

The rest of this episode looks useless.

---
