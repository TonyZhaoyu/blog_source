---
title: Embedded ADT
date: 2018-09-04 11:55:32
categories:
- [Coding, Template]
---

#### **Hash table in C**

In this post, a hash table implementation is created. The implementation is intended for resource-restrict platforms like Cortex-M core with a RTOS. The first requirement is speed. It is desired to allocate static memories, and to collect data as quickly as possible. The second requirement is flexibility. The hash table should be flexible to hash customized data structures (not just strings or ints). This also requires the hash function should be flexible. The third requirement is memory collection. If dynamic memory allocation is enabled, a garbage collection method must be deployed to avoid heap memory exhaustion. Last but not the least, errors, like malloc failure, should be well handled.

**References:**

1. Hash Table Program in C:
https://www.tutorialspoint.com/data_structures_algorithms/hash_table_program_in_c.htm

2. Hash Table Basics:
http://www.cs.yale.edu/homes/aspnes/pinewiki/C(2f)HashTables.html?highlight=%28CategoryAlgorithmNotes%29

***

#### **Ring buffer in C**

The related code was posted here: https://github.com/TonyZhaoyu/embedded_ring_buffer.