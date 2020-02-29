---
title: A crash-course of using Cmocka
date: 2018-09-20 13:09:17
categories:
- [Coding, Practices, Cmocka crash-course]
---

Unit testing is not just value validation using assertions. An important testing technique, namely mock, should be equally addressed. Cmocka provides a test framework of conducting mock features. The following content serves as a summary of two related links (https://blog.microjoe.org/2017/unit-tests-c-cmocka-coverage-cmake.html#assert-functions and https://lwn.net/Articles/558106/), targeting to clarify the concept of mock and the usage of Cmocka.

It is assumed that users are able to generate dynamically libraries of Cmocka. The test platform is on a Ubuntu. Unfortunately, LLVM on MacOS does not recognize *--wrap* option. Following the steps below to complete source code preparation:

1. Download the source from https://cmocka.org/files/1.1/. Decompress the folder.
2. Enter the decompressed folder and follow the commands above to build the source code. Line 3 (i.e., cmake ..) might be overlooked from time to time. Usally '..' points to where cmocka is.

```bash
$ mkdir build
$ cd build
$ cmake ..
$ make clean
$ make -j4
```

3. To show how the library to be integrated into your project, we use the chef_wrap example that comes with the cmocka package. Copy the chef_wrap folder from Cmocka example into a preferred path.
4. Create a folder and name it as *lib* under chef_wrap folder. And copy the dynamic library (under the path build/src/) into the lib folder. You should be able to see three files (*libcmocka.so.0.4.1, libcmocka.s0.0 and libcmocka.so*) under the lib folder. Two of the files are symbolic links, and they are related to the *so* file as below. One could create the symbolic links if not exist.

```bash
lrwxrwxrwx 1    14 Sep 22 22:07 libcmocka.so -> libcmocka.so.0
lrwxrwxrwx 1    18 Sep 22 22:07 libcmocka.so.0 -> libcmocka.so.0.4.1
-rwxr-xr-x 1 52768 Sep 22 22:07 libcmocka.so.0.4.1
```

> Virtual box shared folder does not allow symbolic links to be created (nor exist). Hence use a folder other than the shared ones.

5. Modify chef.c and waiter_test_wrap.c. Change *#include <cmocka.h>* to *#include "cmocka.h"*.
6. Copy *cmocka.h* (under *include* folder) under the chef_wrap folder.
7. Create a shell script to compile and link the source code. An example of such a script could be the following:

```bash
# System variables.
SYSTEM=$(uname)
CC=gcc
LD=gcc

SRC_DIR=./
INC_DIR=./
LIB_DIR=./

# Compile src files.
$CC -Wall -c $SRC_DIR/chef.c -I$INC_DIR -o $SRC_DIR/chef.o
$CC -Wall -c $SRC_DIR/waiter_test_wrap.c -I$INC_DIR -o $SRC_DIR/waiter_test_wrap.o

# Link objs.
$LD $SRC_DIR/chef.o $SRC_DIR/waiter_test_wrap.o -o $SRC_DIR/chef_test -L./$LIB_DIR -lcmocka -Wl,-rpath=./$LIB_DIR
```

8. The execution result is as follows:

```log
[==========] Running 2 test(s).
[ RUN      ] test_order_hotdog
Chef couldn't cook hotdog: Unknown error!
[  ERROR   ] --- 0xffffffffffffffff != 0
[   LINE   ] --- .//waiter_test_wrap.c:130: error: Failure!
[  FAILED  ] test_order_hotdog
[ RUN      ] test_bad_dish
Chef couldn't cook hotdog: Unknown error!
[  ERROR   ] --- 0xffffffffffffffff != 0xfffffffffffffffe
[   LINE   ] --- .//waiter_test_wrap.c:163: error: Failure!
[  FAILED  ] test_bad_dish
[==========] 2 test(s) run.
[  PASSED  ] 0 test(s).
[  FAILED  ] 2 test(s), listed below:
[  FAILED  ] test_order_hotdog
[  FAILED  ] test_bad_dish

2 FAILED TEST(S)
```
