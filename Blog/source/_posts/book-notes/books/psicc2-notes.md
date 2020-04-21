---
title: PSiCC2
date: 2018-05-29 10:39:45
categories:
- [Book notes, Books]
---

#### QP framework reference (PSICC2)

<img src="http://www.state-machine.com/qpc/qp_banner.jpg" width="400" style="border-style: none">

*Courtesy of Quantum Leaps:* http://www.state-machine.com/

#### Software tracing for event-driven systems

Section 11.1 has a brilliant description of a non-intrusive tracing method. Quoted below:

> To minimize the RAM usage, the target-resident trace component typically uses a **circular trace buffer** that is continuously updated, and new data overwrites the old when the buffer "wraps around" due to limited size or transmission rate to the host. This reflects the typically applied *last-is-best* policy in collecting the trace data.

Whenever reading the above description, I'm always wondering how SEGGER systemview code works? Will try to dig in and to see whether a circular buffer is used to transmit data to JLink device.

***

#### Application Note: OOP in C

This App note is not part of the book, but what has been described in the App note is deployed in the QF code. Before exploring OOP in C code, some knowledge is worth discussing.

##### Upcasting and downcasting in C

The concept is commonly used in OOP (object-oriented programming). The direction *up* and *down* indicates the conversion between the pointer to a super class and the pointer to a subclass. Specifically, *upcasting* means a subclass pointer is treated as a super class pointer (going up to the root class). Conversely, when treating a super class pointer to a subclass pointer (going down to the derived class), *downcasting* is used.

Upcasting is safe in C's context due to the following reason:

>The alignment of the Rectangle structure (*a subclass*) and the inherited attributes of the Shape structure (*a super class*) is guaranteed by the C standard WG14/N1124. Section 6.7.2.1.13 of this standard, says: "... A pointer to a structure object, suitably converted, points to its initial member. There may be unnamed padding within a structure object, but not at its beginning".

Downcasting may be unsafe if calling methods exclusively to the derived class. Normally, such an unsafe action should not be conducted, since the purpose of downcasting is to address polymorphism by calling the interfacing methods in the super class.

##### Inline functions in C

This technique is rarely in my project, as function call overhead is not a huge problem. It's worth noting in some embedded systems, performance does matter, and hence here are some discussions based on the article: http://www.drdobbs.com/the-new-c-inline-functions/184401540.

When dealing with inline functions, a question came to my mind is how inline function saves time compared to normal function calls. In the aforementioned article, there's a nice example:

```c
extern int a, b, c;

void callee(int *x, int y)
{
  *x = 10 * y;
}

void caller_1()
{
  a = 10 * b;
  f(&c, b);
}
```

if callee() is an inline function, i.e., *inline void callee()*, the compiler could optimize caller_1() as the following:

```c
void caller_1()
{
  // After inline substitution.
  a = 10 * b;
  *&c = 10 * b;
}
```

If no inline substitution, a call of callee() would incur stack storage of the input parameter, stack storage of the output, frame-counter storage, and restore the frame-counter to release stack. The following is a more elaborated version:

>Argument values are copied to the stack or special registers; A return address is created and stored on the stack or to a register; The program branches to the function; A stack frame is set up for the local variables of the function; After the function finishes, the stack frame is torn down; The return address is retrieved; A branch is made to the return address.

From the above example, we could observe that inline substitution cuts off the routine that a normal function call does, and hence saves time. In the article, the writer introduces a potential behavior of a compiler when conducting inline substitution. In short, there may be a few iterations of optimizations before reconstructing the code in the example. Function MACROs could also be in favor of increasing performance. Notice the body of MACROs will be textually replaced to the original callee(), and may not preserve the semantics of the callee like the compiler does.

The primary disadvantage of using inline functions is that the code could grow bigger. The article points out `In extreme cases,this can degrade program performance by increasing page faults and cache misses`.
