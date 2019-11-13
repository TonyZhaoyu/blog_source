---
title: Techniques in C and compiler
date: 2018-08-13 11:52:06
---

#### **Malloc an array of pointers**

Consider a situation where an array needs to be created during run-time, and in this array, pointers will be stored. The following code shows a structure definition, whose pointer will be stored in an array.

```c
typedef struct _testStruct {
  uint8_t  bla;
  uint16_t blabla;
} TestStruct;

typedef TestStruct * testStructPtr;
```

Here's the code of mallocin' the array.

```c
#define ARRAY_SIZE (5)

testStructPtr * array = (testStructPtr *)malloc(ARRAY_SIZE * sizeof(testStructPtr));
```

***

#### **Play with GCC**

Sometimes we found C code reading is not fun at all, especially the code with many strange symbols. Here's an example:

```c
__attribute__((weak)) int foo(int bar)
{
  // Blablabla
}
```

The symbol *__attribute__((weak))* is specifically used by GCC for compilation and linking. There are tons of such symbols, but I will be focusing on the commonly used one. For many coders, the options that come up with *gcc* may be another mysterious land. For example, *--wrap*.

* Weak attribute symbol.

By default, when we declare the implementation of a function in a C file, then the function symbol is defined as a strong symbol. Any attempt to redefine this strong symbol will lead to the well know error you may know: the multiple definitions of error.

```bash
libhello.a(hello.c.o): In function 'open_i2c':
lib/hello.c:15: multiple definition of `open_i2c'
tests_do_something.c.o:tests_do_something.c:12: first defined here
```

>**Weak symbols, however, can be redefined.** This is exactly what we need in order to test that our high-level function correctly calls our low-level function, while these to functions being implemented in the same source file.

Reference: https://blog.microjoe.org/2017/unit-tests-c-cmocka-coverage-cmake.html#declaring-tests.

* Wrap functions.

We could use a GCC linker option named '--wrap=....' to tell the linker which function to be linked. Since you are more likely to call gcc instead of ld in your compilation process, you can tell gcc to pass the --wrap option to ld by passing the --Wl,--wrap=... argument to GCC.

The --wrap=open notation asks GCC to make every call to the open functon to reach the __wrap_open function instead. If for whatever reason you need to use the real open function after this option is passed, then you can call the __real_open function (after declaring its prototype).

For example, we want to mock the system call *close* which is called in a function of a C file.

```c
/* src.c */
int foo(void)
{
  close();
}
```

We write a test file to test foo() but don't actually want to trigger a system call. In the test file, we could do:

```c
/* test.c */
int __wrap_close(int fd)
{
  // The following line is CMocka based.
  check_expected(fd);
  return mock();
}
```

When we use gcc to compile and link, we need to specify something like the following:

```bash
gcc src.c test.c -Wl,--wrap=close -o test
```

Reference: https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_node/ld_3.html.

***

#### **Function pointers**

Function pointers have been widely used in C/C++ SDKs. In SDKs, they are usually wrapped into hook functions. Take the famous uC/OS kernel as an example, the following screenshot quoted one of the customer stories [original link](https://www.micrium.com/about/customer-stories/vasamed/).
> The power-management features of uC/OS can keep a device running for years without a battery change. These features include hook functions for initiating low-power modes, support for a dynamic tick rate, and even tick-less operations.

To exemplify the usage of function pointers (or hook functions), open-source libraries are to be used to serve our case. cJSON library is a C/C++ open-source library dealing with JSON data [Github link](https://github.com/DaveGamble/cJSON). In cJSON.h, line 57 ~ 60 defines a hook function which allows users to enable specified ‘malloc’ and ‘free’ methods. The code snippets are shown below:

```c
typedef struct cJSON_Hooks {
      void *(*malloc_fn)(size_t sz);
      void (*free_fn)(void *ptr);
} cJSON_Hooks;

/* Supply malloc, realloc and free functions to cJSON */
extern void cJSON_InitHooks(cJSON_Hooks* hooks);
```

How cJSON_InitHooks() method is being used in cJSON.c? Line 46 ~ 47 defines the function pointer variables as below:

```c
static void *(*cJSON_malloc)(size_t sz) = malloc;
static void (*cJSON_free)(void *ptr) = free;
```

These variables, by default are assigned to malloc and free function pointer provided by stdlib.h. As such, even if cJSON_InitHooks() method is never been called, the rest of cJSON’s methods are still functioning. As for user specified functions, the body of cJSON_InitHooks is presented as below:

```c
void cJSON_InitHooks(cJSON_Hooks* hooks)
{
    if (!hooks) { /* Reset hooks */
        cJSON_malloc = malloc;
        cJSON_free = free;
        return;
    }

    cJSON_malloc = (hooks->malloc_fn)?hooks->malloc_fn:malloc;
    cJSON_free = (hooks->free_fn)?hooks->free_fn:free;
}
```

Pretty smart huh? Here is a dummy example of using such a hook function. NB: this example makes no sense in real applications.

```c
#include <stdio.h>
#include <stdlib.h>
#include "cJSON.h"

/*
 * @brief: self-defined malloc method.
 */
void *selfdefMallocMethod(size_t sz)
{
    printf("self-defined malloc function is invoked.\n");
    return malloc(sz);
}

/*
 * @brief: self-defined free method.
 */
void selfdefFreeMethod(void *ptr)
{
    printf("self-defined free function is invoked.\n");
    return free(ptr);
}

int main(int argc, char **argv)
{
    cJSON_Hooks *myHookMethods = (cJSON_Hooks *)malloc(sizeof(cJSON_Hooks));
    myHookMethods->malloc_fn = selfdefMallocMethod;
    myHookMethods->free_fn = selfdefFreeMethod;
    cJSON_InitHooks(myHookMethods);

    const char *dummyStr = "{\"please_parse_me\":\"Okay\"}"
    cJSON *dummyJSON = cJSON_Parse(dummyStr);
    cJSON_Delete(dummyJSON);

    return 0;
}
```

You should be able to see several printouts of “self-defined malloc method is invoked” when cJSON_Parse method is called, and several printouts of “self-defined free method is invoked” when cJSON_Delete is called.

Hereby, paho-mqtt-client [Github link](https://github.com/eclipse/paho.mqtt.c) library has been used as another example. Paho-mqtt-client library is much more complex than cJSON library. To begin with, one needs to include the top-level MQTTClient.h to initialize an MQTT client and instantiate hook functions. Some understanding barriers need to be removed beforehand:

1. In MQTTClient.h, what is this macro ‘DLLExport’? DLLExport is defined by line 109 ~ 115. Since only Unix platform is considered, according to line 114, ‘DLLExport’ is defined as below:

```c
#define DLLExport __attribute__ ((visibility (&default)))
```

**__attribute__ ((visibility (“default”)))** could be referred to this link (http://gcc.gnu.org/wiki/Visibility). Herein, I duplicate some of the explanations: “Default visibility is the normal case for ELF. This value is available for the visibility attribute to override other options that may change the assumed visibility of symbols“.  In short, it indicates similar meaning as ‘export’. What are the ways to define a hook function (function pointer)? Firstly, as described in part I, using the keyword ‘typedef ‘ with an explicit ‘* ‘ prefix could serve the case. e.g., typedef void (* dummyMethod) (int argument1); Secondly, just like the way in MQTTClient.h, the explicit ‘*’ prefix no longer exists. e.g., line 334:

2. What are the ways to define a hook function (function pointer)? Firstly, as described in part I, using the keyword ‘typedef ‘ with an explicit ‘* ‘ prefix could serve the case. e.g., typedef void (* dummyMethod) (int argument1); Secondly, just like the way in MQTTClient.h, the explicit ‘*’ prefix no longer exists. e.g., line 334:

```c
typedef void MQTTClient_connectionLost(void* context, char* cause);
```

As such, MQTTClient_connectionLost could be used as a variable. Such a variable could be found in line 363:

```c
DLLExport int MQTTClient_setCallbacks(MQTTClient handle, void* context, MQTTClient_connectionLost* cl,
MQTTClient_messageArrived* ma, MQTTClient_deliveryComplete* dc);
```

For more details, please refer to the following [link](https://stackoverflow.com/questions/1591361/understanding-typedefs-for-function-pointers-in-c).
An example of client initialisation and MQTTClient_setCallbacks instantiation is presented as the following code snippets.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "MQTTClient.h"

void delivered(void *context, MQTTClient_deliveryToken dt)
{
    printf("Message with token value %d delivery confirmed\n", dt);
}

int msgarrvd(void *context, char *topicName, int topicLen, MQTTClient_message *message)
{
    char *payloadptr = (char *)malloc(message->payloadlen + 1);
    memset(payloadptr,0,message->payloadlen + 1);
    strcpy(payloadptr,(char *)(message->payload));
    printf("Message arrived\n");
    printf("topic: %s\n", topicName);
    printf("Message payload: %s\n",payloadptr);
    free(payloadptr);
    MQTTClient_freeMessage(&message);
    MQTTClient_free(topicName);
    return 1;
}

void connlost(void *context, char *cause)
{
    printf("\nConnection lost\n");
    printf("cause: %s\n", cause);
}

int main(int argc, char **argv)
{
    MQTTClient client;
    // ...
    MQTTClient_setCallbacks(client, NULL, connlost, msgarrvd, delivered);
    // ...
    return 0;
}
```

***

#### **Print pointer values**

This may not be a trick, but something that's worth noting.

```c
#include <stdio.h>
#include <stdlib.h>

void pointerFuncA(int* iptr){
/*Print the value pointed to by iptr*/
printf("Value:  %d\n", *iptr );

/*Print the address pointed to by iptr*/
printf("Value:  %p\n", iptr );

/*Print the address of iptr itself*/
printf("Value:  %p\n", &iptr );
}

int main(){
int i = 1234;
int* foo = &i;
pointerFuncA(foo);

return 0;
}
```

Output:

```c
Value:  1234
Value:  0xffe2ac6c
Value:  0xffe2ac44
```

***

#### **Muli-line function MACRO definition**

Sometimes, one needs to use MACROs to define a function that contains multiple lines and a return value. An example of doing such a definition is given below:

```c
#include <stdio.h>

#define max_t(type,x,y) \
 	({ type __x = (x); type __y = (y); __x > __y ? __x: __y; })

int main(int argc, char *argv[])
{
  int a = 5, b = 6;

  int c = max_t(int, a, b);

  int d = ({
    int __x = 7;
    int __y = 8;
    __x > __y ? __x : __y;
  });

  printf("max_t result: c = %d\r\n", c);
  printf("max_t result: d = %d\r\n", d);

  return 0;  
}
```

Output:

```c
max_t result: c = 6
max_t result: d = 8
```

This example is inspired by the Linux kernel code, where *max_t* resides in kernel.h file. Notice the key is the brackets. If they are removed, compilation error would emerge. What also noticeable is the *type* parameter for run-time type casting.
