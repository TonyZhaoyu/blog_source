---
title: Embedded hardware interfaces for communications
date: 2019-08-17 10:36:06
---

#### **UART communication**

As its name tells, UART is an asynchronous serial communication between devices. A typical wiring connection is as follows:

  <img src="https://cn.bing.com/th?id=OIP.LAOk3F5k2VOtBlej8nQ3IgHaDo&pid=Api&rs=1" width="250" style="border-style: none">

When using UART is selected for the communication between a fast device and a slow device, some sort of flow control is required to ensure no data lost. Take a RPi and an 8-bit MCU as an example. If the PRi wants to send a large stream of data to the MCU, the MCU might be in the danger of buffer exhaustion due to limited buffer space. With flow control, such a situation could be avoided as the MCU could inform the RPi to halt transmission until it handles the data in the buffer.

There are basically three ways to take advantage of the flow control:

1. Hardware flow control.

![Hardware flow control](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/Hardware%20flow%20control.png?raw=true)

  CTS indicates `clear to send`, and RTS indicates `request to send`. As shown in the above figure, each device could trigger a halting/resuming of data transmission. If Device A wants to receive data, it will assert RTS (i.e., request Device B to send me data). If the receiving buffer is **almost** full, it should deassert RTS. The reason for setting an **almost** full signal is due to the fact there might be data on the line just after the RTS deassertion.

2. Legacy hardware flow control (master/slave).

![Legacy hardware flow control](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/Legacy%20hardware%20flow%20control.png?raw=true)

  The legacy hardware flow control is usually implemented for a master (or DTE: data terminal equipment) and slave (or DCE: data communication equipment) situation, and in other words, it is a uni-directional communication. When DTE wants to send data, it asserts RTS and waits for CTS being asserted by DCE.

3. Software flow control (XON/XOFF).

  There is no need for extra wiring of software flow control. The flow control is decided by two specific ASCII characters i.e., XON - 0x11 and XOFF - 0x13. If the transmitter reads a XOFF from the receiver, the transmission should halt, and it could resume after reading a XON.

**References**:
https://learn.sparkfun.com/tutorials/serial-communication/all
https://www.silabs.com/documents/public/application-notes/an0059.0-uart-flow-control.pdf