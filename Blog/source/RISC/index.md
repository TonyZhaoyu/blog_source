---
title: Preface - RISC
date: 2019-06-07 17:52:56
---

RISC ISA has been dominating the embedded world over decades. ARM, specifically, accounts for a huge market share, and leaves much limited space for MIPS. As AI and ML becomes pervasive recently, fabricating domain-specific SoCs leads a new trend in IC industry that was used to be ruled by a few giants. People tend to value ISA more since ISA constitutes the corner-stone of a general-purpose CPU in such SoCs. An ISA  which is free from license, ease to customize with a complete tool-chain would be in much favor of architects from various domains. By far, RISC-V might arguably be the chosen one due to its open-source character, and activated community. Thanks to the emergence of RISC-V, we finally see some challenge to a closed-source ARM.

<img src="https://riscv.org/wp-content/uploads/2015/10/cropped-LI_profile.png" width="250" style="border-style: none">

*Courtesy of RISC-V foundation:* https://riscv.org/

Moreover, the spirit of open-source has stimulated multiple organizations to embrace the new era of SoC designs, including some big names (like *Silicon Labs* and *NXP*) from IC industry. Really exited to foresee open RISC dominates the market in 5 to 10 years.

<img src="https://www.openhwgroup.org/images/openhw-landscape.svg" width="350" style="border-style: none">

*Courtesy of open hardware group:* https://www.openhwgroup.org/

<img src="https://isastaging.wpengine.com/wp-content/uploads/2018/11/board.png" width="350" style="border-style: none">

*Courtesy of open-isa:* https://open-isa.org/

***

There is one company playing a leader role in RISC-V community. The name is SiFive. The company is known from its background, i.e., strong academic relationship with UCB computer architecture lab.

<img src="https://community.cadence.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-01-06/sifive_2D00_logo_2D00_v1.png" width="300" style="border-style: none">

*Courtesy of SiFive:* https://www.sifive.com/

Having attended a few seminars of SiFive, I've summarized a few ideas/jargons hereby. I'd apologize for the less structural organization as some ideas are new to me. Also, there might be some missing descriptions, and they will be updated later.

* **RISC-V continuing works in 2019**

Some jargons with simple descriptions are presented below:

1. CLIC: It is a RISC-V Core-Local Interrupt Controller ([CLIC](https://github.com/sifive/clic-spec/blob/master/clic.adoc)) proposed by SiFive. It is expected to replace  the existing RISC-V local interrupt scheme (CLINT) in the future. The CLIC also implements the standard RISC-V platform-level interrupt controller (PLIC).

2. Vectors: Most refers to [vector extension](https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc). The ideas is to outperform SIMD instructions.

3. Hypervisor: RISC-V supports three privilege modes, i.e., Machine mode, Supervisor mode and User mode. Hypervisor is an extension of the Supervisor mode which provides virtualization etc.

4. ZFinx: Quoted from [vector extension](https://github.com/riscv/riscv-v-spec/blob/master/v-spec.adoc): `Zfinx ("F in X") is a new ISA option under consideration where floating-point instructions take their arguments from the integer register file.`.

5. Code density: There is a great answer [here](https://electronics.stackexchange.com/questions/4123/about-code-density-and-its-definition). Basically, high density code takes less RAM space and takes less micro-instructions to realize a function. Usually it depends on the CPU ISA and the compiler.

* **Tools/techs used by SiFive**

As SiFive works closely with the [BAR](https://bar.eecs.berkeley.edu/), i.e., Berkeley Architecture Research, some tools have been adopted from the laboratory to the commercial. The following lists include tools originated from lab and tools that have been developed by SiFive.

1. Code generator: [Chisel](https://chisel.eecs.berkeley.edu/) - Constructing Hardware in a Scala Embedded Language. SiFive use Chisel to model customized CPU systems on the Web, and generates verifiable RTL code for customers.

2. Chip generator: Prometheus. Not sure what it is after Googling.

3. [Tilelink](https://sifive.cdn.prismic.io/sifive%2F57f93ecf-2c42-46f7-9818-bcdd7d39400a_tilelink-spec-1.7.1.pdf): Basically it is a bus to connect general-purpose processors, DMA engines and accelerators etc.

4. Chiplink: I could not find proper documents on Google, but basically it is a serialized chip-to-chip TileLink.

* **Business models and road-maps of SiFive and SiFive China**

Firstly, SiFive China runs independently to SiFive US. It seemed that SiFive China would focus more on AI/ML, as they claim all-in vector extension. There will be a AI EVB launch this year, namely Freedom Resolution. SiFive is an IP core vendor but has a very strong ambition to stretches out its ecosystem to AI/ML market. As such, they created `Design-share` to offer levels of IPs to customers by partnering various IP vendors (e.g., Imagination for GPU and A/D companies). To improve time-to-market, SiFive builds IP templates (like IoT MCUs, smart Audio, smart Video etc) for customers. By such a method, the spirit what SiFive offers makes hardware design `soft`, and to some extent matches the idea of SaaS (software as a service).
