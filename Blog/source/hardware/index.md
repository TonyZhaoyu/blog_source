---
title: Embedded hardware interfaces for communications
date: 2019-08-17 10:36:06
---

#### **UART communication**

As its name tells, UART is an asynchronous serial communication between devices. A typical wiring connection is as follows:

  <img src="https://cn.bing.com/th?id=OIP.LAOk3F5k2VOtBlej8nQ3IgHaDo&pid=Api&rs=1" width="250" style="border-style: none">

When using UART is selected for the communication between a fast device and a slow device, some sort of flow control is required to ensure no data lost. Take a RPi and an 8-bit MCU as an example. If the PRi wants to send a large stream of data to the MCU, the MCU might be in the danger of buffer exhaustion due to limited buffer space. With flow control, such a situation could be avoided as the MCU could inform the RPi to halt transmission until it handles the data in the buffer.

##### UART flow control

There are basically three ways to take advantage of the flow control:

1. **Hardware flow control**

![Hardware flow control](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/Hardware%20flow%20control.png?raw=true)

  CTS indicates `clear to send`, and RTS indicates `request to send`. As shown in the above figure, each device could trigger a halting/resuming of data transmission. If Device A wants to receive data, it will assert RTS (i.e., request Device B to send me data). If the receiving buffer is **almost** full, it should deassert RTS. The reason for setting an **almost** full signal is due to the fact there might be data on the line just after the RTS deassertion.

  There might be some additional pins namely DTR (data terminal ready) and DSR (data set ready). These flow-control pins are no longer in use nowadays. The [history](https://stackoverflow.com/questions/957337/what-is-the-difference-between-dtr-dsr-and-rts-cts-flow-control) is duplicated as below:
  >The difference between them is that they use different pins. Seriously, that's it. The reason they both exist is that RTS/CTS wasn't supposed to ever be a flow control mechanism, originally; it was for half-duplex modems to coordinate who was sending and who was receiving. RTS and CTS got misused for flow control so often that it became standard.

2. **Legacy hardware flow control (master/slave)**

![Legacy hardware flow control](https://github.com/TonyZhaoyu/blog_source/blob/master/pics/Legacy%20hardware%20flow%20control.png?raw=true)

  The legacy hardware flow control is usually implemented for a master (or DTE: data terminal equipment) and slave (or DCE: data communication equipment) situation, and in other words, it is a uni-directional communication. When DTE wants to send data, it asserts RTS and waits for CTS being asserted by DCE.

3. **Software flow control (XON/XOFF)**

  There is no need for extra wiring of software flow control. The flow control is decided by two specific ASCII characters i.e., XON - 0x11 and XOFF - 0x13. If the transmitter reads a XOFF from the receiver, the transmission should halt, and it could resume after reading a XON.

**References**:

<https://learn.sparkfun.com/tutorials/serial-communication/all>
<https://www.silabs.com/documents/public/application-notes/an0059.0-uart-flow-control.pdf>

**Hardware flow control from a PC**:

Using a UART-to-TTL converter, the PC could talk to a MCU using UART protocol. Popular converters like [CP2102](https://www.silabs.com/documents/public/data-sheets/CP2102-9.pdf) could also provide flow controls. However, it might be hard for users to initiate flow controls as CP2102 by default. In other words, the PC needs to send specific commands to the converter so as to enable flow controls inside (check this [link](https://www.silabs.com/community/interface/forum.topic.html/cp2102_rts_cts_quest-PhJX)). Unfortunately, most of the PC software does not support sending such commands. Hence, to test flow control, it'd be better to use two MCUs.

#### Use UARTs on a MCU

1. One common way of 
