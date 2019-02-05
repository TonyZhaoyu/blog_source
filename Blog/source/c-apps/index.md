---
title: Basics in C programming
date: 2019-02-05 14:16:31
---

#### **The usage of sizeof() and strlen()**

The standard C functions sizeof() and strlen() are most likely one of the first functions ever used when learning C. They have been used at many aspects of validating a string, an instance of a structure. The following content shows what are the results of sizeof() and strlen() in various situations.

------------------------ **The usage of *sizeof()*** ------------------------

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#if defined __LINUX__
  #include <malloc.h>
#endif

typedef struct _TestStruct {
  int  testInt;
  char * testStr;
  char * testStr_1[5];
} TestStruct;

typedef struct _TestPadding {
  char * testChar;
  int  * testInt;
} TestPadding;

TestStruct staticTestStruct_0 = {
  .testInt = 0,
  .testStr = "Hello",
};

TestStruct staticTestStruct_1 = {
  .testInt = 1,
  .testStr = NULL,
};

TestStruct staticTestStruct_2 = {
  .testInt = 2,
};

int main(int argc, char const *argv[])
{
  char array_0[20];
  char * array_2 = (char *)malloc(20 * sizeof(char));
  // Static array test.
  printf("Static array sizeof: %lu\r\n", sizeof(array_0));
  char array_1[] = {'H', 'e', 'l', 'l', 'o'};
  printf("Static array element :%lu\r\n", sizeof(array_1)/sizeof(array_1[0]));
  // Dynamic array test.
  printf("Dynamic array sizeof :%lu\r\n", sizeof(array_2));
  free(array_2);
  // Static struct test.
  printf("TestStruct sizeof :%lu\r\n", sizeof(TestStruct));
  printf("staticTestStruct_0 sizeof :%lu\r\n", sizeof(staticTestStruct_0));
  printf("staticTestStruct_1 sizeof :%lu\r\n", sizeof(staticTestStruct_1));
  printf("staticTestStruct_2 sizeof :%lu\r\n", sizeof(staticTestStruct_2));
  // Dynamic struct test.
  TestStruct * dynamTestStruct_0 = (TestStruct *)malloc(sizeof(TestStruct));
  dynamTestStruct_0->testInt = 3;
  dynamTestStruct_0->testStr = (char *)malloc(20 * sizeof(char));
  printf("dynamTestStruct_0 sizeof :%lu\r\n", sizeof(dynamTestStruct_0));
  printf("dynamTestStruct_0->testStr sizeof :%lu\r\n",
         sizeof(dynamTestStruct_0->testStr));
  free(dynamTestStruct_0->testStr);
  free(dynamTestStruct_0);
  // Structure padding test.
  printf("TestPadding sizeof :%lu\r\n", sizeof(TestPadding));

  return 0;
}
```

The execution result (on a 64-bit Mac) is as follows:

```c
Static array sizeof: 20
Static array element :5
Dynamic array sizeof :8
TestStruct sizeof :56
staticTestStruct_0 sizeof :56
staticTestStruct_1 sizeof :56
staticTestStruct_2 sizeof :56
dynamTestStruct_0 sizeof :8
dynamTestStruct_0->testStr sizeof :8
TestPadding sizeof :16
```

> The method sizeof() is a compile time unary operator which can be used to compute the size of its operand, where unary operator indicates an operation with only one operand, i.e., a single input. The size is measured in the number of char-sized storage units required for the type. The result has an unsigned integral type that is usually denoted by *size_t*. The compiler computes sizeof() with a constant result-values.

There are basically two situations when sizeof() is used. Firstly, to allocate dynamic memory. Examples are shown in the code above. Notice how the malloc works for *char* and *struct* types. Secondly, it could be used to calculate the number of elements of the array. See the example of *array_1*. Some attentions need to be paid when using this method:

* The method could calculates the right bytes when the operand is an array (e.g., array_0[]), or an structure (e.g., TestStruct) excluding the memory referenced by a pointer.

* When the operand is a pointer, the result will be the size of the pointer itself (e.g., dynamTestStruct_0). Not the whole memory that the pointer points to.

* The aggregate size of a structure can be greater than the sum of the sizes of its individual members (e.g., TestPadding) due to structure padding (the compiler wants to align in word-length).

------------------------ **The usage of *strlen()*** ------------------------

In order to understand how *strlen()* works, we duplicate the implementation of this method in Glibc as below. More info could refer to https://sourceware.org/git/?p=glibc.git;a=blob_plain;f=string/strlen.c;hb=HEAD.

```c
#include <string.h>
#include <stdlib.h>

#undef strlen

#ifndef STRLEN
# define STRLEN strlen
#endif

/* Return the length of the null-terminated string STR.  Scan for
   the null terminator quickly by testing four bytes at a time.  */
size_t
STRLEN (const char *str)
{
  const char *char_ptr;
  const unsigned long int *longword_ptr;
  unsigned long int longword, himagic, lomagic;

  /* Handle the first few characters by reading one character at a time.
     Do this until CHAR_PTR is aligned on a longword boundary.  */
  for (char_ptr = str; ((unsigned long int) char_ptr
			& (sizeof (longword) - 1)) != 0;
       ++char_ptr)
    if (*char_ptr == '\0')
      return char_ptr - str;

  /* All these elucidatory comments refer to 4-byte longwords,
     but the theory applies equally well to 8-byte longwords.  */

  longword_ptr = (unsigned long int *) char_ptr;

  /* Bits 31, 24, 16, and 8 of this number are zero.  Call these bits
     the "holes."  Note that there is a hole just to the left of
     each byte, with an extra at the end:

     bits:  01111110 11111110 11111110 11111111
     bytes: AAAAAAAA BBBBBBBB CCCCCCCC DDDDDDDD

     The 1-bits make sure that carries propagate to the next 0-bit.
     The 0-bits provide holes for carries to fall into.  */
  himagic = 0x80808080L;
  lomagic = 0x01010101L;
  if (sizeof (longword) > 4)
    {
      /* 64-bit version of the magic.  */
      /* Do the shift in two steps to avoid a warning if long has 32 bits.  */
      himagic = ((himagic << 16) << 16) | himagic;
      lomagic = ((lomagic << 16) << 16) | lomagic;
    }
  if (sizeof (longword) > 8)
    abort ();

  /* Instead of the traditional loop which tests each character,
     we will test a longword at a time.  The tricky part is testing
     if *any of the four* bytes in the longword in question are zero.  */
  for (;;)
    {
      longword = *longword_ptr++;

      if (((longword - lomagic) & ~longword & himagic) != 0)
	{
	  /* Which of the bytes was the zero?  If none of them were, it was
	     a misfire; continue the search.  */

	  const char *cp = (const char *) (longword_ptr - 1);

	  if (cp[0] == 0)
	    return cp - str;
	  if (cp[1] == 0)
	    return cp - str + 1;
	  if (cp[2] == 0)
	    return cp - str + 2;
	  if (cp[3] == 0)
	    return cp - str + 3;
	  if (sizeof (longword) > 4)
	    {
	      if (cp[4] == 0)
		return cp - str + 4;
	      if (cp[5] == 0)
		return cp - str + 5;
	      if (cp[6] == 0)
		return cp - str + 6;
	      if (cp[7] == 0)
		return cp - str + 7;
	    }
	}
    }
}
```

Some notes when reading this piece of code.

1. The syntax of *for* loop allows no braces if a single statement is fired within the loop (like the one in line 21).
2. The string to be measured is stored in the memory with continuous indexes. That is why line 25 (*return char_ptr - str*) works.
3. The code is optimized with respect to performance. Refer to https://stackoverflow.com/questions/20021066/how-the-glibc-strlen-implementation-works.
4. The coder is extremely familiar with memory alignment and computer ISA.
5. There are some performance comparisons between different strlen implementation. Check https://news.ycombinator.com/item?id=510326. The book, Hacker's Delight (http://hackersdelight.org/) mentioned in the link is worth reading.

There is a simple *strlen()* implementation from K&R.

```c
int strlen(char *s)
{
    char *p = s;
    while (*p != '\0')
        p++;
    return p - s;
}
```

When using this function, please pay extra care about the string being passed to the method. Make sure the string ends with *'\0'*, otherwise it may crash the program or return a nonsense value.

***

#### **GCC link to a shared library at a specific directory**

Link: https://stackoverflow.com/questions/8835108/how-to-specify-non-default-shared-library-path-in-gcc-linux-getting-error-whil

For example, all the shared library and the test file are in the same folder.

```bash
$ gcc -Wall test_basics.c -o test -L./ -lcmocka -Wl,-rpath=./
```

***

#### **When const meets volatile**

The topic is elaborated using three sections: *const* usage, *volatile* usage and the mixture of *const* and *volatile* usage.

When speaking of *const*, we could spontaneously relate to *read-only*. And it is true that a variable that is marked by const should not be changed elsewhere other than its definition. An example could be `const char *str = "Hello World!"`. However, there are some human-compilation tests regarding const, in which a few statements with const are to be validated. Considering the following cases:

```c
int a = 8;
// A pointer.
int *b = &a;
// A pointer to a const value.
const int *c = &a;
int const *d = b;
// A const pointer to value.
int * const e = &a;
// A const pointer to a const value.
const int * const f = &a;
```

c, d and f will be illegal if the value of a is to be changed. c and d is legal to change the pointer to another pointer e.g., `int i = 3; c = &i;`, and such a change is illegal for f. It is legal for e to change the value of a, e.g., `a = 10;`. But it would be illegal for f to do pointer change like e.g., `int j = 9; f = &j;`. The const qualifier could also be used for non-pointer values. The following lines are perfectly legal, `int const a = 8; const int *b = &a;`.

The usage of *volatile* qualifier is compiler related. Basically, it prevents the compiler from optimizing away the memory read/write operations to the volatile variable. The syntax of using volatile is just like const. Considering the pointer situation, the most common use case is `volatile int *a = &b;` or `int volatile *a = &b`, indicating a pointer to a volatile variable. Volatile pointers to a non-volatile data is rare. There are three cases that will use volatile qualifier (refer to https://barrgroup.com/Embedded-Systems/How-To/C-Volatile-Keyword):

1. Memory-mapped peripheral registers

2. Global variables modified by an interrupt service routine

3. Global variables accessed by multiple tasks within a multi-threaded application.

A good example of the first case is as below:

```c
// Situation 1: non volatile memory read.
uint8_t * p_reg = (uint8_t *) 0x1234;

do { // Some code. } while (0 == *p_reg);

// Assembly
  mov p_reg, #0x1234
  mov a, @p_reg
loop:
  # Some code.
  bz loop
```

```c
// Situation 2: volatile memory read.
uint8_t volatile * p_reg = (uint8_t *) 0x1234;

do { // Some code. } while (0 == *p_reg);

// Assembly
  mov p_reg, #0x1234
loop:
  # Some code.
  mov a, @p_reg
  bz loop
```

When `combining const and volatile`, we might wonder whether the definition of `const volatile int *a = &b` is legal? In terms of a read-only memory-map register, it is perfectly legal, e.g., `const volatile uint_8 *a = (uint8_t *)0x8000000A`. *const* limits the access to the variable to be read-only. *volatile* forces the compiler to be aware of this variable that should be read from the memory-mapped register every single time.

***

#### **Bit manipulation**

Bit manipulations are full of tricks. In some cases, it decrease an algorithm's complexity from O(logN) down to O(1). A good reference could be the book Hacker's Delight. Here are some examples from this link: https://www.hackerearth.com/zh/practice/notes/bit-manipulation/.

1. How to check if the given number is power of 2?

The tricks is this method `n & (n - 1) == 0`. Basically it flips the bit of the right side of the rightmost 1, e.g., `n = (110)b; n - 1 = (101)b`, or flips the rightmost 1 if it's the last bit.

2. Count the number of ones in the binary representation of the given number.

Based on the first trick, we could know that `n & (n - 1)` could count the number of ones, as each time it mange to detect a one-bit. The following is a sample implementation:

```c
uint16_t one_count(int n)
{
  uint16_t cnt = 0;

  while (n) {
    n = n & (n - 1);
    cnt++;
  }

  return cnt;
}
```

3. Check if the i-th bit is set in the binary form of the given number.

This one is easy. Use this condition `N & (1 << i)`, where N is the given number for the i-th bit.

4. Set the specific bit and read the specific bit of a register.

Read the specific bit could use the same condition in 3, i.e., `N & (1 << i)`. We could set or clear a specific bit using the following conditions respectively: `N = N | (1 << i)` and `N = N & (~(1 << i))`.

5. How to generate all the possible subsets of a set?

Considering a consecutive memory of a set, like an static array or dynamic array. We could use index to find each set element. We could use bit 1 to represent the presence of an element, and 0 to represent the absence of an element. Like a state machine in truth-table, we traverse through all the possibilities (e.g., a set of 3 elements has 8 possibility (000)b, (001)b etc) and print the element with 1 bit.

6. Detect which bit contains the leftmost one?

This question may be challenging. My thought is to somehow set all the bit after the leftmost 1 (e.g., (0100)b => (0111)b), and count the number of ones until it reaches a zero. The final result is then the `count - 1`. The difficult part is set all the bit after the leftmost 1. To achieve this, we could use the following lines:

```c
// Notice an N is a 16-bit integer.
N = N| (N>>1);
N = N| (N>>2);
N = N| (N>>4);
N = N| (N>>8);
```