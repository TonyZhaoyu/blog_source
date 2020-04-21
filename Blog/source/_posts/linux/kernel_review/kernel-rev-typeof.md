---
title: The magic of typeof and container_of
date: 2018-11-07 10:19:10
categories:
- [Linux, Kernel Review]
---

#### **The famous "typeof" and "container_of"**

* **"typeof" in the kernel**

Many dynamic programming language like Javascript has dynamic way of determining the data type with syntax similar to *typeof*. In C code, a compiler extension provides a way to use *typeof*. It is recommended to compile source code with *-std=gnu99* (rather *-std=c99*) for such a feature. In the kernel code, *typeof* has been widely used. Here is an example:

```c
#ifndef _TYPES_H_
#define _TYPES_H_

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

typedef unsigned char		u8;
typedef unsigned short		u16;
typedef unsigned int		u32;
typedef unsigned long long	u64;
typedef signed char		s8;
typedef short			s16;
typedef int			s32;
typedef long long		s64;

#define min(x,y) ({ \
	typeof(x) _x = (x);	\
	typeof(y) _y = (y);	\
	(void) (&_x == &_y);	\
	_x < _y ? _x : _y; })

#define max(x,y) ({ \
	typeof(x) _x = (x);	\
	typeof(y) _y = (y);	\
	(void) (&_x == &_y);	\
	_x > _y ? _x : _y; })

#endif /* _TYPES_H_ */
```

In the example, the statement *typeof(x) _x = (x)* could be explained using a specific type say *int*. That is to say, if x has the *int* type, then *typeof(x) _x = (x)* equals to *int _x = (x)*, which creates a variable and assigned by the value of x. There is one line *(void) (&_x == &_y)* worth noting. This line basically checks if the type _x and type _y are the same. If not, the compile would throw out a warning "comparison of distinct pointer types." Alternatively, there is way of doing min and max without using typeof.

```c
#define min_t(type, x, y) ({			\
	type __min1 = (x);			\
	type __min2 = (y);			\
	__min1 < __min2 ? __min1: __min2; })

#define max_t(type, x, y) ({			\
	type __max1 = (x);			\
	type __max2 = (y);			\
	__max1 > __max2 ? __max1: __max2; })
```

Considering the following code for different implementation of *min*. We could find out why we need temp variables (like *_x* and *_y*) to store inputs. A function should not worry about such variables, as the arguments that passed through are already copies of the inputs.

```c
#include <stdio.h>

#define min(x ,y) ({      \
  (x) < (y) ? (x) : (y); })

#define min_2(x ,y) ({    \
  typeof(x) _x = x;       \
  typeof(y) _y = y;       \
  (_x) < (_y) ? (_x) : (_y); })

int get_min(int x, int y)
{
  return (x < y) ? x : y;
}

int main(int argc, char *argv[])
{
  int a = 2, b = 3;
  int c = 4, d = 5;
  int e = 5, f = 6;
  int g = 5, h = 6;

  printf("case 1: %d\r\n", min(a, b));
  printf("case 2: %d, c: %d, d: %d\r\n", min(c++, d++), c, d);
  printf("case 3: %d, e: %d, f: %d\r\n", min_2(e++, f++), e, f);
  printf("case 4: %d, g: %d, h: %d\r\n", get_min(g++, h++), g, h);

  return 0;
}
```

Execution results:

```bash
There are some warnings during compiling:
test.c:26:51: warning: unsequenced modification and access to 'g' [-Wunsequenced]
  printf("case 4: %d, g: %d, h: %d\r\n", get_min(g++, h++), g, h);
                                                  ^         ~
test.c:26:56: warning: unsequenced modification and access to 'h' [-Wunsequenced]
  printf("case 4: %d, g: %d, h: %d\r\n", get_min(g++, h++), g, h);
                                                      ^       ~
2 warnings generated.

case 1: 2
case 2: 5, c: 6, d: 6  // The ++ results appeared to be wrong. Expect c == 5.
case 3: 5, e: 6, f: 7
case 4: 5, g: 6, h: 7
```

* **"container_of" in the kernel**.

The definition could be found in include/linux/kernel.h. Briefly speaking, the purpose of container_of is to get the structure pointer by a pointer of the member of that structure.

```c
/**
 * container_of - cast a member of a structure out to the containing structure
 * @ptr:	the pointer to the member.
 * @type:	the type of the container struct this is embedded in.
 * @member:	the name of the member within the struct.
 *
 */
#define container_of(ptr, type, member) ({			\
	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
	(type *)( (char *)__mptr - offsetof(type,member) );})

/* The definition of offsetof */
#define offsetof(TYPE, MEMBER)	((size_t)&((TYPE *)0)->MEMBER)  
```
The definition of *offsetof* gives the address of the *MEMBER* and force the address to be in *size_t* formatted. In *container_of*, the argument *member* is the name of the member rather a type, and hence we need *typeof* to determine the type. A compilation error would occur if *member* is not a valid member of the structure. Some usage samples of *offset_of* and *container_of* are presented as below. To prove "&((type *)0)->member" works as expected, *testPtr* has been created. Basically, "&((TestStruct *)0)->member" is equal to "&testPtr->member". **Since the start address of the structure is 0, the address of a member naturally becomes the offset.** The offset of *member_0* is 0x0 as *member_0* is the initial element, and *member_1* is 0x8 as "sizeof(member_0)" (i.e., sizeof(unsigned long)) equals to 8. In the end, use "char *" to format the member's address and getting the initial address by subtract the offset value.

```c
#include <stdio.h>

#define offsetof(TYPE, MEMBER)	\
  ((size_t)&((TYPE *)0)->MEMBER)

#define container_of(ptr, type, member) ({			\
	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
	(type *)( (char *)__mptr - offsetof(type,member) );})

typedef struct _TestStruct {
  unsigned long member_0;
  char  member_1;
} TestStruct;

int main(int argc, char *argv[])
{
  TestStruct test;
  TestStruct *testPtr = NULL;
  test.member_0 = 5;
  test.member_1 = 'c';

  printf("test addr :%p\r\n", &test);
  printf("member_0 addr :%p\r\n", &test.member_0);
  printf("member_1 addr :%p\r\n", &test.member_1);
  printf("&((TestStruct *)0)->member_0: %p\r\n",
          &((TestStruct *)0)->member_0);
  printf("&testPtr->member_1: %p\r\n",
          &testPtr->member_1);
  printf("offsetof member_0: 0x%zx\r\n",
          offsetof(TestStruct,
                   member_0));
  printf("offsetof member_1: 0x%zx\r\n",
          offsetof(TestStruct,
                   member_1));
  printf("container_of member_0: %p\r\n",
          container_of(&test.member_0,
                       TestStruct,
                       member_0));
  printf("container_of member_1: %p\r\n",
          container_of(&test.member_1,
                       TestStruct,
                       member_1));
}
```

The results are:

```c
test addr :0x7fff5aaa0a80
member_0 addr :0x7fff5aaa0a80
member_1 addr :0x7fff5aaa0a88
&((TestStruct *)0)->member_0: 0x0
&testPtr->member_1: 0x8
offsetof member_0: 0x0
offsetof member_1: 0x8
container_of member_0: 0x7fff5aaa0a80
container_of member_1: 0x7fff5aaa0a80
```