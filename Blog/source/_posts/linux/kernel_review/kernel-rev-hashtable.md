---
title: Hash table
date: 2018-11-14 11:55:27
categories:
- [Linux, Kernel Review]
---

The implementation of hash table in the Linux kernel uses golden ratio constants to deterministically calculates a random number from any key. Such constants are defined in *include/linux/hash.h*. The following code gives you an example of using a 32-bit constant.

```c
#include <stdio.h>
#include <stdlib.h>

typedef uint32_t u32;

/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
#define GOLDEN_RATIO_PRIME_32 0x9e370001UL

static inline u32 hash_32(u32 val, unsigned int bits)
{
	/* On some cpus multiply is faster, on others gcc will do shifts */
	u32 hash = val * GOLDEN_RATIO_PRIME_32;

	/* High bits are more random, so use them. */
	return hash >> (32 - bits);
}

int main(int argc, char *argv[])
{
  u32 hashedVal;

  printf("NetworkId hash test:\r\n");
  for (u32 i = 0x0001; i <= 0x0064; i++) {
    printf("Hash result of 0x%04X: %u\r\n", i, hash_32(i, 7));
  }
  printf("Hash result of 0x2001: %u\r\n", hash_32(0x2001, 7));

  printf("\r\nGroupId hash test:\r\n");
  for (u32 i = 0xC000; i <= 0xC0C8; i+=2) {
    printf("Hash result of 0x%04X: %u\r\n", i, hash_32((u32)i, 7));
  }

  return 0;
}
```

The fundamental of hash table implementation is based on chaining if a collision is detected. A case than may cause collision is when the key is greater than the buckets size of a hash table. To use the hash table, the caller needs to create a hash table with a fixed bucket size, and the size is a power of 2 number. Each bucket contains a linked list, which is leveraged to deal with hashing collision.