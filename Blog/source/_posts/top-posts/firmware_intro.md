---
title: Firmware 101
date: 2016-10-4 10:19:10
categories:
  - Top Posts
---

<img src="http://www.element14.com/community/servlet/JiveServlet/showImage/2-84952-167466/bbb-top-white.png" width="600">

*Coutesy of Beaglebone Black*: https://beagleboard.org/black/.

#### **Introduction**

It has always been a pleasure to say I am an embedded engineer (honestly, just to satisfy my vanity), even though people may have no idea about the title. Only an experienced engineer working for years in this field could they know how complex the term ’embedded system’ is able to convey. Anyway, I have an interesting thought, which is to note down the understanding of this term chronologically. It would be fun to view the improvements as experience grows in a timely manner. Hopefully, I won’t be too embarrassed when look back.

***

#### **Version 0.2, Date: 04/10/2016**

This version provides more understandings on firmware. The term ‘firmware’ has been confusing me since I was aware of this term. What confused me most is I did not bear a clear view after reading tons & tons of online materials. Until now, I think I might have a conclusion on this term, and it turned out what Wikipedia explained started to make sense now. Some old-school engineers would prefer the definition of firmware as a piece of software running on a micro-controller (dating back to the timeline when micro-processor was not popular). Take remote controller as an example: the firmware reads the input from buttons and translates the digital signal to a format that obeys infrared protocol.

What about the definition nowadays? We are living in a world where embedded systems are dramatically grown: 8-bit micro-controller has been expended to 32-bit; micro-processor has been doing tasks that originally managed by PCs. There is no excuse for firmware expanding its scale to absorb latest growth in embedded systems. So, moment of truth:

The term firmware is mostly used in embedded systems. “Firmware is held in non-volatile devices such as ROM, EPROM or flash memory.” (Wikipedia firmware definition) Firmware refers to a piece of software running on micro-controller or micro-processor.
The term firmware is functional-oriented rather platform-oriented. An example of firmware on a micro-controller: a ZigBee end-device has the ability to connect to the ZigBee gateway and communicate with any node within a mesh network. Thanks to the network stack, developers could easily handle their business logic with APIs provided by the stack. Hereby, the network stack is ‘firmware’. ZigBee chip vendors provide IC with RF communication and physical connections (UART/SPI/I2C etc.) to MCUs. The killer function relies on that piece of firmware which handles routing info, IC properties status etc. To summarize, a quick Q&A could be applied: Does the firmware talks to hardware? Yes, it communicates with the external IC with SPI/UART/I2C. Does the firmware provides APIs to the upper layer logic? Yes indeed.

An example of firmware on a micro-processor: a ZigBee gateway running on OpenWrt Linux is capable of coordinating all the end-devices in the mesh network, and could allow cloud connectivity. OpenWrt is a widely used open-source Linux on routers. It could be tailored and embedded on multiple platforms (either ARM or MIPS based) for easy Wi-Fi routing. However, it is firmware developers' responsibility to enable ZigBee gateway functions on such a gateway. Such piece of firmware may no longer serve as the software directly communicates to the hardware, since Linux kernel separates such a communication and leaves the firmware running on the application/middleware layer. Hence, an update of such firmware may not necessarily be correlated to Linux kernel upgrade.

***

#### **Version 0.3, Date: 02/01/2017**

I’ve always been thinking about doing a half-year summary. Hence, here it is. 6-month has passed since I stepped my feet into wireless industry. I guess I’ve witnessed a specific angle of ‘firmware’ development during some hands-on application creation. I could describe the angle as wireless network firmware development. It looks a bit mouthful, yet it is physically true and even appears on Google’s job list.

I’ve been working on ZigBee related projects and hence got a scratch on the development process. Wireless chip vendors usually offer network stacks to developers for easy application creation. Such stacks cover the behavior of multiple layers and usually need to conform with standards like IEEE 802.15.4, ZigBee or Thread. The interaction between application layer and such stacks are through APIs (i.e, callback functions) offered by stacks.

This leads to a result in which the application is highly user-experience dependent with tiny bit lower-layer considerations. Take a ZigBee application as an example: a user wants a ZigBee end-node to report its temperature value periodically. So, an application engineer sent a reporting command at the application layer, expecting everything is all set. The engineer would care nothing about MAC layer retries under a noisy RF environment.

Does such an application creation relate to firmware development? The answer is 100 percent positive. The stacks do a good job on wireless network management. However they wouldn’t explicitly define the behavior of hardware interactions, like reading values from an ADC or blinking a LED through a GPIO. These hardware interactions are tied to embedded development, and hence application creation based on which is still part of firmware development. Bingo !!!

There is one disadvantage though. The maintenance pressure of network stacks is totally based on chip vendors as the source wouldn’t be opened by them. Once the user-experience of the application is not as good as expected, it is now “Huston, we have a problem” time. Application engineers rely on ‘Huston’ to fix its stack bug (or may not be a bug since by nature it is what it is), while listening to some threats like “Fixing such bugs would result in standards violations” blah blah blah. If one doesn’t want a project to hang up, workarounds could be created. Workarounds may be a pain source in the future if the stack hole is filled by ‘Huston’. You may find yourself in an embarrassing situation where you need to eliminate your workarounds in the firmware and  good luck with that.

***

#### **Version 0.4, Date: 30/08/2018**

This gonna be a short version. It has been a really long time since last version. During this period of missing, I was impressed by the need for fundamental knowledge during coding. From my observation, most MCU based projects are extremely careful about HEAP memory usage. Like, array usage spreads out everywhere in C files. Although such an observation is not always true to powerful MCUs like MT7697's cortex-M4 with a 200KB RAM. When dealing with IoT data (e.g., from MQTT), *malloc* would be used.

The point is the C code in every production-ready project involves tons of fundamental knowledge. The MACRO usage, string usage, compiler tricks etc. I benefit from reading books *SEI CERT C Coding Standard* and *CERT C Programming Languages Secure Coding Standard* in which many unfamiliar pieces of C coding are presented. For the projects I was working with, ADT (abstract data-types) were not heavily addressed. The commonly used types are arrays and linked-list. The careful usage of *malloc* restricts the usage of complex data types like trees. Also, there's no need for deploying a complex data type if a simple one suffices. I do have a copy of MISRA-C guideline, and hopefully I could benefit more from reading.
