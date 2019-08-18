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

2. Legacy hardware flow control (master/slave).

3. Software flow control (XON/XOFF).

**References**:
https://learn.sparkfun.com/tutorials/serial-communication/all
https://www.silabs.com/documents/public/application-notes/an0059.0-uart-flow-control.pdf
