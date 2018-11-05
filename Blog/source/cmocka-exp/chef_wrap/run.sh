#!/bin/bash

SYSTEM=$(uname)

## Paths.
LIB_PATH=lib

## Exe and obj names.
CHEF_OBJ=chef
WAITER_OBJ=waiter_test_wrap
EXE_CMOCKA=chef_test

## Build test binary.
rm -f $EXE_CMOCKA *.o

# Build src.
# gcc -c -g -Wl,--wrap=chef_cook $CHEF_OBJ.c -o $CHEF_OBJ.o
# gcc -c -g -Wl,--wrap=chef_cook $WAITER_OBJ.c -o $WAITER_OBJ.o
# Link objects.
if [[ $SYSTEM == 'Darwin' ]]; then
  gcc $CHEF_OBJ.c $WAITER_OBJ.c -L./$LIB_PATH -o $EXE_CMOCKA -lcmocka
fi
# House keeping.
rm -f *.o

## Configure dylib path.
if [[ $SYSTEM == 'Darwin' ]]; then
  install_name_tool -change @rpath/libcmocka.0.dylib $(pwd)/libcmocka.0.4.1.dylib $EXE_CMOCKA
fi
