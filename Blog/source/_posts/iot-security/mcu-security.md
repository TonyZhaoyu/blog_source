---
title: Security Features in Modern MCU
date: 2020-04-21 11:29:42
categories:
- [IoT Security]
---

#### Readback Protection

Refer to a Whitepaper published by NCC group `Microcontroller Readback Protection Bypasses and Defenses`.

Many different mechanisms are used by microcontroller vendors to provide data readback protection, including:
* Disabling debugger access completely.
* Preventing debuggers from reading memory-mapped flash addresses while otherwise leaving the debugging capability intact.
* Preventing flash reads by any internal bus master other than the CPU instruction fetch mechanism.
* Disabling flash reads within bootloaders.
* Encrypting the contents of flash.

##### Debug Pins Reconfigured for Alternate Functions

The threat here is: attackers are able to read memory via debug interfaces like Jtag if debug pins are not protected/disabled.

* Run-time debug disablement has vulnerability as attackers could attach the debugger at early stage while letting device reset to halt the MCU before run-time disablement starts.
* The root cause of such an issue is normally such debug pins are multiplexed with GPIOs, and some MCU allows run-time debug pin remapping. Sometimes boot mode pins could contribute to bypassing the debug interface remapping.


