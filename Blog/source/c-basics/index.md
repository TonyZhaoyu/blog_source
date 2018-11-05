---
title: Basics in C/C++ programming
date: 2018-09-04 12:11:42
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
