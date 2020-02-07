---
title: Wish list for 2019
date: 2019-02-13 19:04:00
categories:
  - Top Posts
---

Here is a wish list for 2019. I have done some tailor work, and the following should present a reasonable one.

To begin with, here is a briefing of knowledge & skills to be improved.

1. Coding skills in C.
2. BLE-Mesh specification understanding.
3. Computer science knowledge of CPU & assembly.
4. RISC-V CPU design based on Verilog HDL.

***

* **Tasks for improving *C* coding skills**

|  *Item #* | *Description*  | *Methods* | *Measurement* |
|:-:|-|-|-|
| 1 | Data structure | - `Linux kernel study.` <br> - `Video tutorials` | Compose C code (including test code) and blog. |
| 2 | Tricks in C and GCC compiler | - `Linux kernel study` <br> - `BT-Mesh stack study` <br> - `Video tutorials` | Same as Item 1 |

**Reference**: `BOOK - Data structure and program design in C.`

* **Algorithms**. This section is separated from others as C++ (along with built-in library) is chosen as the language. The focus is really on the algorithm itself rather program-dependent. The bottom line is to get enough knowledge for embedded software development, and hence, won't consider those with too much comprehension. Same category should be considered since there is very likely overlapping with the data structure section.

|  *Item #* | *Description*  | *Methods* | *Measurement* |
|:-:|-|-|-|
| 1 | Sorting algorithms | - `BOOK: Algorithms in graphs` <br> - `Leetcode: easy and medium level` | Summarize in blogs. Leetcode tests. |
| 2 | Searching algorithms | - `BOOK: Algorithms in graphs` <br> - `Leetcode: easy and medium level` | Same as Item 1 |

* **RTOS**. Have done a lot porting work based on FreeRTOS mostly. There is an increasing trend of using RTOS for embedded IoT products, and hence the need for diving in becomes stronger. The purpose is to understand all necessary components of a RTOS and implement a test version. The last item is technically not a RTOS, but it's worth noting for an embedded application.

|  *Item #* | *Description*  | *Methods* | *Measurement* |
|:-:|-|-|-|
| 1 | IPC - message queue | - `PDF: Micrium - uCOS-III` <br> - `FreeRTOS source code` | Summarize in blogs. Source code on Github. |
| 2 | IPC - semaphore & mutex | - `PDF: Micrium - uCOS-III` <br> - `FreeRTOS source code` | Same as item 1 |
| 3 | Preemption-based scheduling policy | - `PDF: Micrium - uCOS-III` <br> - `FreeRTOS source code` | Same as item 1 |
| 4 | Memory management policy | - `PDF: Micrium - uCOS-III` <br> - `FreeRTOS source code` | Same as item 1 |
| 5 | Quantum Leap - QPC framework | - `BOOK: QP framework design` <br> - `QP framework source code` | Same as item 1 |

* **Verilog & RISC-V CPU**. It has been a really long time ever since last touched HDL (it was VHDL back then) in a Uni-Lab. As RISC-V becoming pervasive, it is time to work with some digital design I am long for. The long-term goal is to build a RISC-V CPU with 5 pipeline and 5 hardware thread.

|  *Item #* | *Description*  | *Methods* | *Measurement* |
|:-:|-|-|-|
| 1 | Verilog syntax study | - `BOOK: Verilog HDL introduction` | Summarize in blogs. Source code on Github. |
| 2 | Digital design based on Verilog | - `BOOK: Verilog HDL introduction` <br> - `BOOK: Digital design: with intro to Verilog HDL` <br> - `Verify code on iVerilog` | Summarize in blogs. Source code and verification code on Github. <br> `The goal is to build necessary components for a CPU.` |
| 3 | RISC-V & CPU study | Check references | Summarize in blogs. Source code on Github. |

**Reference**:
  - `BOOK: The RISC-V reader`.
  - `BOOK: Computer architecture: a quantitative approach`.
  - `BOOK: Computer organization design: as SW/HW interface`.
  - `BOOK: Compter systems: a programmer's perspective`.
